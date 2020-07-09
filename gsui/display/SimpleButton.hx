package gsui.display;
import gsui.utils.MaskUtils;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.events.MouseEvent;
import haxe.xml.Access;

/**
 * Simple button that uses up to 3 images to handle up, over and selected states.
 * @author loudo
 */
enum State {
	DEFAULT;
	HOVER;
	SELECTED;
}
class SimpleButton extends GenericButton
{
	
	public var state:State;
	
	var _default:Bitmap = null;
	var _hover:Bitmap  = null;
	var _selected:Bitmap  = null;
	
	public function new(Up:BitmapData, Hover:BitmapData, Selected:BitmapData, Data:Access, ContainerW:Float, ContainerH:Float) 
	{
		super(Data.has.click ? Data.att.click : "", Data.has.onHover ? Data.att.onHover : "");
		
		if(Data.has.id)
			name = Data.att.id;
			
		if (Up == null)
			trace("attribute name missing in " + Data.x.toString());
		_default = new Bitmap(Up, PixelSnapping.AUTO, true);
		if(Hover != null)
			_hover = new Bitmap(Hover, PixelSnapping.AUTO, true);
		if(Selected != null)
			_selected = new Bitmap(Selected, PixelSnapping.AUTO, true);
		
		var _width = Data.has.width ? Std.parseFloat(Data.att.width) : GUI.GUI_WIDTH;
		var	_height = Data.has.height ? Std.parseFloat(Data.att.height): GUI.GUI_HEIGHT;
		_positions = new ElementPosition(Data, ContainerW, ContainerH, _default.width, _default.height);//TODO warning differents width between default and hover
		
		x = _positions.x;
		y = _positions.y;
		
		if (Data.has.scale)
			scaleX = scaleY = Std.parseFloat(Std.string(Data.att.scale));
		if (Data.has.sW)
			scaleX = Std.parseFloat(Std.string(Data.att.sW));
		if (Data.has.sH)
			scaleY = Std.parseFloat(Std.string(Data.att.sH));
		if (Data.has.a)
			rotation = Std.parseFloat(Std.string(Data.att.a));
		
		if(_positions.mask != null)
			MaskUtils.createMask(this, _positions.mask);
			
		if (Data.has.param)
			customClickParam = Data.att.param;
		
		addChild(_default);
		state = DEFAULT;
		_needRollListeners = _positions.hasOver;
		init();
	}
	override private function doHover(e:MouseEvent):Void
	{
		if (e.type == MouseEvent.ROLL_OVER)
		{
			if(_hover != null){
				if (numChildren > 0)
					removeChildAt(0);
				addChild(_hover);
			}
			x = _positions.x + _positions.x_hover;
			y = _positions.y + _positions.y_hover;
			if (_positions.maskOver != null)
				MaskUtils.createMask(this, _positions.maskOver);
			state = HOVER;
		}else {
			if(_hover != null){
				if (numChildren > 0)
						removeChildAt(0);
				addChild(_default);
			}
			x = _positions.x;
			y = _positions.y;
			if (_positions.maskOver != null)
				MaskUtils.createMask(this, _positions.mask);
		}
		state = DEFAULT;
		super.doHover(e);
		
	}
	override public function select():Void
	{
		if (_selected != null) {
			if (numChildren > 0)
				removeChildAt(0);
			addChild(_selected);
			x = _positions.x + _positions.x_selected;
			y = _positions.y + _positions.y_selected;
			if (_positions.maskSelected != null)
				MaskUtils.createMask(this, _positions.maskSelected);
			state = SELECTED;
			handleListeners(false);
		}
		super.select();
		
	}
	override public function unselect():Void
	{
		if(_hover != null){
			if (numChildren > 0)
					removeChildAt(0);
			addChild(_default);
		}
		x = _positions.x;
		y = _positions.y;
		if (_positions.maskOver != null || _positions.maskSelected != null)
			MaskUtils.createMask(this, _positions.mask);
		state = DEFAULT;
		handleListeners(true);
	}
}