package gsui.display;
import gsui.utils.ParserUtils;
import openfl.display.Sprite;
import haxe.xml.Fast;
import openfl.geom.Rectangle;

/**
 * ...render many buttons automatically.
 * @usage call setData(), addData(), removeData() to update
 * @author loudo
 */
class GUIRender extends Sprite
{
	public var isBackground:Bool = false;
	
	public var nodes(default, null):Array<Button>;
	
	var _width:Float;
	var _height:Float;
	
	/**
	 * layout v (vertical), h (horizontal), p (already placed), or column,row
	 * @default h (horizontal)
	 */
	var _layout:String = "";//default h
	
	var _gap:Int;
	
	public var centerContent:Bool;
	
	var _containerW:Float;
	var _containerH:Float;
	
	public var maxItem:Int;
	public var items(default, null):Int;


	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		
		_width = ParserUtils.getWidth(Data, ContainerW);
		_height = ParserUtils.getHeight(Data, ContainerH);
		isBackground = Data.has.background && Data.att.background == "true";
		centerContent = Data.has.x && Data.att.x == "center";//TODO center y
		_containerW = ContainerW;
		_containerH = ContainerH;
		
		name = Data.att.id;
		
		maxItem = Std.parseInt(Data.att.num);
		
		var itemRenderer:Fast = Data.elements.next();
		
		var gap:Int = Data.has.gap ? Std.parseInt(Data.att.gap) : 0;
		var gapW:Int = gap;
		var gapH:Int = gap;
		var scale:Float = itemRenderer.has.scale ? Std.parseFloat(itemRenderer.att.scale) : 1;
		if (itemRenderer.has.width) {
			gapW += Std.int(Std.parseInt(itemRenderer.att.width) * scale);
		}
		if (itemRenderer.has.height) {
			gapH += Std.int(Std.parseInt(itemRenderer.att.height) * scale);
		}
		var row:Int = 1;
		var column:Int = 1;
		if (Data.has.layout)
		{
			_layout = Data.att.layout;
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
		if (row == -1) {//already placed
			for (el in Data.elements)
			{
				nodes.push(cast(GUI._parseButton(el, _width, _height), Button));
			}
		}else {//need to be placed
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
					button = cast GUI._parseButton(itemRenderer, _width, _height);
					button.setX(buttonX);
					button.setY(buttonY);
					if(itemRenderer.has.id)
						button.name = itemRenderer.att.id + i;
					nodes.push(button);
					i++;
					
				}
			}
		}
		
		GUI._placeDisplay(Data, this, ContainerW, ContainerH, _width, _height);
		
	}
	public function updatePosition():Void
	{
		if (centerContent)
		{
			x = (_containerW  - width) * 0.5;
		}
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
	public function setDirty():Void
	{
		if (this.parent != null)
		{
			this.parent.invalidate();
		}
		updatePosition();//TODO merge with Base.init()
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