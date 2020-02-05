package gsui.display;
import gsui.interfaces.IDestroyable;
import gsui.interfaces.IPositionUpdatable;
import gsui.utils.MathUtils;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * Basic code for buttons (Button, SimpleButton)
 * There are 2 variables for click and 2 for hover which allow to call at the same time native ui call (GUI._mouseHandler) and custom callback
 * @author loudo
 */
class AbstractButton extends Sprite implements IPositionUpdatable implements IDestroyable 
{
	
	/**
	 * Native click parameter used with GUI._mouseHandler
	 */
	public var clickParam:String;
	/**
	 * Native hover parameter used with GUI._mouseHandler
	 */
	public var hoverParam:String;
	/**
	 * Custom click parameter used with user custom class
	 */
	public var customClickParam:String;
	/**
	 * Native hover parameter used with user custom class
	 */
	public var customHoverParam:String;
	/**
	 * Custom mouse callback
	 */
	public var mouseCallback:AbstractButton->String->String->Void;
	
	/**
	 * disable native gui callback
	 * (previous name :	 hasGUICallback)
	 */
	public var disableGUICallback:Bool;
	
	@:isVar public var disableMouseClick(default, set):Bool;
	
	public var isHover:Bool;
	
	var _positions:ElementPosition;
	
	public function new(ClickParam:String, HoverParam:String) 
	{
		super();
		
		this.clickParam = ClickParam;
		this.hoverParam = HoverParam;
		this.customClickParam = "";
		this.customHoverParam = "";
		this.isHover = false;
		this.disableMouseClick = false;
		this.disableGUICallback = false;
	}
	private function init():Void
	{
		mouseChildren = false;
		isHover = false;
		disableGUICallback = false;
		handleListeners();
	}
	private function handleListeners(add:Bool = true):Void
	{
		if (add) {
			addEventListener(MouseEvent.CLICK, doSelected);
			buttonMode = true;
			if(_positions.hasOver){
				addEventListener(MouseEvent.ROLL_OVER, doHover);//TODO add in a update function
				addEventListener(MouseEvent.ROLL_OUT, doHover);//TODO add in a update function
			}
		}else {
			removeEventListener(MouseEvent.CLICK, doSelected);
			buttonMode = false;
			if(_positions.hasOver){
				removeEventListener(MouseEvent.ROLL_OVER, doHover);
				removeEventListener(MouseEvent.ROLL_OUT, doHover);
			}
		}
	}
	public function set_disableMouseClick(v:Bool):Bool
	{
		disableMouseClick = v;
		buttonMode = !v;
		return v;
	}
	private function doHover(e:MouseEvent):Void
	{
		if (e.type == MouseEvent.ROLL_OVER) {
			isHover = true;
			
			GUI._cursorOver();
			
			if (mouseCallback != null){
				mouseCallback(this, MouseEvent.ROLL_OVER, customHoverParam);
			}
			if (!disableGUICallback && hoverParam != "")
			{
				GUI._mouseHandler(this, MouseEvent.ROLL_OVER, hoverParam);
			}
			
		}else {
			isHover = false;
			
			GUI._cursorOut();
			
			
			if (mouseCallback != null)
				mouseCallback(this, MouseEvent.ROLL_OUT, "");
			/*if(disableGUICallback)
				GUI._mouseHandler(this, MouseEvent.ROLL_OUT, "");*/
			
		}
	}
	private function doSelected(e:MouseEvent):Void
	{
		if (!disableMouseClick) {	
			select();
		}
	}
	public function select():Void
	{
		if(mouseCallback != null){
			mouseCallback(this, MouseEvent.CLICK, customClickParam);
		}
		if (!disableGUICallback && clickParam != "")
		{
			GUI._mouseHandler(this, MouseEvent.CLICK, clickParam);
		}
				
	}
	public function unselect():Void
	{
		isHover = false;
	}
	
	public function overlap():Bool
	{
		if (parent != null)
		{
			return MathUtils.pointInCoordinates(parent.mouseX, parent.mouseX, x, y, width, height);
		}
		return false;
	}
	
	public function destroy():Void
	{
		isHover = false;
		mouseCallback = null;
		clickParam = null;
		hoverParam = null;
		customClickParam = null;
		customHoverParam = null;
		handleListeners(false);
	}
	
	public function getSlot(name:String):Slot
	{
		return null;
	}
	
	public function setX(x:Float):Void
	{
		_positions.x = x;
		this.x = x;
	}
	public function setY(y:Float):Void
	{
		_positions.y = y;
		this.y = y;
	}
}