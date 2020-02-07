package gsui.display;
import gsui.utils.ParserUtils;
import gsui.utils.XMLUtils;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.events.MouseEvent;
import haxe.xml.Fast;
import openfl.Assets;
import openfl.display.DisplayObject;
#if debug
import gsui.interfaces.IDebuggable;
#end

/**
 * Advanced Button where you can put as many things you want including texts
 * TODO externalize get assets and parsing data
 * TODO QCU
 * @author loudo
 */
#if debug
class Button extends GenericButton implements IDebuggable
#else
class Button extends GenericButton
#end
{
	public var state(get, set):String;
	function get_state():String{ return _currentState; } 
	
	var _width:Float;
	var _height:Float;
	var _isAutoSize:Bool;
	
	var _nodes:Array<GUINode>;
	
	var _keepSelect:Bool = false;
	
	#if debug
	var _debug:Bool = false;
	#end
	
	var _data:GuiButtonData = null;
	/**
	 * only one additional default state per button activated at a time
	 */
	var _customState:String = "";
	/**
	 * States for a button : up, hover, selected.
	 * These states can be mixed with default "" and _customState
	 */
	var _currentState:String = "";
	

	function set_state(value:String):String { 
		if (_currentState == value)
			return _currentState;
					
		handleState(value);
		
		_currentState = value;
		
		return _currentState;
	} 
	
	function handleState(value:String):Void
	{
		//CHILDS
		//remove everything but state == "" and customState
		if(value != ""){
			for (node in _nodes)
			{
				if(!node.isDefaultState() && !node.hasState(_customState)){
					if (node.element != null && node.element.parent != null) {
						if (node.data.has.onOut)
						{
							var i = 0;
							for (onOut in node.data.att.onOut.split(","))
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
		}
		//add default (state == "") and current state (allow to replace in order element non removed too)
		for (node in _nodes)
		{
			if (node.hasState(value) || node.isDefaultState() || node.hasState(_customState))
			{
				if (node.element != null) {
						addChild(node.element);
						
						if (node.data.has.onIn)
						{
							for (onIn in node.data.att.onIn.split(","))
							{
								GUI.getTransition(onIn).start(node.element);
							}
						}
						
						if (value == "hover" && node.data.has.onHover )
						{
							for (onHover in node.data.att.onHover.split(","))
							{
								GUI.getTransition(onHover).start(node.element);
							}
						}else if (_currentState == "hover" && value == "up" && node.data.has.onUp)
						{
							for (onUp in node.data.att.onUp.split(","))
							{
								GUI.getTransition(onUp).start(node.element);
							}
						}
						
						if (Std.is(node.element, GUITextField) && node.data.has.hoverColor)//hack for text
						{
							if (value == "hover") {
								cast(node.element, GUITextField).textColor = ParserUtils.getColor(node.data, "hoverColor");
							}else {
								cast(node.element, GUITextField).textColor = ParserUtils.getColor(node.data);
							}
						}
				}
			}
		}
		//CURRENT BOUTON ROOT
		switch(value) {
			case "up":
				x = _positions.x;
				y = _positions.y;
			case "hover":
				x = _positions.x + _positions.x_hover;
				y = _positions.y + _positions.y_hover;
			case "selected":
				x = _positions.x + _positions.x_selected;
				y = _positions.y + _positions.y_selected;
		}
	}
	
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super( Data.has.click ? Data.att.click : "", Data.has.onHover ? Data.att.onHover : "");
		
		if(Data.has.id)
			name = Data.att.id;
		
		_width = Data.has.width ? Std.parseFloat(Data.att.width) : ContainerW;
		_height = Data.has.height ? Std.parseFloat(Data.att.height) : ContainerH;
		
		_isAutoSize = Data.has.size && Data.att.size == "auto";
		
		if (_isAutoSize)
		{
			_width = Std.parseFloat(XMLUtils.getFirstChild(Data).att.width);
			_height = Std.parseFloat(XMLUtils.getFirstChild(Data).att.height);
		}
		
		_keepSelect = Data.has.keepSelect ? Data.att.keepSelect == "true" : false;
		
		if (Data.has.scale)
			scaleX = scaleY = Std.parseFloat(Std.string(Data.att.scale));
		if (Data.has.sW)
			scaleX = Std.parseFloat(Std.string(Data.att.sW));
		if (Data.has.sH)
			scaleY = Std.parseFloat(Std.string(Data.att.sH));
		if (Data.has.a)
			rotation = Std.parseFloat(Std.string(Data.att.a));
			
		if(Data.has.hitArea && Data.att.hitArea == "true"){
			this.graphics.beginFill(0, 0);
			this.graphics.drawRect(0,0,_width, _height);
			this.graphics.endFill();
		}
		
		if (Data.has.param)
			customClickParam = Data.att.param;
		
		_nodes = GUI._parseXML(Data, _width, _height);
		
		_positions = new ElementPosition(Data, ContainerW, ContainerH, _width, _height);
		
		x = _positions.x;
		y = _positions.y;
		
		state = "up";
		_needRollListeners = true;
		init();
	}
	
	override private function doHover(e:MouseEvent):Void
	{
		if (!disableMouseClick)
		{
			if(!_keepSelect || (_keepSelect && _currentState != "selected")){
				if (e.type == MouseEvent.ROLL_OVER) {
					state = "hover";
				}else {
					state = "up";
				}
			}
		}
		super.doHover(e);
	}
	override public function select():Void
	{
		state = "selected";
		super.select();
	}
	override public function unselect():Void
	{
		state = "up";
		super.unselect();
	}
	
	override public function getSlot(name:String):Slot
	{
		for (node in _nodes)
		{
			if (Std.is(node.element, Slot) && node.element.name == name) {
				return cast(node.element, Slot);
			}
		}
		return null;
	}
	public function getTextfield(name:String):GUITextField
	{
		for (node in _nodes)
		{
			if (Std.is(node.element, GUITextField) && node.element.name == name) {
				return cast(node.element, GUITextField);
			}
		}
		return null;
	}
	public function setData(guiButtonData:GuiButtonData):Void
	{
		if (guiButtonData != null) {
			_data = guiButtonData;
			if(guiButtonData.images != null){
				for (i in 0...guiButtonData.images.length)
				{
					var slot:Slot = getSlot(guiButtonData.images[i].gui);
					slot.removeAll();
					trace(guiButtonData.images[i].value);
					if(guiButtonData.images[i].value != "")
						slot.addChild(new Bitmap(Assets.getBitmapData(guiButtonData.images[i].value), PixelSnapping.AUTO, true));
					
				}
			}
			if(guiButtonData.texts != null){
				for (i in 0...guiButtonData.texts.length)
				{
					var text:GUITextField = getTextfield(guiButtonData.texts[i].gui);
					text.text = guiButtonData.texts[i].value;
					
				}
			}
			
			if (guiButtonData.state != "") {
				_customState = guiButtonData.state;
				handleState(_currentState);
			}else {
				_customState = "";
			}
			customHoverParam = guiButtonData.onHover;
			customClickParam = guiButtonData.click;
			mouseCallback = guiButtonData.clickHandler;
			//disableMouseClick = mouseCallback != null ? false : true;
			//disableGUICallback = disableMouseClick;
		}
	}
	public function removeData():Void
	{
		_customState = "";
		customHoverParam = "";
		customClickParam = "";
		mouseCallback = null;
		if (_data != null)
		{
			_data.destroy();
			_data = null;
		}
	}
	public function getData():GuiButtonData
	{
		return _data;
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
	
	#if debug
	public function drawDebug():Void
	{
		trace('drawDebug',_debug, width, height, x, y);
		if (!_debug)
		{
			this.graphics.beginFill(0x00ff00, 0.25);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			_debug = true;
		}
		else {
			this.graphics.clear();
			_debug = false;
		}
	}
	#end
	/*public function clone():Button
	{
		var b:Button = new Button()
	}*/
}