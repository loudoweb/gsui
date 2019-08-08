package gsui.interfaces;

/**
 * @author loudo
 */
interface ILayoutable 
{
	#if flash
	public var x:Float;
	public var y:Float;
	#else
	public var x(get,set):Float;
	public var y(get, set):Float;
	#end
}