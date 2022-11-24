package gsui.display;

import gsui.utils.ParserUtils;
import openfl.display.Sprite;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import haxe.xml.Access;
import openfl.Assets;
import openfl.display.Shape;
import openfl.geom.Point;
#if debug
import gsui.interfaces.IDebuggable;
import openfl.events.MouseEvent;
#end

/**
 * Textfield
 * TODO : inherits from textfield directly ?
 * @author loudo
 */
class GUITextField extends Base {
	public static var TONGUE_VAR:EReg = new EReg("{\\$[a-zA-Z0-9-_]+}", "ig");
	public static var GUI_VAR:EReg = new EReg("{[a-zA-Z0-9-_ ]+}", "ig");

	public var sourceText:String;
	public var text(get, set):String;
	public var textColor(get, set):UInt;

	public var textfield:TextField;

	var _upper:Bool;
	var _strike:Bool = false;
	var _strikeShape:Shape;

	/**
	 * Keep height set in xml
	 */
	var _keepHeight:Bool;

	public function new(Data:Access, ContainerW:Float, ContainerH:Float) {
		textfield = new TextField();
		textfield.embedFonts = true;

		super(Data, ContainerW, ContainerH);

		#if debug
		_colorDebug = 0xFF0000;
		#end
	}

	override function parse(xml:Access):Void {
		super.parse(xml);

		_upper = xml.has.upper && xml.att.upper == "true";

		var font:Font = null;

		if (xml.has.id) {
			textfield.name = xml.att.id;
		}

		var textDef:Access = GUI._getDef(xml.att.font);

		if (textDef == null) {
			textDef = GUI._getDef("defaultFont");
		}

		if (textDef != null && Assets.exists(textDef.att.font)) {
			font = Assets.getFont(textDef.att.font);
		} else if (textDef != null && Assets.exists("fonts/" + textDef.att.font + ".ttf")) {
			font = Assets.getFont("fonts/" + textDef.att.font + ".ttf");
		}
		if (Assets.exists(xml.att.font)) {
			font = Assets.getFont(xml.att.font);
		} else if (Assets.exists("fonts/" + xml.att.font + ".ttf")) {
			font = Assets.getFont("fonts/" + xml.att.font + ".ttf");
		}

		var size = xml.has.size ? Std.parseInt(xml.att.size) : (textDef.has.size ? Std.parseInt(textDef.att.size) : 20);

		var color = ParserUtils.getColor(xml, textDef);

		var format:TextFormat = new TextFormat(font.fontName, size, color);

		if (xml.has.align)
			format.align = xml.att.align;
		else if (textDef != null && textDef.has.align)
			format.align = textDef.att.align;

		if (xml.has.bold)
			format.bold = Std.string(xml.att.bold) == "true";
		else if (textDef != null && textDef.has.bold)
			format.bold = Std.string(textDef.att.bold) == "true";

		textfield.defaultTextFormat = format;

		if (xml.has.input && xml.att.input == "true") {
			textfield.type = TextFieldType.INPUT;
			textfield.selectable = true;
		} else if (textDef != null && textDef.has.input && textDef.att.input == "true") {
			textfield.type = TextFieldType.INPUT;
			textfield.selectable = true;
		} else {
			textfield.selectable = false;
		}

		if (xml.has.maxChars)
			textfield.maxChars = Std.parseInt(xml.att.maxChars);
		else if (textDef != null && textDef.has.maxChars)
			textfield.maxChars = Std.parseInt(textDef.att.maxChars);

		if (xml.has.a) // TODO r instead?
			textfield.rotation = Std.parseFloat(Std.string(xml.att.a));
		else if (textDef != null && textDef.has.a)
			textfield.rotation = Std.parseFloat(Std.string(textDef.att.a));

		if (xml.has.strike)
			_strike = xml.att.strike == "true";
		else if (textDef != null && textDef.has.strike)
			_strike = textDef.att.strike == "true";

		if ((xml.has.multiline && xml.att.multiline == "true")
			|| (textDef != null && textDef.has.multiline && textDef.att.multiline == "true")) {
			textfield.multiline = true;
			textfield.wordWrap = true;
			textfield.width = initWidth;

			if (!xml.has.fixHeight)
				textfield.autoSize = TextFieldAutoSize.LEFT; // TODO check language (arab => to the right)
		}

		if (!xml.has.width) {
			if (!textfield.multiline) {
				// don't use parent width, by default we will have a textfield that fit the text width if only one line
				useParentWidth = false;
				textfield.autoSize = TextFieldAutoSize.LEFT; // TODO check language (arab => to the right)

				if (format.align == "center") {
					usePercentX = true;
					initX = 0.5;
					pivotX = 0.5;
				}
			}
		}

		if (!xml.has.height) {
			useParentHeight = false;
			usePercentHeight = false;
			initHeight = 0;
		} else {
			_keepHeight = true;
			textfield.height = initHeight;
		}

		if (useParentHeight || usePercentHeight)
			_keepHeight = true;

		if (xml.has.text) {
			updateText(xml.att.text);
		} else if (xml.innerHTML != "") {
			updateText(xml.innerData);
		} else {
			updateText("");
		}
	}

