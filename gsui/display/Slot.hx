package gsui.display;

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
	public function destroy():Void
	{
		removeAll();
	}
	
}