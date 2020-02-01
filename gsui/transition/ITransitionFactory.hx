package gsui.transition;
import haxe.xml.Fast;

/**
 * @author Ludovic Bas - www.lugludum.com
 */
interface ITransitionFactory 
{
	public function create(xml:Fast):Transition;
}