package gsui;

import gsui.display.GUIGroup;
import gsui.utils.GraphicsUtils;
import motion.Actuate;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;


/**
 * Global scroll that allow scroll for the whole app.
 * //TODO add inertia
 * //TODO make bottom of slide fits bottom of screen when scrolling up at maximum
 * //TODO allow scroll at a component-basis and not only for the whole app
 * @author Ludovic Bas
 */
class Scroller {
	

	public static var MIN_TIME_FOR_SCROLL:Int = 500;
	public static var MIN_DIST_FOR_SCROLL:Int = 50;
	public static var HEADER:Int = 0;
	
	public static var STAGE:Stage = Lib.current.stage;
	
	public static var target(default, set):DisplayObject;
	
	public static var isScrolling(default, null):Bool;
	
	public static var hasScrolling(default, null):Bool;
	
	public static var onScroll:lime.app.Event<Float->Void> = new lime.app.Event<Float->Void>();
	
	static var hasInit:Bool;
	
	/**
	 * This element will not moved with the scroller
	 */
	public static var fixedElement:DisplayObject;
	public static var fixedElementOriginY:Float;
	
	static var _previousY:Float;
	static var _lastY:Float;
	static var _startY:Float;
	static var _time:Int = 0;
	static var _previousTime:Int = 0;
	static var _deltaT:Float = 0;
	
	static var _deltaDist:Float = 0;
	static var _globalDist:Float = 0;
	
	static var _targetHeight:Float;
	
	static var _parentWidth:Float;
	static var _parentHeight:Float;
	static var _parentRatio:Float;
	static var _posX:Float;
	static var _posY:Float;
	
	public static var scrollbar(default, null):Sprite;
	static var _bar:Sprite;
	static var _barBounds:Rectangle;
	
	public static function createScrollbar(height:Int, posX:Int):Sprite
	{
		scrollbar = new Sprite();
		_bar = new Sprite();
		GraphicsUtils.drawRectFill(scrollbar.graphics, 10, height - 20, 0x786E64, 0.2);
		GraphicsUtils.drawRectFill(_bar.graphics, 10, (height - 20) / 3, 0x786E64, 0.3);
		scrollbar.addChild(_bar);
		scrollbar.x = Lib.current.stage.stageWidth - scrollbar.width - 10 + posX;
		scrollbar.y = 10;
		_barBounds = new Rectangle(0, 0, 0, scrollbar.height - _bar.height);
		_bar.buttonMode = true;
		fixedElement = scrollbar;
		fixedElementOriginY = scrollbar.y;
		return scrollbar;
	}
	
	public static function set_target(_target:DisplayObject):DisplayObject
	{
		
		removeEnterFrame();
		removeListeners(true);
		
		if (target != null && target.hasEventListener(MouseEvent.CLICK))
				target.removeEventListener(MouseEvent.CLICK, stopClick, true);
				
		if (fixedElement != null)
			fixedElement.y = fixedElementOriginY;
		
		_lastY = -1;
		_startY = -1;
		
		target = _target;
		
		hasScrolling = false;
		
		checkNeedScroll();
		
		if (!hasInit)
		{
			hasInit = true;
			//SignalHandler.onScrollNewSize.add(modifySizeForScroll);
			//SignalHandler.onScrollGoBottom.add(onGoBackPage);
			//SignalHandler.onScrollNewPos.add(modifyScrollPos);
		}
		
		if (scrollbar != null)
		{
			scrollbar.parent.addChild(scrollbar);
			_bar.y = 0;
			
		}
		
		return _target;
	}
	
	public static function checkNeedScroll():Void
	{
		isScrolling = false;
		
		if (target ==  null)
			return;
		
		_targetHeight = target.height;
				
		trace(_targetHeight , _parentHeight, _targetHeight * _parentRatio);
		
		computeNeedScroll();
	}
	
	static function computeNeedScroll():Void
	{
			
		if (_targetHeight > _parentHeight + 1)//TODO use pixelbounds instead of simple height to not have masked height (when fixed in openfl)
		{
			//SignalHandler.onScrollAvailable.dispatch();
			hasScrolling = true;
			addListeners();
		}else{
			removeListeners();
			hasScrolling = false;
		}
	}
	
