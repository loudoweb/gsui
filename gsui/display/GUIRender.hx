package gsui.display;
import gsui.utils.ParserUtils;
import openfl.display.Sprite;
import haxe.xml.Access;
import openfl.geom.Rectangle;

/**
 * ...render many buttons automatically.
 * //TODO should not need alreayd set nodes to addData
 * @usage call setData(), addData(), removeData() to update
 * @author loudo
 */
class GUIRender extends Base
{
	public var isBackground:Bool = false;
	
	public var nodes(default, null):Array<Button>;
	
	/**
	 * layout v (vertical), h (horizontal), p (already placed), or ColumnxRow
	 * @default h (horizontal)
	 */
	var _layout:String = "";//default h
	
	var _gap:Int;
	
	public var centerContent:Bool;
	
	var _containerW:Float;
	var _containerH:Float;
	var itemRenderer:Access;
	var gapW:Int;
	var gapH:Int;
	var _oldWidth:Float;
	var _oldHeight:Float;
	
	/**
	 * 
	 * MaxItem limit the number of items in the stack. If set to 0, it means there is no limit.
	 * Each item after the limit, is a cloned of the first one.
	 */
	public var maxItem:Int;
	public var items(default, null):Int;
	public var row:Int;
	public var column:Int;


	public function new(Data:Access, ContainerW:Float, ContainerH:Float) 
	{
		super(Data, ContainerW, ContainerH);
	}
	
	override function parse(xml:Access):Void 
	{
		super.parse(xml);
		
		isBackground = xml.has.background && xml.att.background == "true";
		centerContent = xml.has.x && xml.att.x == "center";//TODO center y
		
		maxItem = xml.has.num ? Std.parseInt(xml.att.num) : 0;
		
		itemRenderer = xml.elements.next();
		
		_gap = xml.has.gap ? Std.parseInt(xml.att.gap) : 0;
		gapW = _gap;
		gapH = _gap;
		var scale:Float = itemRenderer.has.scale ? Std.parseFloat(itemRenderer.att.scale) : 1;
		if (itemRenderer.has.width) {
			gapW += Std.int(Std.parseInt(itemRenderer.att.width) * scale);
		}
		if (itemRenderer.has.height) {
			gapH += Std.int(Std.parseInt(itemRenderer.att.height) * scale);
		}
		
		row = 1;
		column = 1;
		
		if (xml.has.layout)
		{
			_layout = xml.att.layout;
			if (_layout == "h") {
				column = maxItem;
				_gap = gapW;
			}else if (_layout == "v") {
				row = maxItem;
				_gap = gapH;
			}else if(_layout == "p"){
				column = -1;
				row = -1;
			}else {
				column = Std.parseInt(_layout.split("x")[0]);
				row = Std.parseInt(_layout.split("x")[1]);
			}
		}else {
			column = maxItem;
			_layout = "h";
		}
		
		nodes = [];
		
		//parse already placed elements
		if (row == -1) {
			for (el in xml.elements)
			{
				nodes.push(cast(GUI._parseButton(el, initWidth, initHeight), Button));
			}
		}else{
			//create buttons from item renderer
			var button:Button;
			var buttonX:Float = 0;
			var buttonY:Float = 0;
			var i = 1;
			for (j in 0...row)
			{
				buttonY = j * gapH;
				for (k in 0...column)
				{
					buttonX = k * gapW;
					button = cast GUI._parseButton(itemRenderer, initWidth, initHeight);
					button.setX(buttonX);
					button.setY(buttonY);
					if(itemRenderer.has.id)
						button.name = itemRenderer.att.id + i;
					nodes.push(button);
					i++;
					
				}
			}
		}
	}

	override public function preInit():Void 
	{
		//move only item renderer and not already placed nodes
		/*if (row > -1)
		{
			var i = 0;
			var buttonX:Float = 0;
			var buttonY:Float = 0;
			for (node in nodes)
			{
				buttonX = (i % column) * gapW;
				buttonY = (i % row) * gapH;
				node.setX(buttonX);
				node.setY(buttonY);
				i++;
			}
		}*/
	}
	
	override public function init():Void 
	{
		/*var oldWidth = width;
		var oldHeight = height;
		
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
		*/
		super.init();
		
	}

	public function setData(data:Array<GUIButtonData>):Void
	{
		_oldWidth = initWidth;
		_oldHeight = initHeight;

		if (data.length > maxItem) {
			if(maxItem > 0)
			{
					trace("too many data");
					return;
			}else{
				for(i in 0...data.length)
				{
					var button:Button = cast GUI._parseButton(itemRenderer, initWidth, initHeight);
					if(itemRenderer.has.id)
						button.name = itemRenderer.att.id + i;
					nodes.push(button);
				}
			}
		}
		items = data.length;
		var i:Int = 0;
		for (node in nodes)
		{
			if (i < items) {
				addChild(node);
				node.setData(data[i]);
				if (node.onIn != "")
				{
					for (onIn in node.onIn.split(","))
					{
						GUI.getTransition(onIn).start(node);
					}
				}
			}else {
				if(node.parent != null)
					node.parent.removeChild(node);
			}
			++i;
		}

		switch(_layout)
		{
			case "h":
				initWidth = width;
			case "v":
				initHeight = height;
			default:
				initHeight = height;
				initWidth = width;
		}
		


		/*if (oldWidth != width || oldHeight != height)
		{
			//setDirty();
			dispatchResize();
		}*/
		setDirty();
	}
	public function addData(data:Array<GUIButtonData>):Void
	{
		_oldWidth = initWidth;
		_oldHeight = initHeight;

		var begin:Int = items;
		if (items + data.length > maxItem) {
			if(maxItem > 0)
			{
					trace("too many data");
					return;
			}else{
				for(i in 0...data.length)
				{
					var button:Button = cast GUI._parseButton(itemRenderer, initWidth, initHeight);
					if(itemRenderer.has.id)
						button.name = itemRenderer.att.id + begin + i;
					nodes.push(button);
				}
				
			}
			
		}
		items += data.length;
		for (i in begin...items)
		{
			var node:Button = nodes[i];
			if (i < items) {
				addChild(node);
				node.setData(data[i-begin]);
			}else {
				if(node.parent != null)
					node.parent.removeChild(node);
			}
		}

		switch(_layout)
		{
			case "h":
				initWidth = width;
			case "v":
				initHeight = height;
			default:
				initHeight = height;
				initWidth = width;
		}

		setDirty();
	}
	public function removeData(indexes:Array<Int>):Void
	{
		var toRemove:Array<Button> = [];
		for (i in 0...indexes.length)
		{
			toRemove.push(nodes[indexes[i]]);
		}
		items -= toRemove.length;
		for (node in toRemove)
		{
			node.removeData();
			if(node.parent != null)
				node.parent.removeChild(node);
		}
		setDirty();
	}
	
	public function clear():Void
	{
		for (node in nodes)
		{
			node.removeData();
			if(node.parent != null)
				node.parent.removeChild(node);
		}
		items = 0;
		
		setDirty();
	}
	
	public function getButtonIndex(button:Button):Int
	{
		var i:Int = 0;
		for (node in nodes)
		{
			if (node == button)
				return i;
			i++;
		}
		return -1;
	}
	public function getButton(index:Int):Button
	{
		return nodes[index];
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
	
}