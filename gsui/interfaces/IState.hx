package gsui.interfaces;

/**
 * @author Ludovic Bas - www.lugludum.com
 */
interface IState 
{
	function update(time:Float):Void;
	function onAdded():Void;
	function onRemoved():Void;
}