	static function addListeners(createScrollRect:Bool = true):Void
	{
		if(createScrollRect){

			target.scrollRect = new Rectangle( -_posX / _parentRatio, 0, _parentWidth / _parentRatio, _parentHeight / _parentRatio);
			target.x = 0;
		}
		STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		STAGE.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		
		if (scrollbar != null)
		{
			scrollbar.visible = true;
			scrollbar.parent.addChild(scrollbar);
			_bar.y = 0;
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
		}
		
	}
	
	static function removeListeners (destroyScroll:Bool = true):Void {
		if (STAGE.hasEventListener(MouseEvent.MOUSE_WHEEL))
			STAGE.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		if (STAGE.hasEventListener(MouseEvent.MOUSE_DOWN))
			STAGE.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
		if(destroyScroll && target != null){
			target.scrollRect = null;
			target.x = _posX;
		}
		if (isScrolling)
		{
			STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			STAGE.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			isScrolling = false;
		}
		
		if (scrollbar != null)
		{
			scrollbar.visible = false;
			_bar.removeEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
		}
	}
	
	static function onDown(e:MouseEvent):Void
	{
		removeEnterFrame();
		
		isScrolling = true;
		_startY = _lastY = e.stageY;
		STAGE.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		STAGE.addEventListener(MouseEvent.MOUSE_UP, onUp);
		
	}
	static function onUp(e:MouseEvent):Void
	{
		isScrolling = false;
		STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
		STAGE.removeEventListener(MouseEvent.MOUSE_UP, onUp);

		_globalDist = _startY - _lastY;
		_deltaDist = _lastY - _previousY;
		
		
		
		if (Math.abs(_globalDist) > MIN_DIST_FOR_SCROLL)
		{
			target.addEventListener(MouseEvent.CLICK, stopClick, true);
			//SignalHandler.onScrollBegin.dispatch();
			
			if (Lib.getTimer() - _time < 17)//avoid inertia when UP is fired at a different moment than the last MOVE event.
			{
			
				_deltaT = ( _time - _previousTime ) / 1000;//between 2 move events
				
				STAGE.addEventListener(Event.ENTER_FRAME, onUpdate);
			}
			
		}else{
			if (target.hasEventListener(MouseEvent.CLICK))
				target.removeEventListener(MouseEvent.CLICK, stopClick, true);
		}
		
	}
	
	static function onWheel (e:MouseEvent):Void {
		
		removeEnterFrame();
		
		var distWheel:Int = 80;
		var rect = target.scrollRect;
		if (e.delta > 0) {
			rect.y -= distWheel;
		} else {
			rect.y += distWheel;			
		}
		
		
		//SignalHandler.onScrollBegin.dispatch();
		
		checkBounds(rect);
		setFixedElements(rect.y);
		
		target.scrollRect = rect;
		
		if (_bar != null)
			_bar.y = Math.abs(rect.y / maxY()) * (scrollbar.height - _bar.height);
			
		onScroll.dispatch(rect.y);
		
	}
	
	static inline function removeEnterFrame():Void
	{
		if (STAGE.hasEventListener(Event.ENTER_FRAME)){
			STAGE.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}
	}
	
	static function checkBounds(rect:Rectangle):Void
	{
		var _max = maxY();
		if (rect.y < 0){
			rect.y = 0;
		}else if (rect.y > _max){
			rect.y = _max;
		}
	}
	
	static function setFixedElements(_y:Float):Void
	{
		if (fixedElement != null)
		{
			fixedElement.y = fixedElementOriginY + _y;
		}
	}
	
	static function onMove(e:MouseEvent):Void
	{
		
		var rect = target.scrollRect;
		rect.y -= (e.stageY - _lastY);
		_previousY = _lastY;
		_lastY = e.stageY;
		
		_previousTime = _time;
		_time = Lib.getTimer();
		
		
		
		checkBounds(rect);
		setFixedElements(rect.y);
		
		target.scrollRect = rect;
		
		if (_bar != null)
			_bar.y = Math.abs(rect.y / maxY()) * (scrollbar.height - _bar.height);
			
		onScroll.dispatch(rect.y);
	}
	
