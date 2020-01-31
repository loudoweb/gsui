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
	 * 
	 * @param	black
	 * @param	main default color
	 * @param	iMain opposite of default color
	 * @param	secondary other main color
	 * @param	red
	 * @param	green
	 * @param	blue
	 * @param	white
	 * @param	grey
	 */
	public static function initColor(main:String = "000000",
									iMain:String = "FFFFFF",
									secondary:String = "DEDEDE",
									red:String = "FF0000",
									green:String = "00FF00",
									blue:String = "0000FF",
									black:String = "000000",
									white:String = "FFFFFF",
									grey:String = "CCCCCC",
									pink:String = "DF5286"):Void
	{
		COLOR_TAG = new StringMap<String>();
		COLOR_TAG.set("black", black);
		COLOR_TAG.set("main", main);
		COLOR_TAG.set("iMain", iMain);
		COLOR_TAG.set("secondary", secondary);
		COLOR_TAG.set("red", red);
		COLOR_TAG.set("green", green);
		COLOR_TAG.set("blue", blue);
		COLOR_TAG.set("white", white);
		COLOR_TAG.set("grey", grey);
		COLOR_TAG.set("grey", pink);
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