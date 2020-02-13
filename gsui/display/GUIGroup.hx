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
import openfl.events.Event;

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
class GUIGroup extends Base implements IDebuggable
#else
class GUIGroup extends Base
#end
{
	var _layout:ELayout;//default absolute
	var _gap:Float;//use width/height set in xml or parent
	var _isAuto:Bool;//auto layout after creating nodes
	
	public var isBackground:Bool = false;
	#if debug
	var _debug:Bool = false;
	#end
	
	/**
	 * All nodes in the order of the xml (this is the order used to keep the layout from the xml)
	 */
	var _nodes:Array<GUINode>;
	/**
	 * All nodes in the order of zindex if any
	 */
	var _nodesIndexed:Array<Int>;
	
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
					if (node.onOut != "")
					{
						var i = 0;
						for (onOut in node.onOut.split(","))
						{
							GUI.getTransition(onOut).start(node.element, i == 0 ? function() {node.element.parent.removeChild(node.element); } : null);
							i++;
						}
						
					}else{
						node.element.parent.removeChild(node.element);
					}
				}
			}
		}
		
		//add default (state == '') and current state
		var node;
		for (i in 0..._nodesIndexed.length)
		{
			node = _nodes[_nodesIndexed[i]];
			if (node.hasState(value) || node.isDefaultState())
			{
				if (node.element != null) {
						addChild(node.element);
						
						if (node.onIn != "")
						{
							for (onIn in node.onIn.split(","))
							{
								GUI.getTransition(onIn).start(node.element);
							}
						}
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
		super(Data, ContainerW, ContainerH);
	
	}
	
	override function parse(xml:Fast):Void 
	{
		super.parse(xml);
		
		if (xml.has.size && xml.att.size == "firstChild")
		{
			initWidth = Std.parseFloat(XMLUtils.getFirstChild(xml).att.width);
			initHeight = Std.parseFloat(XMLUtils.getFirstChild(xml).att.height);
		}
		
		isBackground = xml.has.background && xml.att.background == "true";
				
		if (xml.has.mouseEnabled && xml.att.mouseEnabled == "false")
			this.mouseEnabled = this.mouseChildren = false;
			
		_gap = xml.has.gap ? Std.parseFloat(xml.att.gap) : 0;
		_isAuto = xml.has.auto && xml.att.auto == "true";
		
		_nodes = GUI._parseXML(xml, initWidth, initHeight);
		
		_nodesIndexed = [for (i in 0..._nodes.length) i];
		_nodesIndexed.sort(function(a:Int, b:Int) {
			if (_nodes[a].zindex < _nodes[b].zindex)
				return -1
			else if (_nodes[a].zindex > _nodes[b].zindex)
				return 1;
			return 0;
		});
		
		switch(xml.name)
		{
			case "boxV":
			_layout = VERTICAL;
			case "boxH":
			_layout = HORIZONTAL;
		}
	}
	
	override public function preInit():Void 
	{
		state = "";
	}
	
	override public function init():Void 
	{
		
		if (_layout != null)
		{
			//update nodes x and y
			
			var pWH:Float = 0;
			for (node in _nodes)
			{
				
				switch(_layout)
				{
					case HORIZONTAL:
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setX(pWH);
						else if (Std.is(node.element, Base)){
							cast(node.element, Base).initX = pWH;
							cast(node.element, Base).init();
						}
						else
							node.element.x = pWH;
						pWH += node.element.width > 0 ? node.element.width + _gap : (node.width != "" ? Std.parseFloat(node.width) : 0) + _gap;
					case VERTICAL:
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setY(pWH);
						else if (Std.is(node.element, Base))
						{
							
							cast(node.element, Base).initY = pWH;
							cast(node.element, Base).init();
						}
						else
							node.element.y = pWH;
						pWH += node.element.height > 0 ? node.element.height + _gap : (node.height != "" ? Std.parseFloat(node.height) : 0) + _gap;
						
				}
				
			}
			//only if width and height not specified in xml
			//update width or height after layouting to permit good x and y placement for this
			switch(_layout)
			{
				case HORIZONTAL:
					initWidth = width;
				case VERTICAL:
					initHeight = height;
			}
			dispatchResize();
			
		}
		//update this x and y
		//GUI._placeDisplay(Data, this, ContainerW, ContainerH, initWidth, initHeight);
		
		super.init();
	}
	
	function onChildResize(e:Event):Void
	{
		var pWH:Float = 0;
		
		for (node in _nodes)
		{
			
			switch(_layout)
			{
				case HORIZONTAL:
					if (Std.is(node.element, IPositionUpdatable))
						cast(node.element, IPositionUpdatable).setX(pWH);
					else
						node.element.x = pWH;
					pWH += node.element.width > 0 ? node.element.width + _gap : (node.width != "" ? Std.parseFloat(node.width) : 0) + _gap;
				case VERTICAL:
					if (Std.is(node.element, IPositionUpdatable))
						cast(node.element, IPositionUpdatable).setY(pWH);
					else
						node.element.y = pWH;
					pWH += node.element.height > 0 ? node.element.height + _gap : (node.height != "" ? Std.parseFloat(node.height) : 0) + _gap;
					
			}
			
		}
		//only if width and height not specified in xml
		//update width or height after layouting to permit good x and y placement for this
		switch(_layout)
		{
			case HORIZONTAL:
				initWidth = width;
			case VERTICAL:
				initHeight = height;
		}
		
		//update this x and y
		//TODO use AlignUtils instead of ...
		//GUI._placeDisplay(Data, this, ContainerW, ContainerH, initWidth, initHeight);
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