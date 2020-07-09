package gsui.display;
import gsui.BindedVariables;
import gsui.interfaces.IPositionUpdatable;
import gsui.utils.XMLUtils;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import haxe.xml.Access;
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

class GUIGroup extends Base
{
	public var isBackground:Bool = false;
	
	public var state(get, set):String;
	
	var _layout:ELayout;//default absolute
	/**
	 * Distance between children.
	 * Use width/height set in xml or parent.
	 * Auto (value of -1) means that children will take all the width or height of the group.
	 * @default 0
	 */
	var _gap:Float;
	
	var _isInit:Bool;
	
	/**
	 * All nodes in the order of the xml (this is the order used to keep the layout from the xml)
	 */
	var _nodes:Array<GUINode>;
	/**
	 * All nodes in the order of zindex if any
	 */
	var _nodesIndexed:Array<Int>;
	
	var _currentState:String = "";
	
	
	
	function get_state():String{ return _currentState; } 

	function set_state(value:String):String{ 
		_currentState = value;
		//CHILDS
		//remove everything but state == ""
		for (node in _nodes)
		{
			if(!node.isDefaultState()){
				if (node.element != null && node.element.parent != null) {
					
					/*if (Std.is(node.element, Base))
					{
						cast(node.element, Base).onResize.remove(onChildResize);
					}*/
					
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
						
						/*if (Std.is(node.element, Base))
						{
							cast(node.element, Base).onResize.add(onChildResize);
						}*/
						
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
		//guard to avoid calling init() twice when Group is instanciated
		if(_isInit)
			setDirty();
		_isInit = true;
		//dispatchResize();
		return _currentState;
	} 
	
	/**
	 * 
	 * @param	Data
	 * @param	ContainerW size of parent container
	 * @param	ContainerH size of parent container
	 * @param	layout default is absolute placement
	 */
	public function new(Data:Access, ContainerW:Float, ContainerH:Float) 
	{
		_isInit = false;
		super(Data, ContainerW, ContainerH);
	
	}
	
	override function parse(xml:Access):Void 
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
			
		_gap = xml.has.gap ? (xml.att.gap == "auto" ? -1 : Std.parseFloat(xml.att.gap)) : 0;
		
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
		
		
		if (xml.has.currentState)
		{
			if (xml.att.currentState.indexOf("{") != -1)
			{
				var variables = GUI._bindedVariables;
				var binder:BindedVariables;
				if (variables.exists(xml.att.currentState))
				{
					binder = variables.get(xml.att.currentState);
					_currentState = binder.value;
				}else {
					binder = new BindedVariables(xml.att.currentState, "");
					variables.set(xml.att.currentState, binder);
					_currentState = "";
				}
				binder.registerGroup(this);
				
			}else{
				_currentState = xml.att.currentState; 
			}
		}else{
			_currentState = ""; 
		}
		
	}
	
	override public function preInit():Void 
	{
		state = _currentState;
	}
	
	override public function init():Void 
	{
		var oldWidth = width;
		var oldHeight = height;
		
		if (_layout != null)
		{
			
			//check total space to compare with wanted space for auto gap
			var totalSpace = 0.0;
			if (_gap == -1)
			{
				
				for (node in _nodes)
				{
					
					switch(_layout)
					{
						case HORIZONTAL:
							
							totalSpace += node.element.width;
						case VERTICAL:
							totalSpace += node.element.height;
							
					}
					
				}
			}
			
			//update nodes x and y
			var pWH:Float = 0;
			var gap = 0.0;
			
			switch(_layout)
			{
				case HORIZONTAL:
					
					gap = _gap == -1 ? (initWidth - totalSpace) / _nodes.length : _gap;
					
					for (node in _nodes)
					{
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setX(pWH);
						else if (Std.is(node.element, Base)){
							cast(node.element, Base).initX = pWH;
							cast(node.element, Base).init();
						}
						else
							node.element.x = pWH;
						pWH += node.element.width > 0 ? node.element.width + gap : (node.width != "" ? Std.parseFloat(node.width) : 0) + gap;
					}
				case VERTICAL:
					
					gap = _gap == -1 ? (initHeight - totalSpace) / _nodes.length : _gap;
					
					for (node in _nodes)
					{
						if (Std.is(node.element, IPositionUpdatable))
							cast(node.element, IPositionUpdatable).setY(pWH);
						else if (Std.is(node.element, Base))
						{
							
							cast(node.element, Base).initY = pWH;
							cast(node.element, Base).init();
						}
						else
							node.element.y = pWH;
						pWH += node.element.height > 0 ? node.element.height + gap : (node.height != "" ? Std.parseFloat(node.height) : 0) + gap;
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
		}
		
		if (oldWidth != width || oldHeight != height)
		{
			//setDirty();
			dispatchResize();
		}
		
		//update this x and y
		//GUI._placeDisplay(Data, this, ContainerW, ContainerH, initWidth, initHeight);
		
		super.init();
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
	
		/**
	 * Called by child width/height changed
	 */
	override public function invalidate():Void 
	{
		if (_layout != null)
		{
			init();
			
			super.invalidate();
		}
	}
	
	function onChildResize():Void
	{
		init();
	}
}