package gsui.transition;
import haxe.xml.Access;

/**
 * @author Ludovic Bas - www.lugludum.com
 */
interface ITransitionFactory 
{
	public function create(xml:Access):Transition;
}