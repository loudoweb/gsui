package gsui.utils;
import haxe.xml.Fast;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class ParserUtils 
{

	public static function getWidth(Data:Fast, ContainerW:Float):Float
	{
		return Data.has.width ? getSizeValue(Data.att.width, ContainerW) : ContainerW;
	}
	
	public static function getHeight(Data:Fast, ContainerH:Float):Float
	{
		return Data.has.height ? getSizeValue(Data.att.height, ContainerH) : ContainerH;
	}
	
	public static function getSizeValue(size:String, containerSize:Float):Float
	{
		if (size.indexOf("%") != -1)
		{
			return containerSize * Std.parseFloat(size.substr(0, size.length - 1)) * 0.01;
		}else{
			return Std.parseFloat(size);
		}
	}
	
	public static function getColor(Data:Fast, ?DefaultData:Fast):Int
	{
		var colorDef = null;
		if (Data.has.color)
		{
			colorDef = GUI._getDef(Data.att.color);
			return colorDef  != null ? parseColor(colorDef.att.value) : parseColor(Data.att.color);
			
			
		}else if (DefaultData != null && DefaultData.has.color) {
			
			colorDef = GUI._getDef(DefaultData.att.color);
			return colorDef  != null ? parseColor(colorDef.att.value) : parseColor(DefaultData.att.color);
		}
		return 0;
	}
	
	public static function parseColor(str:String):Int
	{
		str = StringTools.replace(str, "#", "0x");
		if (str.indexOf("0x") != 0)
			str = "0x" + str;
		return Std.parseInt(str);
	}
	
	public static function getAtt(Data:Fast, att:String, defaultvalue:Int = 0):Int
	{
		return Data.has.resolve(att) ? Std.parseInt(Data.att.resolve(att)) : defaultvalue;
	}
	
}