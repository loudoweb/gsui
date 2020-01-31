package gsui.display;
import gsui.interfaces.IDestroyable;
import gsui.interfaces.IPositionUpdatable;
import gsui.utils.MathUtils;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * Basic code for buttons (Button, SimpleButton)
 * @author loudo
 */
class AbstractButton extends Sprite implements IPositionUpdatable implements IDestroyable 
{

	public var isHover:Bool = false;
	@:isVar public var disableMouseClick(default, set):Bool = false;
	var _positions:ElementPosition;
	
	public var mouseCallback:AbstractButton->String->String->Void;
	public var onClickParam:String;
	public var onHoverParam:String;
	public var hasGUICallback:Bool;
	
	public function new(ClickParam:String, HoverParam:String) 
	{
		super();
		onClickParam = ClickParam;
		onHoverParam = HoverParam;
	}
	private function init():Void
	{
		mouseChildren = false;
		isHover = false;
		hasGUICallback = true;
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
			if (onHoverParam != "")
			{
				if(hasGUICallback)
					GUI._mouseHandler(this, MouseEvent.ROLL_OVER, onHoverParam);
				if (mouseCallback != null)
					mouseCallback(this, MouseEvent.ROLL_OVER, onHoverParam);
			}
		}else {
			isHover = false;
			GUI._cursorOut();
			if (onHoverParam != "")
			{
				if(hasGUICallback)
					GUI._mouseHandler(this, MouseEvent.ROLL_OUT, "");
				if (mouseCallback != null)
					mouseCallback(this, MouseEvent.ROLL_OUT, "");
			}
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
		if(hasGUICallback && onClickParam != "")
			GUI._mouseHandler(this, MouseEvent.CLICK, onClickParam);
			
		if(mouseCallback != null)
			mouseCallback(this, MouseEvent.CLICK, onClickParam);
				
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
		onClickParam = null;
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