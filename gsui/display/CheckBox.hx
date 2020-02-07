package gsui.display;
import bindx.IBindable;
import gsui.utils.DestroyUtils;
import gsui.utils.GraphicsUtils;
import gsui.display.GenericButton;
import haxe.xml.Fast;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
 * Checkbox
 * @author loudo
 */
class CheckBox extends GenericButton implements IBindable
{

	var _bg:Bitmap = null;
	var _check:Bitmap = null;
	var _label:GUITextField;
	@:bindable public var checked:Bool = false;
	
	public function new(Data:Fast, Bg:BitmapData, Check:BitmapData, ContainerW:Float, ContainerH:Float) 
	{
		super(Data.has.click ? Data.att.click : "", "");
		if(Data.has.id)
			name = Data.att.id;
		_bg = new Bitmap(Bg, PixelSnapping.AUTO, true);
		_check = new Bitmap(Check, PixelSnapping.AUTO, true);
		if (Data.has.checkPos) {
			var temp:Array<String> = Data.att.checkPos.split(',');
			_check.x = Std.parseInt(temp[0]);
			_check.y = Std.parseInt(temp[1]);
			temp = null;
		}
		
		addChild(_bg);
		
		_label = new GUITextField(GUI._getDef(Data.att.label_def), ContainerW, ContainerH);
		_label.updateText(Data.att.label);
		_label.x += _bg.width;
		addChild(_label);
		
		
		GraphicsUtils.drawRectFill(this.graphics, _bg.width, _bg.height, 0, 0);

		
		_positions = new ElementPosition(Data, ContainerW, ContainerH, _bg.width, _bg.height);
		
		init();
	}
	
	override public function select():Void
	{
		if (_check != null) {
			if (!checked) {
				checked = true;
				addChild(_check);
			}else {
				checked = false;
				if(_check.parent != null)
					_check.parent.removeChild(_check);
			}
		}
		super.select();
		
	}
	override public function unselect():Void
	{
		if (_check != null) {
			if (checked) {
				checked = false;
				if(_check.parent != null)
					_check.parent.removeChild(_check);
			}
		}
		super.unselect();
	}
	
	override public function destroy():Void
	{
		//TODO destroy pour tous les UI
		DestroyUtils.dispose(_bg.bitmapData);
		DestroyUtils.dispose(_check.bitmapData);
		super.destroy();
	}
	
	public function check(newValue:Bool = true):Void
	{
		if(newValue)
			select();
		else if (newValue != checked)
			unselect();
	}
	
}