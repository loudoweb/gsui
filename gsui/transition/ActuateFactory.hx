package gsui.transition;
import haxe.xml.Fast;
import gsui.transition.Transition;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class ActuateFactory implements ITransitionFactory 
{

	public function new() 
	{
		
	}
	
	
	/* INTERFACE gsui.transition.ITransitionFactory */
	
	public function create(xml:Fast):Transition 
	{
		return ActuateTransition.create(xml).parse(xml);
	}
	
}