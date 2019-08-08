package gsui.utils;
import haxe.ds.StringMap;
using StringTools;

/**
 * ...
 * @author loudo
 */
class TextUtils 
{
	static var nbsp:EReg = ~/ ([:?!]+)/gi;
	public static var COLOR_TAG:StringMap<String>;
	/**
	 * Init color
	 */
	public static function initColor():Void
	{
		COLOR_TAG = new StringMap<String>();
		COLOR_TAG.set("black", "000000");
		COLOR_TAG.set("red", "ff0000");
		COLOR_TAG.set("green", "00ff00");
		COLOR_TAG.set("blue", "0000ff");
		COLOR_TAG.set("white", "ffffff");
		COLOR_TAG.set("ping", "DF5286");
	}
	
	/**
	 * Replace standard space by non-breaking space before : ? !
	 * @usage	french language at least prefers using non breaking white space before those characters.
	 * @param	txt
	 * @return
	 */
	public static function replaceByNbsp(txt:String):String
	{
		return nbsp.replace(txt, " $1");		
	}
	
	/**
	 * Replace custom xml tag with color
	 * @see initColor()
	 * @param	txt
	 * @return
	 */
	public static function replaceColor(txt:String):String
	{
		for (color in COLOR_TAG.keys())
		{
			txt = txt.replace('<$color>', '<font color="#${COLOR_TAG.get(color)}">');
			txt = txt.replace('</$color>', '</font>');
		}
		return txt;
		
	}
	
}