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
		return Data.has.width ? getWidthValue(Data.att.width, ContainerW) : ContainerW;
	}
	
	public static function getHeight(Data:Fast, ContainerH:Float):Float
	{
		return Data.has.height ? getHeightValue(Data.att.height, ContainerH) : ContainerH;
	}
	
	inline static function getWidthValue(value:String, containerSize:Float):Float
	{
		if (value == "stage")
			return ResizeHelper.WIDTH;
		else 
			return getPercentValue(value, containerSize);
	}
	inline static function getHeightValue(value:String, containerSize:Float):Float
	{
		if (value == "stage")
			return ResizeHelper.HEIGHT;
		else 
			return getPercentValue(value, containerSize);
	}
	
	/**
	 * Get value based on a percentage of the container size (need explicit % in the string), default is in pixel.
	 * @param	value
	 * @param	containerSize
	 * @return	float position
	 */
	inline public static function getPercentValue(value:String, containerSize:Float):Float
	{
		if (hasPercent(value))
		{
			return containerSize * Std.parseFloat(value.substr(0, value.length - 1)) * 0.01;
		}else{
			return Std.parseFloat(value);
		}
	}
	
	inline public static function hasPercent(value:String):Bool
	{
		return value.indexOf("%") != -1;
	}
	
	public static function getColor(Data:Fast, attribute:String = "color", ?DefaultData:Fast):Int
	{
		var colorDef = null;
		if (Data.has.resolve(attribute))
		{
			colorDef = GUI._getDef(Data.att.resolve(attribute));
			return colorDef  != null ? parseColor(colorDef.att.value) : parseColor(Data.att.resolve(attribute));
			
			
		}else if (DefaultData != null && DefaultData.has.color) {
			
			colorDef = GUI._getDef(DefaultData.att.color);
			return colorDef  != null ? parseColor(colorDef.att.value) : parseColor(DefaultData.att.color);
		}
		return 0;
	}
	
	public static function getColorAlpha(Data:Fast, attribute:String = "color", ?DefaultData:Fast):Float
	{
		var colorDef = null;
		if (Data.has.resolve(attribute))
		{
			colorDef = GUI._getDef(Data.att.resolve(attribute));
			return colorDef  != null ? parseAlpha(colorDef) : parseAlpha(Data);
			
			
		}else if (DefaultData != null && DefaultData.has.color) {
			
			colorDef = GUI._getDef(DefaultData.att.color);
			return colorDef  != null ? parseAlpha(colorDef) : parseAlpha(DefaultData);
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
	
	public static function parseAlpha(Data:Fast):Float
	{
		return Data.has.alpha ? Std.parseFloat(Data.att.alpha) : 1;
	}
	
	inline public static function getAttInt(Data:Fast, att:String, defaultvalue:Int = 0):Int
	{
		if (Data.has.resolve(att))
		{
			var str = Data.att.resolve(att);
			return hasPercent(str) ? Std.parseInt(str.substr(0, str.length - 1)) : Std.parseInt(str);
		}else{
			return defaultvalue;
		}
	}
	/**
	 * If value contains %, it will return a float between 0 and 1. Otherwise, the value from the xml is just converted to a float.
	 * @param	Data
	 * @param	att
	 * @param	defaultvalue
	 * @return
	 */
	inline public static function getAttFloat(Data:Fast, att:String, defaultvalue:Float = 0):Float
	{
		if (Data.has.resolve(att))
		{
			var str = Data.att.resolve(att);
			return hasPercent(str) ? Std.parseFloat(str.substr(0, str.length - 1)) * 0.01 : Std.parseFloat(str);
		}else{
			return defaultvalue;
		}
	}
	
}