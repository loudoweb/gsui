package gsui.utils;
import openfl.display.Graphics;

/**
 * Helper to create shapes
 * @author loudo
 */
class GraphicsUtils 
{

	public static function drawRectFill(graphics:Graphics, width:Float, height:Float, color:Int = 0xff0000, alpha:Float = 1):Void
	{
		graphics.beginFill(color, alpha);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();
	}
	public static function drawRect(graphics:Graphics, width:Float, height:Float, color:Int = 0xff0000, stroke:Int = 1, alpha:Float = 1):Void
	{
		graphics.lineStyle(stroke, color, alpha);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();
	}
	public static function drawCircleFill(graphics:Graphics, diameter:Float, color:Int = 0xff0000, alpha:Float = 1):Void
	{
		graphics.beginFill(color, alpha);
		graphics.drawCircle(0, 0, diameter * 0.5);
		graphics.endFill();
	}
	public static function drawCircle(graphics:Graphics, diameter:Float, color:Int = 0xff0000, stroke:Int = 1, alpha:Float = 1):Void
	{
		graphics.lineStyle(stroke, color, alpha);
		graphics.drawCircle(0, 0, diameter * 0.5);
		graphics.endFill();
	}
	
}