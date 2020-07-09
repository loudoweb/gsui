package gsui.utils;
import haxe.xml.Access;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class XMLUtils 
{

	inline public static function getFirstChild(xml:Access):Access
	{
		var child = null;
		for (el in xml.elements)
		{
			child = el;
			break;
		}
		return child;
	}
	
}