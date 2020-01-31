package gsui.utils;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;

/**
 * Helper to create mask
 * @author Loudo
 */
class MaskUtils
{

	public static function createMask(display:DisplayObject, rect: Rectangle):Void {
		if(rect != null)
			display.scrollRect = rect;
	}
	
}