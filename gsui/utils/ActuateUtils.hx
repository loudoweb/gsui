package gsui.utils;
import motion.Actuate;
import openfl.display.DisplayObject;

/**
 * Utils for Actuate animations
 * @author loudo
 */
class ActuateUtils 
{

	/**
	 * Anim when button clicked
	 * @param	display
	 */
	public static function animClick(display:DisplayObject, duration:Float = 0.25, scale:Float = 0.9):Void
	{
		Actuate.tween(display, duration, { scaleX : scale, scaleY: scale} ).onComplete(resetScale, [display]);		
	}
	/**
	 * Reset Scale
	 * @param	display
	 */
	static function resetScale(display:DisplayObject):Void
	{
		display.scaleX = 1;
		display.scaleY = 1;
	}
	
}