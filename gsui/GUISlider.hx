package gsui;
import bindx.IBindable;
import haxe.xml.Fast;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import gsui.interfaces.ILayoutable;

/**
 * Slider
 * @author loudo
 */
class GUISlider extends Sprite implements ILayoutable implements IBindable
{
	var _bg:Bitmap;
	var _slide:Sprite;
	var _label:GUITextField;
	@:bindable public var value(default, set):Float;
	
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		if(Data.has.id)
			name = Data.att.id;
		var sliderDef:Fast = Data.has.slider_def ? GUI._getDef(Data.att.slider_def) : null;
		var labelDef:Fast = Data.has.label_def ? GUI._getDef(Data.att.label_def) : (sliderDef != null && sliderDef.has.label_def ?  GUI._getDef(sliderDef.att.label_def) : null);
		var buttonDef:Fast = Data.has.button_def ? GUI._getDef(Data.att.button_def) : (sliderDef != null && sliderDef.has.button_def ?  GUI._getDef(sliderDef.att.button_def) : null);
		
		if (sliderDef == null)
		{
			sliderDef = Data;
		}
		
		var bg:BitmapData = sliderDef.has.bg ? GUI._getBitmapData(sliderDef.att.bg) : null;
		_bg = new Bitmap(bg, PixelSnapping.AUTO, true);
		addChild(_bg);
		
		if (buttonDef != null) {
			var sliderOff:BitmapData = buttonDef.has.name ? GUI._getBitmapData(buttonDef.att.name) : null;
			var sliderOn:BitmapData = buttonDef.has.hover ? GUI._getBitmapData(buttonDef.att.hover) : null;
			//TODO use SliderButton
			var button:SimpleButton = new SimpleButton(sliderOff, sliderOn, sliderOn, buttonDef, _bg.width, _bg.height);
			button.hasGUICallback = false;
			button.mouseCallback = _clickHandler;
			_slide = new Sprite();
			addChild(_slide);
			_slide.addChild(button);
		}else {
			trace("attribute button_def should be define");
		}
		
		if(labelDef != null){
			_label = new GUITextField(labelDef, 0, _bg.height);
			var textContainer:Sprite = new Sprite();
			textContainer.x += _bg.width + 10;//TODO externaliser
			addChild(textContainer);
			textContainer.addChild(_label);
		}
		value = 1;
		
	}
	public function set_value(newValue:Float):Float
	{
		value = newValue;
		if (_label != null)
			_label.text = Std.string(Std.int(newValue*100));
		if (_slide != null)
			_slide.x = Std.int(newValue * _bg.width - _slide.width*0.5);
		return newValue;
	}
	
	private function _clickHandler(button:AbstractButton, eventType:String, param:String):Void
	{
		//TODO push to update?
	}
	
	public static function merge(Data:Fast, Def:Fast):Fast
	{
		//TODO merge
		return Data;
	}
	
}