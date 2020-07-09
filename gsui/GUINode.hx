package gsui;
import haxe.xml.Access;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * Allow to change state of sub elements of group
 * @author loudo
 */
class GUINode
{
	//TODO use Base here
	public var element:DisplayObject;
	public var state:Array<String>;
	public var zindex:Int;
	public var onIn:String;
	public var onOut:String;
	public var onHover:String;
	public var onUp:String;
	
	//TODO removed this after using Base
	public var width:String;
	public var height:String;
	
	//TODO find other solution instead of keeping this
	public var color:String;
	public var hoverColor:String;
	
	private inline static var DEFAULT:String = "";
	
	public function new(Element:DisplayObject, State:String = "", ?Data:Access) 
	{
		element = Element;
		
		zindex = Data.has.zindex ? Std.parseInt(Data.att.zindex) : 0;
		onIn = Data.has.onIn ? Data.att.onIn : "";
		onOut = Data.has.onOut ? Data.att.onOut : "";
		onHover = Data.has.onHover ? Data.att.onHover : "";
		onUp = Data.has.onUp ? Data.att.onUp : "";
		color = Data.has.color ? Data.att.color : "";
		hoverColor = Data.has.hoverColor ? Data.att.hoverColor : "";
		width = Data.has.width ? Data.att.width : "";
		height = Data.has.height ? Data.att.height : "";

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