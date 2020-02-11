package gsui.display;
import gsui.interfaces.IPositionUpdatable;
import gsui.utils.XMLUtils;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import haxe.xml.Fast;
#if debug
import gsui.interfaces.IDebuggable;
import openfl.events.MouseEvent;
#end

enum ELayout
{
	VERTICAL;
	HORIZONTAL;
}
/**
 * Group is a layer that can contain many elements and handle different custom states to update its content
 * @author loudo
 */
#if debug
class GUIGroup extends Sprite implements IDebuggable
#else
class GUIGroup extends Sprite
#end
{
	var _width:Float;
	var _height:Float;
	var _layout:ELayout;//default relative
	var _gap:Float;
	
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
	 * @param	layout default is absolute placement
	 */
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		_width = Data.has.width ? Std.parseFloat(Data.att.width) : ContainerW;
		_height = Data.has.height ? Std.parseFloat(Data.att.height) : ContainerH;
		
		if (Data.has.size && Data.att.size == "firstChild")
		{
			_width = Std.parseFloat(XMLUtils.getFirstChild(Data).att.width);
			_height = Std.parseFloat(XMLUtils.getFirstChild(Data).att.height);
		}
		
		isBackground = Data.has.background && Data.att.background == "true";
		
		name = Data.att.id;
		
		if (Data.has.mouseEnabled && Data.att.mouseEnabled == "false")
			this.mouseEnabled = this.mouseChildren = false;
		
		_nodes = GUI._parseXML(Data, _width, _height);
		
		state = "";
				
		switch(Data.name)
		{
			case "boxV":
			_layout = VERTICAL;
			case "boxH":
			_layout = HORIZONTAL;
		}
		
		if (_layout != null)
		{
			//update nodes x and y
			_gap = Data.has.gap ? Std.parseFloat(Data.att.gap) : 0;
			var pWH:Float = 0;
			for (node in _nodes)
			{
				
				switch(_layout)
				{
					case HORIZONTAL:
						if (	Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setX(pWH);
						else
							node.element.x = pWH;
						pWH += node.element.width > 0 ? node.element.width + _gap : (node.data.has.width ? Std.parseFloat(node.data.att.width) : 0) + _gap;
					case VERTICAL:
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setY(pWH);
						else
							node.element.y = pWH;
						pWH += node.element.height > 0 ? node.element.height + _gap : (node.data.has.height ? Std.parseFloat(node.data.att.height) : 0) + _gap;
						
				}
				
			}
			//only if width and height not specified in xml
			//update width or height after layouting to permit good x and y placement for this
			switch(_layout)
			{
				case HORIZONTAL:
					_width = width;
				case VERTICAL:
					_height = height;
			}
		}
		//update this x and y
		GUI._placeDisplay(Data, this, ContainerW, ContainerH, _width, _height);

	}
	
	public function onInvalidate():Void
	{
		//TODO iterate nodes and update everything
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
	 * Get child through display list
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
	/**
	 * Get direct child of certain name
	 * @param	name
	 * @return
	 */
	private function getDirectChild(name:String):DisplayObject
	{
		for (node in _nodes)
		{
			if (node.element.name == name)
				return node.element;
		}
		return null;
	}
	/**
	 * Get direct child of certain name and type T.
	 * //old name : getChildOf
	 */
	@:generic public function getChildByType<T:DisplayObject>(name:String, type:Class<T>):T
	{
		for (node in _nodes)
		{
			if (node.element.name == name)
				return cast node.element;
		}
		return null;
	}
	/**
	 * Find all direct children of type T
	 * old name : getElementsOf
	 */
	@:generic public function getChildrenByType<T:DisplayObject>(type:Class<T>):Array<T>
	{
		var elementsOfType:Array<T> = [];
		for (node in _nodes)
		{
			if (Std.is(node.element, type)) 
				elementsOfType.push(cast node.element);
		}
		return elementsOfType;
	}
	/**
	 * Find all elements of type T in all display list
	 */
	public function getElementsByType<T:DisplayObject>(type:Class<T>, ?arr:Array<T> ):Array<T>
	{
		if (arr == null)
			arr = [];
			
		for (node in _nodes)
		{
			if (Std.is(node.element, type))
			{
				arr.push(cast node.element);
			}
			if (Std.is(node.element, GUIGroup)) {
				var group:GUIGroup = cast node.element;
				group.getElementsByType(type, arr);
			}
		}
		return arr;
	}
	#if debug
	public function drawDebug():Void
	{
		if (!_debug)
		{
			trace('drawDebug');
			this.graphics.beginFill(0x0000ff, 0.10);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			this.addEventListener(MouseEvent.ROLL_OVER, onOverDebug);
			//no recursive for GuiGroup since all groups are stored in GUI for now
			for (node in _nodes)
			{
				if(Std.is(node.element, IDebuggable)){
					cast(node.element, IDebuggable).drawDebug();
				}
			}
			_debug = true;
		}else {
			this.graphics.clear();
			this.removeEventListener(MouseEvent.ROLL_OVER, onOverDebug);
			for (node in _nodes)
			{
				if(Std.is(node.element, IDebuggable)){
					cast(node.element, IDebuggable).drawDebug();
				}
			}
			_debug = false;
		}
	}
	function onOverDebug(e:MouseEvent):Void
	{
		trace('over $name');
	}
	#end
}