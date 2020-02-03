package gsui.interfaces;

/**
 * Implements this interface if you want gsui communicates with custom classes
 * @author Loudo
 */

interface IStateManager
{
		function changeState(state:String):Void;
		function getBackToPreviousState():Void;
		function isState(state:String):Bool;
}