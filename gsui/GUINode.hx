package gsui;
import haxe.xml.Fast;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * Allow to change state of sub elements of group
 * @author loudo
 */
class GUINode
{
	public var element:DisplayObject;
	public var state:Array<String>;
	public var data:Fast;
	
	private inline static var DEFAULT:String = "";
	
	public function new(Element:DisplayObject, State:String = "", ?Data:Fast) 
	{
		element = Element;
		data = Data;
		
		state = parseState(State);
	}
	
	private function parseState(State:String):Array<String>
	{
		return State.split(",");
	}
	
	/**
	 * 
	 * @param	State
	 * @return
	 */
	public function hasState(State:String):Bool
	{
		if (State == DEFAULT)
			return state[0] == DEFAULT;
		if (State.indexOf(",") != -1)
		{
			var check = false;
			for (s in State.split(","))
			{
				if (state.indexOf(s) != -1)
					return true;
			}
			return false;
		}
		return state.indexOf(State) != -1;
		
	}
	
	public function isDefaultState():Bool
	{
		return state[0] == DEFAULT;
	}
	
}