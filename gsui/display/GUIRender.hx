package gsui.display;
import gsui.utils.ParserUtils;
import openfl.display.Sprite;
import haxe.xml.Fast;
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
	 * layout v (vertical), h (horizontal), p (already placed), or column,row
	 * @default h (horizontal)
	 */
	var _layout:String = "";//default h
	
	var _gap:Int;
	
	public var centerContent:Bool;
	
	var _containerW:Float;
	var _containerH:Float;
	var itemRenderer:Fast;
	var gapW:Int;
	var gapH:Int;
	
	public var maxItem:Int;
	public var items(default, null):Int;
	public var row:Int;
	public var column:Int;


	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super(Data, ContainerW, ContainerH);
	}
	
	override function parse(xml:Fast):Void 
	{
		super.parse(xml);
		
		isBackground = xml.has.background && xml.att.background == "true";
		centerContent = xml.has.x && xml.att.x == "center";//TODO center y
		
		maxItem = Std.parseInt(xml.att.num);
		
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
	
	override public function init():Void 
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
		
		super.init();
		
		updatePosition();
	}
	
	public function updatePosition():Void
	{
		/*if (centerContent)
		{
			x = (_containerW  - width) * 0.5;
		}*/
		/*if (height > _height && this.scrollRect == null)
		{
			this.scrollRect = new Rectangle(0, 0, _width, _height);
			//TODO make element scrollable
		}*/
	}
	public function setData(data:Array<GUIButtonData>):Void
	{
		if (data.length > maxItem) {
			trace("too many data");
			return;
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
		setDirty();
	}
	public function addData(data:Array<GUIButtonData>):Void
	{
		var begin:Int = items;
		if (items + data.length > maxItem) {
			trace("too many data");
			return;
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
	public function fitData():Void
	{
		var collectedData:Array<GUIButtonData> = [];
		//collect GuiButtonData
		for (node in nodes)
		{
			if (node.parent != null && node.getData() != null)
			{
				collectedData.push(node.getData());
			}
		}
		setData(collectedData);
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