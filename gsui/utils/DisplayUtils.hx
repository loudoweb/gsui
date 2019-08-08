package gsui.utils;
import openfl.display.DisplayObject;

/**
 * ...
 * @author loudo
 */
class DisplayUtils 
{

	/**
	 * Flip on x axis
	 * @param	display
	 */
	public static function flipX(display:DisplayObject):Void
	{
		display.scaleX = -1;
	}
	
	/**
	 * Flip on y axis
	 * @param	display
	 */
	public static function flipY(display:DisplayObject):Void
	{
		display.scaleY = -1;
	}
		/**
	 * Scale from a final width
	 * @param	display
	 * @param	finalWidth
	 */
	public static function scaleW(display:DisplayObject, finalWidth:Float):Void
	{
		display.scaleX = finalWidth / display.width;
		display.scaleY = finalWidth / display.width;
	}
	/**
	 * Scale from a final height
	 * @param	display
	 * @param	finalWidth
	 */
	public static function scaleH(display:DisplayObject, finalHeight:Float):Void
	{
		display.scaleX = finalHeight / display.height;
		display.scaleY = finalHeight / display.height;
	}
	
	/**
	 * Scale proportionally
	 * @param	display
	 * @param	finalScale
	 */
	public static function scale(display:DisplayObject, finalScale:Float):Void
	{
		display.scaleX = finalScale;
		display.scaleY = finalScale;
	}
	
}