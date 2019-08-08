package gsui.utils;
import openfl.display.Sprite;

/**
 * ...
 * @author loudo
 */
class GraphicsUtils 
{

	public static function drawRect(display:Sprite, width:Float, height:Float, color:Int = 0xff0000):Void
	{
		display.graphics.beginFill(color);
		display.graphics.drawRect(0, 0, width, height);
		display.graphics.endFill();
	}
	
}