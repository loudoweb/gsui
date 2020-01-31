package gsui.utils;
import haxe.xml.Fast;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class XMLUtils 
{

	public static function getFirstChild(fast:Fast):Fast
	{
		var child = null;
		for (el in fast.elements)
		{
			child = el;
			break;
		}
		return child;
	}
	
}