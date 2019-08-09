package gsui;
import openfl.display.Sprite;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import haxe.xml.Fast;
import openfl.Assets;
import openfl.display.Shape;
import openfl.geom.Point;
#if debug
import gsui.interfaces.IDebuggable;
#end

/**
 * Textfield
 * TODO : inherits from textfield directly ?
 * @author loudo
 */
#if debug
class GUITextField extends Sprite implements IDebuggable
#else
class GUITextField extends Sprite
#end
{
	@:isVar public var text(get, set):String;
	@:isVar public var textColor(get, set):UInt;
	var _textfield:TextField;
	var _upper:Bool;
	var _containerW:Float;
	var _containerH:Float;
	var _positions:ElementPosition;
	var _data:Fast;
	var _strike:Bool = false;
	var _strikeShape:Shape;
	#if debug
	var _debug:Bool = false;
	#end
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		
		_upper = Data.has.upper && Data.att.upper == "true";
		_containerW = ContainerW;
		_containerH = ContainerH;
		_data = Data;
		
		var font:Font = null;
		_textfield = new TextField();
		_textfield.embedFonts = true;
		
		
		if (Data.has.id){
			_textfield.name = Data.att.id;
			name = Data.att.id;
		}
		
		var textDef:Fast = GUI._getDef(Data.att.font);
		
		
		if (textDef == null)
		{
			textDef = GUI._getDef("defaultFont");
		}
		
		if (textDef != null && Assets.exists("fonts/" + textDef.att.font + ".ttf"))
		{
			font = Assets.getFont("fonts/" + textDef.att.font + ".ttf");
		}
		
		if (Assets.exists("fonts/" + Data.att.font + ".ttf"))
		{
			font = Assets.getFont("fonts/" + Data.att.font + ".ttf");
		}
		
		
		
		var size = Data.has.size ? Std.parseInt(Data.att.size) : (textDef.has.size ? Std.parseInt(textDef.att.size) : 20);
		var color = Data.has.color ? Std.parseInt(Data.att.color) : (textDef.has.color ? Std.parseInt(textDef.att.color) : 0);
		
		
		var format:TextFormat = new TextFormat (font.fontName, size, color );
		
		
		if (Data.has.align)
			format.align = Data.att.align; 
		else if(textDef != null && textDef.has.align)
			format.align = textDef.att.align; 
			
		if (Data.has.bold)
			format.bold = Std.string(Data.att.bold) == "true"; 
		else if(textDef != null && textDef.has.bold)
			format.bold = Std.string(textDef.att.bold) == "true"; 
		
		_textfield.defaultTextFormat = format;
		
		if (Data.has.input && Data.att.input == "true") {
			_textfield.type = TextFieldType.INPUT;
			_textfield.selectable = true;
		}else if (textDef != null && textDef.has.input && textDef.att.input == "true") {
			_textfield.type = TextFieldType.INPUT;
			_textfield.selectable = true;
		}else {
			_textfield.selectable = false;
		}
		if (Data.has.width) {
			_textfield.width = Std.string(Data.att.width) == "" ? _containerW : Std.parseFloat(Data.att.width);
		}else if (textDef != null && textDef.has.width) {
			_textfield.width = Std.string(textDef.att.width) == "" ? _containerW : Std.parseFloat(textDef.att.width);
		}else {
			_textfield.autoSize = TextFieldAutoSize.LEFT;//TODO check language (arab => to the right)
		}
		
		if (Data.has.height)
			_textfield.height = Std.parseFloat(Data.att.height);
		else if (textDef != null && textDef.has.height)
			_textfield.height = Std.parseFloat(textDef.att.height);
			
		if ((Data.has.multiline && Data.att.multiline == "true") || (textDef != null && textDef.has.multiline && textDef.att.multiline == "true")){
			_textfield.multiline = true;
			_textfield.wordWrap = true;
			_textfield.autoSize = TextFieldAutoSize.LEFT;
		}
		
		if(Data.has.maxChars)
			_textfield.maxChars = Std.parseInt(Data.att.maxChars);
		else if(textDef != null && textDef.has.maxChars)
			_textfield.maxChars = Std.parseInt(textDef.att.maxChars);
			
		if (Data.has.a)//TODO r instead?
			_textfield.rotation = Std.parseFloat(Std.string(Data.att.a));
		else if (textDef != null && textDef.has.a)
			_textfield.rotation = Std.parseFloat(Std.string(textDef.att.a));
			
		if (Data.has.strike)
			_strike = Data.att.strike == "true";
		else if (textDef != null && textDef.has.strike)
			_strike = textDef.att.strike == "true";
		
		addChild(_textfield);
	}
	public function set_text(v:String):String
	{	
		_textfield.htmlText = _upper ? v.toUpperCase() : v;
		_positions = new ElementPosition(_data, _containerW, _containerH, _textfield.width, _textfield.textHeight);
		x = _positions.x;
		y = _positions.y;
		#if flash
		if (_strike && v != "") {//TODO utiliser textLineMetrics http://community.openfl.org/t/textfield-how-i-get-char-bound/804/10
			var startPt:Point=new Point(_textfield.getCharBoundaries(0).x,_textfield.getCharBoundaries(0).y);
			var h:Float=_textfield.getLineMetrics(0).height-_textfield.getLineMetrics(0).leading;
			var _strikeShape:Shape=new Shape();
			_strikeShape.x=_textfield.x;
			_strikeShape.y=_textfield.y;
			_strikeShape.graphics.lineStyle(3);
			_strikeShape.graphics.moveTo(startPt.x,startPt.y+h/2);
			_strikeShape.graphics.lineTo(startPt.x + _textfield.textWidth, startPt.y + h / 2);
			addChild(_strikeShape);
		}else if (_strikeShape != null && _strikeShape.parent != null){
				_strikeShape.parent.removeChild(_strikeShape);
		}
		#end
		return _textfield.text;
	}
	public function get_text():String
	{
		return _textfield.text;
	}
	public function set_textColor(v:UInt):UInt
	{
		_textfield.textColor = v;
		_textfield.text = _textfield.text;
		return _textfield.textColor;
	}
	public function get_textColor():UInt
	{
		return _textfield.textColor;
	}
	#if debug
	public function drawDebug():Void
	{
		if (!_debug)
		{
			_textfield.background = true;
			_textfield.backgroundColor = 0xff0000;
			_debug = true;
		}
		else {
			_textfield.background = false;
			_debug = false;
		}
	}
	#end
}