	override public function preInit():Void {
		addChild(textfield);
	}

	override public function init():Void {
		if (useParentHeight) {
			textfield.height = parentHeight;
		} else if (usePercentHeight) {
			textfield.height = parentHeight * initHeight; // TOCHECK
		} else if (!_keepHeight) {
			textfield.height = textfield.textHeight + 4;
			initHeight = textfield.height;
		}

		if (useParentWidth) {
			textfield.width = parentWidth;
		} else if (usePercentWidth) {
			textfield.width = initWidth * parentWidth; // TOCHECK
		} else if (textfield.autoSize == TextFieldAutoSize.LEFT && !textfield.multiline) {
			initWidth = textfield.width; // alow to calculate x position
		} else {
			textfield.width = initWidth;
		}

		super.init();
	}

	/**
	 * Set a new text that will be parsed through TONGUE and VARIABLES
	 * @param	sourceText
	 * @return
	 */
	public function updateText(?sourceText:String):String {
		if (sourceText != null)
			this.sourceText = sourceText;

		var destText = sourceText;

		// translated text
		var tongue = GUI.TONGUE;
		if (tongue != null) {
			destText = TONGUE_VAR.map(destText, function(e) {
				var currentMatch = e.matched(0);
				return tongue.get(currentMatch.substring(1, currentMatch.length - 1), "interface", true);
			});
		} else if (destText.indexOf("{$") != -1) {
			trace("tongue is null and you try to use a localized text : " + destText);
		}
		// variable
		var _this = this;
		destText = GUI_VAR.map(destText, function(e) {
			var currentMatch = e.matched(0);
			// use binded variables
			var binder:BindedVariables;
			var variables = GUI._bindedVariables;
			if (variables.exists(currentMatch)) {
				binder = variables.get(currentMatch);
			} else {
				binder = new BindedVariables(currentMatch, "");
				variables.set(currentMatch, binder);
			}
			binder.registerTextField(_this);
			return binder.value;
		});

		this.text = destText;

		return destText;
	}

	public function set_text(v:String):String {
		textfield.htmlText = _upper ? v.toUpperCase() : v;

		#if flash
		if (_strike && v != "") { // TODO utiliser textLineMetrics http://community.openfl.org/t/textfield-how-i-get-char-bound/804/10
			var startPt:Point = new Point(textfield.getCharBoundaries(0).x, textfield.getCharBoundaries(0).y);
			var h:Float = textfield.getLineMetrics(0).height - textfield.getLineMetrics(0).leading;
			var _strikeShape = new Shape();
			_strikeShape.x = textfield.x;
			_strikeShape.y = textfield.y;
			_strikeShape.graphics.lineStyle(3);
			_strikeShape.graphics.moveTo(startPt.x, startPt.y + h / 2);
			_strikeShape.graphics.lineTo(startPt.x + textfield.textWidth, startPt.y + h / 2);
			addChild(_strikeShape);
		} else if (_strikeShape != null && _strikeShape.parent != null) {
			_strikeShape.parent.removeChild(_strikeShape);
		}
		#end

		// init();

		// dispatchResize();
		setDirty();

		return textfield.text;
	}

	public function get_text():String {
		return textfield.text;
	}

	public function set_textColor(v:UInt):UInt {
		textfield.textColor = v;
		textfield.text = textfield.text;
		return textfield.textColor;
	}

	public function get_textColor():UInt {
		return textfield.textColor;
	}

	override public function drawDebug(?color:Int):Void {
		#if debug
		if (!_debug) {
			this.graphics.beginFill(color != null ? color : _colorDebug, 0.10);
			this.graphics.drawRect(0, 0, textfield.width, textfield.height);
			this.graphics.endFill();
			this.addEventListener(MouseEvent.ROLL_OVER, onOverDebug);
			_debug = true;
		} else {
			this.graphics.clear();
			this.removeEventListener(MouseEvent.ROLL_OVER, onOverDebug);
			_debug = false;
		}
		#end
	}
}
