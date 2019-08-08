package gsui;
import gsui.interfaces.ILayoutable;
import gsui.interfaces.IPositionUpdatable;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import haxe.xml.Fast;
#if debug
import gsui.interfaces.IDebuggable;
#end

/**
 * Group is a layer that can contain many elements and handle different custom states to update its content
 * @author loudo
 */
#if debug
class GUIGroup extends Sprite implements ILayoutable implements IDebuggable
#else
class GUIGroup extends Sprite implements ILayoutable
#end
{
	var _width:Float;
	var _height:Float;
	var _layout:String = "";//default relative
	public var isBackground:Bool = false;
	#if debug
	var _debug:Bool = false;
	#end
		
	var _nodes:Array<GUINode>;
	var _currentState:String = "";
	public var state(get, set):String;
	function get_state():String{ return _currentState; } 

	function set_state(value:String):String{ 
		_currentState = value;
		//CHILDS
		//remove everything but state == ""
		for (node in _nodes)
		{
			if(!node.isDefaultState()){
				if (node.element != null && node.element.parent != null) {
					node.element.parent.removeChild(node.element);
				}
			}
		}
		
		//add default (state == '') and current state
		for (node in _nodes)
		{
			if (node.hasState(value) || node.isDefaultState())
			{
				if (node.element != null) {
						addChild(node.element);
				}
			}
		}
		return _currentState;
	} 
	
	/**
	 * 
	 * @param	Data
	 * @param	ContainerW size of parent container
	 * @param	ContainerH size of parent container
	 */
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		_width = Data.has.width ? Std.parseFloat(Data.att.width) : ContainerW;
		_height = Data.has.height ? Std.parseFloat(Data.att.height) : ContainerH;
		isBackground = Data.has.background && Data.att.background == "true";
		
		name = Data.att.id;
		
		if (Data.has.mouseEnabled && Data.att.mouseEnabled == "false")
			this.mouseEnabled = this.mouseChildren = false;
		
		_nodes = GUI._parseXML(Data, _width, _height);
		
		state = "";
		
		if (Data.has.layout)
		{
			//update nodes x and y
			_layout = Data.att.layout;
			var gap:Float = Data.has.gap ? Std.parseFloat(Data.att.gap) : 0;
			var pWH:Float = 0;
			for (node in _nodes)
			{
				if (Std.is(node.element, ILayoutable))
				{
					if (_layout == "h")
					{
						
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setX(pWH);
						else
							node.element.x = pWH;
						pWH += node.element.width > 0 ? node.element.width + gap : (node.data.has.width ? Std.parseFloat(node.data.att.width) : 0) + gap;
					}
					else {//v
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setY(pWH);
						else
							node.element.y = pWH;
						pWH += node.element.height > 0 ? node.element.height + gap : (node.data.has.height ? Std.parseFloat(node.data.att.height) : 0) + gap;
					}
				}
			}
			//only if width and height not specified in xml
			//update width or height after layouting to permit good x and y placement for this
			if (_layout == "h")
			{
				_width = width;
			}else {
				_height = height;
			}
		}
		//update this x and y
		GUI._placeDisplay(Data, this, ContainerW, ContainerH, _width, _height);
	}
	
	public function removeFromParent():Void
	{
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	public function getIndex():Int
	{
		if (parent == null)
			return -1;
		return this.parent.getChildIndex(this);
	}
	
	public function getSlot(name:String):Slot
	{
		for (node in _nodes)
		{
			if (Std.is(node.element, Slot) && node.element.name == name) {
				return cast(node.element, Slot);
			}
		}
		return null;
	}
	
	/**
	 * //TODO cast inside this function
	 * @param	name .name (all child arbo) name (direct child) name.name (arbo)
	 * @return
	 */
	public function getChild(name:String):DisplayObject
	{
		var index:Int = name.indexOf(".");
		if (index == -1) {
			return getDirectChild(name);
		}else if (index == 0) {//TODO pas certain que ça soit la bonne méthode 31/07/2015
			for (node in _nodes)
			{
				var child:DisplayObject = getDirectChild(name.substring(1));
				if (child != null)
					return child;
				if (Std.is(node.element, GUIGroup)) {
					var group:GUIGroup = cast(node.element, GUIGroup);
					child = group.getChild(name);
					if (child != null)
						return child;
				}
			}
		}else {
			var splitName:Array<String> = name.split(".");
			var spr:Sprite = this;
			for (i in 0...splitName.length)
			{
				spr = cast (spr.getChildByName(splitName[i]), Sprite);
			}
			return spr;
		}
		return null;
	}
	private function getDirectChild(name:String):DisplayObject
	{
		for (node in _nodes)
		{
			if (node.element.name == name)
				return node.element;
		}
		return null;
	}
	@:generic public function getChildOf<T:DisplayObject>(name:String, type:Class<T>):T
	{
		for (node in _nodes)
		{
			if (node.element.name == name)
				return cast node.element;
		}
		return null;
	}
	@:generic public function getElementsOf<T:DisplayObject>(type:Class<T>):Array<T>
	{
		var elementsOfType:Array<T> = [];
		for (node in _nodes)
		{
			if (Std.is(node.element, type)) 
				elementsOfType.push(cast node.element);
		}
		return elementsOfType;
	}
	#if debug
	public function drawDebug():Void
	{
		trace('drawDebug');
		if (!_debug)
		{
			trace('drawDebug');
			this.graphics.beginFill(0x0000ff, 0.25);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			//no recursive for GuiGroup since all groups are stored in GUI for now
			for (node in _nodes)
			{
				if(Std.is(node.element, IDebuggable) && !Std.is(node.element, GUIGroup)){
					cast(node.element, IDebuggable).drawDebug();
				}
			}
			_debug = true;
		}else {
			this.graphics.clear();
			for (node in _nodes)
			{
				if(Std.is(node.element, IDebuggable) && !Std.is(node.element, GUIGroup)){
					cast(node.element, IDebuggable).drawDebug();
				}
			}
			_debug = false;
		}
	}
	#end
}