package gsui.display;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;

/**
 * Place Holder for whatever you want
 * @author loudo
 */
class Slot extends Sprite
{

	public function new() 
	{
		super();
		
	}
	
	public function removeAll():Void
	{
		removeChildren();
		/*for (i in 0...numChildren)
		{
			removeChildAt(i);
		}*/
		
	}
	
	public function addImage(name:String):Void
	{
		//TODO Bitmap OR Atlas
		addChild(new Bitmap(Assets.getBitmapData(name), PixelSnapping.AUTO, true));
	}
	
	public function destroy():Void
	{
		removeAll();
	}
	
}