	static function onUpdate(e:Event):Void
	{

		var rect = target.scrollRect; 
		rect.y -= _deltaDist;
		checkBounds(rect);
		setFixedElements(rect.y);
		_deltaDist *= 0.96;//friction
		if (Math.abs(_deltaDist) < 1)
		{
			_deltaDist = 0;
			removeEnterFrame();
		}
		
		target.scrollRect = rect;
		
		onScroll.dispatch(rect.y);
		
	}
	
	/**
	   Parent of target can change his size
	   @param	addedSize
	**/
	public static function onParentSizeChanged (width:Float, height:Float, ratio:Float = 1, posX:Float = 0, posY:Float = 0) {
		_parentWidth = width;
		_parentHeight = height;
		_parentRatio = ratio;
		_posX = posX;
		_posY = posY;
		
		if (scrollbar != null)
			scrollbar.x = Lib.current.stage.stageWidth - scrollbar.width - 10 + posX;
		
		computeNeedScroll();
	}
	/**
	   Components that update their height need to call this function to update the scroll capacity
	   @param	addedSize
	**/
	public static function onTargetSizeChanged (width:Float, height:Float) {
		_targetHeight = height;
		computeNeedScroll();
	}
	
	/**
	 * Component can align the view by modifying the scrollrect position
	 * @param	newY
	 */
	public static function modifyScrollPos(newY:Float):Void {
		if (hasScrolling)
		{
			removeListeners(false);
			var rect = target.scrollRect;
			var initY = rect.y;
			rect.y = newY - HEADER;
			checkBounds(rect);
			Actuate.update (updateScroll, 0.3, [initY], [rect.y]).onComplete(addListeners, [false]);
		}
	}
	/**
	*  Animate until bottom reach
	**/
	public static function onGoBackPage () {
		if (hasScrolling)
		{
			removeListeners(false);
			var rect = target.scrollRect;
			var scrollTo = maxY();
			Actuate.update (updateScroll, 0.3, [rect.y], [scrollTo]).onComplete(addListeners, [false]);
		}
	}
	
	/**
	* Go immediatly to bottom   
	**/
	public static function toBottom () {
		if (hasScrolling)
		{
			var rect = target.scrollRect;
			rect.y = maxY();
			
			target.scrollRect = rect;
		}
	}
	
	/**
	*  Animate until bottom reach
	**/
	public static function onGoUpPage () {
		if (hasScrolling)
		{
			removeListeners(false);
			var rect = target.scrollRect;
			var scrollTo = 0;
			Actuate.update (updateScroll, 0.3, [rect.y], [scrollTo]).onComplete(addListeners, [false]);
		}
	}
	
	inline static function maxY():Float
	{
		//return (_targetHeight *  _parentRatio - _parentHeight) / _parentRatio - 1;//-1 to be sure
		return (_targetHeight - _parentHeight) / _parentRatio;//-1 to be sure
	}
	
	static function updateScroll(_y:Float):Void
	{
		var rect = target.scrollRect;
		rect.y = _y;
		target.scrollRect = rect;
		
		setFixedElements(_y);
	}
	
	static function stopClick(e:MouseEvent):Void
	{
		target.removeEventListener(MouseEvent.CLICK, stopClick, true);
		e.stopPropagation();
	}
	
	static function onBarDown(e:MouseEvent):Void
	{
		e.stopImmediatePropagation();
		
		_bar.removeEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
		STAGE.addEventListener(MouseEvent.MOUSE_UP, onBarUp);
		STAGE.addEventListener(MouseEvent.MOUSE_MOVE, onBarMove);
		_bar.startDrag(false, _barBounds);
	}
	
	static function onBarUp(e:MouseEvent):Void
	{
		STAGE.removeEventListener(MouseEvent.MOUSE_UP, onBarUp);
		STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onBarMove);
		_bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
		
		_bar.stopDrag();
	}
	
	static function onBarMove(e:MouseEvent):Void
	{
		var percent = _bar.y / (scrollbar.height - _bar.height);
		var rect = target.scrollRect;
		rect.y = percent * maxY();
		checkBounds(rect);
		setFixedElements(rect.y);
		target.scrollRect = rect;
		
		onScroll.dispatch(rect.y);
	}
	
	public static function getPosY():Float
	{
		return target.scrollRect.y;
	}
}