package gsui.utils;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.geom.Rectangle;
import openfl.Lib;

/**
 * TODO ???
 * @author Loudo
 */
class GUIUtils
{

	public function new() 
	{
		
	}
	public static function createMask(display:DisplayObject, rect: Rectangle):Void {
		/*if(rect != null)
			display.scrollRect = rect;*/
		/*if (rect != null) {
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x00ff00);
			mask.graphics.drawRect(0, 0, rect.width, rect.height);
			//display.parent.addChild(mask);
			Lib.current.stage.addChild(mask);
			display.mask = mask;
		}*/
	}
	public static function changeMask(display:DisplayObject, rect: Rectangle):Void {
		/*if(rect != null)
			display.scrollRect = rect;*/
		/*if (rect != null) {
			var mask:Shape = display.mask != null ? display.mask : new Shape();
			mask.graphics.beginFill(0x00ff00);
			mask.graphics.drawRect(0, 0, rect.width, rect.height);
			//display.parent.addChild(mask);
			Lib.current.stage.addChild(mask);
			display.mask = mask;
		}*/
	}
	
}