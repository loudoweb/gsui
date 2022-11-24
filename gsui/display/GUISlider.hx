package gsui.display;

import bindx.IBindable;
import haxe.xml.Access;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * Slider
 * @author loudo
 */
class GUISlider extends Sprite implements IBindable {
	var _bg:Bitmap;
	var _progress:Sprite;
	var _progressRect:Rectangle;
	var _slide:Sprite;
	var _label:GUITextField;
	var _rect:Rectangle;
	var _button:SimpleButton;

	@:bindable public var value(default, set):Float;

	public function new(Data:Access, ContainerW:Float, ContainerH:Float) {
		super();

		if (Data.has.id)
			name = Data.att.id;

		var sliderDef:Access = Data.has.slider_def ? GUI._getDef(Data.att.slider_def) : null;
		var labelDef:Access = Data.has.label_def ? GUI._getDef(Data.att.label_def) : (sliderDef != null
			&& sliderDef.has.label_def ? GUI._getDef(sliderDef.att.label_def) : null);
		var buttonDef:Access = Data.has.button_def ? GUI._getDef(Data.att.button_def) : (sliderDef != null
			&& sliderDef.has.button_def ? GUI._getDef(sliderDef.att.button_def) : null);

		if (sliderDef == null) {
			sliderDef = Data;
		}

		var bg:BitmapData = sliderDef.has.bg ? GUI._getBitmapData(sliderDef.att.bg) : null;
		_bg = new Bitmap(bg, PixelSnapping.AUTO, true);
		addChild(_bg);

		if (sliderDef.has.progress) {
			_progress = new Sprite();
			_progress.addChild(new Bitmap(GUI._getBitmapData(sliderDef.att.progress)));
			addChild(_progress);
			_progressRect = new Rectangle(0, 0, _progress.width, _progress.height);
			_progress.scrollRect = _progressRect;
		}

		if (buttonDef != null) {
			var sliderOff:BitmapData = buttonDef.has.name ? GUI._getBitmapData(buttonDef.att.name) : null;
			var sliderOn:BitmapData = buttonDef.has.hover ? GUI._getBitmapData(buttonDef.att.hover) : null;
			// TODO use SliderButton
			_button = new SimpleButton(sliderOff, sliderOn, sliderOn, buttonDef, _bg.width, _bg.height);
			_button.disableGUICallback = true;
			_button.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_slide = new Sprite();
			addChild(_slide);
			_slide.addChild(_button);

			_rect = new Rectangle(-_slide.width / 2, _slide.y, _bg.width, 0);
		} else {
			trace("attribute button_def should be defined");
		}

		if (labelDef != null) {
			_label = new GUITextField(labelDef, 0, _bg.height);
			var textContainer:Sprite = new Sprite();
			textContainer.x += _bg.width + 10; // TODO externaliser
			addChild(textContainer);
			textContainer.addChild(_label);
		}

		value = 1;
	}

	public function set_value(newValue:Float):Float {
		value = newValue;

		setLabel(newValue);

		if (_slide != null)
			_slide.x = Std.int(newValue * _bg.width - _slide.width * 0.5);

		return newValue;
	}

	inline public function setLabel(newValue:Float):Void {
		if (_label != null)
			_label.text = Std.string(Std.int(newValue * 100));
	}

	function onDown(e:MouseEvent):Void {
		_slide.startDrag(false, _rect);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
	}

	function onUp(e:MouseEvent):Void {
		_slide.stopDrag();
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);

		// update value
		value = (_slide.x + _slide.width / 2) / _bg.width;
		_button.unselect();
	}

	function onMove(e:MouseEvent):Void {
		setLabel((_slide.x + _slide.width / 2) / _bg.width);
		if (_progress != null) {
			_progressRect.width = _slide.x;
			_progress.scrollRect = _progressRect;
		}
	}

	function _clickHandler(button:GenericButton, eventType:String, param:String):Void {
		// TODO push to update?
		trace('click');
	}

	public static function merge(Data:Access, Def:Access):Access {
		// TODO merge
		return Data;
	}
}
