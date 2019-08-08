package gsui.utils;
import openfl.display.DisplayObject;
import openfl.display.Sprite;//needed for children

typedef Display = {
	var x:Float;
	var y:Float;
	var scaleX:Float;
	var scaleY:Float;
	var width:Float;
	var height:Float;
	var parent:Display;
}
/**
 * ...
 * @author loudo (Ludovic Bas)
 */
class AlignUtils 
{

	/**
	 * Center Horizontally from a width
	 * @param	display
	 * @param	width
	 */
	public static function centerX(display:DisplayObject, width:Float):Void
	{
		display.x = (width - display.width) / 2;
	}
	/**
	 * Center Vertically from a height
	 * @param	display
	 * @param	height
	 */
	public static function centerY(display:DisplayObject, height:Float):Void
	{
		display.y = (height - display.height) / 2;
	}
	/**
	 * Center Vertically and Horizontally from set values
	 * @param	display
	 * @param	width
	 * @param	height
	 */
	public static function center(display:DisplayObject, width:Float, height:Float):Void
	{
		centerX(display, height);
		centerY(display, width);
	}
	/**
	 * Center from parent height
	 * @param	display
	 */
	public static function centerXFromParent(display:DisplayObject):Void
	{
		if (display.parent == null)
			return;
			
		var parent = display.parent;
		
		display.x = (parent.width - display.width) / 2;
	}
	/**
	 * Center from parent width
	 * @param	display
	 */
	public static function centerYFromParent(display:DisplayObject):Void
	{
		if (display.parent == null)
			return;
			
		var parent = display.parent;
		
		display.y = (parent.height - display.height) / 2;
	}
	/**
	 * Center from parent size
	 * @param	display
	 */
	public static function centerFromParent(display:DisplayObject):Void
	{
		if (display.parent == null)
			return;
			
		var parent = display.parent;
		
		display.y = (parent.height - display.height) / 2;
		display.x = (parent.width - display.width) / 2;
	}
	/**
	 * Align content vertically
	 * @param	display
	 */
	public static function centerYContent(display:Sprite):Void
	{
		var _size = display.height;
		
		var child:DisplayObject;
		for (i in 0...display.numChildren)
		{
			child = display.getChildAt(i);
			child.y = (_size - child.height) / 2;
		}
	}
	/**
	 * Align content horizontally
	 * @param	display
	 */
	public static function centerXContent(display:Sprite):Void
	{
		var _size = display.height;
		
		var child:DisplayObject;
		for (i in 0...display.numChildren)
		{
			child = display.getChildAt(i);
			child.x = (_size - child.width) / 2;
		}
	}
	
	/**
	 * Space equally every child on x axis
	 * @param	display container
	 * @param	totalWidth
	 */
	public static function spaceXContent(display:Sprite, totalWidth:Float ):Void
	{
		var totalContentW:Float = 0;
		for (i in 0...display.numChildren)
		{
			totalContentW += display.getChildAt(i).width;
		}
		
		if (totalWidth < totalContentW)
			totalWidth = totalContentW;
			
		var gap = (totalWidth - totalContentW) / (display.numChildren - 1);
		var addedW:Float = 0;
		var child:DisplayObject;
		for (i in 0...display.numChildren)
		{
			child = display.getChildAt(i);
			child.x = addedW + i * gap;
			addedW += child.width;
		}
	}
	
	/**
	 * Space equally every child on y axis
	 * @param	display container
	 * @param	totalHeight
	 */
	public static function spaceYContent(display:Sprite, totalHeight:Float):Void
	{
		var totalContentH:Float = 0;
		for (i in 0...display.numChildren)
		{
			totalContentH += display.getChildAt(i).height;
		}
		
		if (totalHeight < totalContentH)
			totalHeight = totalContentH;
			
		var gap = (totalHeight - totalContentH) / (display.numChildren - 1);
		var addedH:Float = 0;
		var child:DisplayObject;
		for (i in 0...display.numChildren)
		{
			child = display.getChildAt(i);
			child.y = addedH + i * gap;
			addedH += child.height;
		}
	}
	
}