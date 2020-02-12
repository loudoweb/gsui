package gsui;
import gsui.ElementPosition;
import gsui.display.GenericButton;
import gsui.display.GUITextField;
import gsui.display.SimpleButton;
import gsui.display.Button;
import gsui.display.CheckBox;
import gsui.display.GUIGroup;
import gsui.display.GUIRender;
import gsui.display.GUISlider;
import gsui.display.GUIShape;
import gsui.display.ProgressBar;
import gsui.display.RadioButton;
import gsui.display.Slot;
import gsui.display.Sprite9Grid;
import gsui.interfaces.ICustomCursor;
import gsui.interfaces.IStateManager;
import gsui.transition.ITransitionFactory;
import gsui.transition.Transition;
import gsui.utils.FilterUtils;
import gsui.utils.MaskUtils;
import gsui.utils.ParserUtils;
import gsui.utils.ReplaceUtils;
import haxe.ds.StringMap;
import haxe.xml.Fast;
import motion.Actuate;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.filters.ColorMatrixFilter;
#if dconsole
import pgr.dconsole.DC;
#end
#if svg
import format.SVG;
import openfl.display.Shape;
#end
import openfl.filters.GlowFilter;

/**
 * User Interface
 * //TODO add if attribute in xml and add function to get dynamic data
 * //TODO save only groups in _groups currently in display list
 * //TODO dynamic reloading
 * @author loudo (Ludovic Bas)
 */
enum EGUIAction {
	GUI_CREATE;
	GUI_ADD;
	GUI_REMOVE;
	GUI_STATE;
	GUI_VAR;
	//GUI_EVENT;//TODO use signal?
}
enum EGUIEffect {
	SATURATE;
	GLOW;
	SEPIA;
	HUESAT;
}
enum EGUIType {
	IMG;
	GRID9;
	SIMPLEBUTTON;
	BUTTON;
	CHECKBOX;
	RADIO;
	SLIDER;
	TEXT;
	GROUP;
	BOXV;
	BOXH;
	RENDER;
	SLOT;
	PROGRESSBAR;
	RECT;
	CIRCLE;
}
typedef Tongue =
{
	public function get(flag:String, context:String, safe:Bool):String;
}
class GUI extends Sprite
{
	
	/**
	 * default : STATIC ; DYNAMIC means that all containers can resize when children change size or positions. You can control at a component basis using dynamic="true".
	 */
	public static var ISDYNAMIC:Bool = false;
	/**
	 * width beyond it doesn't scale, default: always scale
	 */
	public static var EFFECTIVE_AREA:Int = 4000;
	
	/**
	 * top group currently on display list
	 */
	static var _activeTopViews:StringMap<GUIGroup>;
	/**
	 * available groups that can be used for createConf or addConf/removeConf
	 */
	static var _views:StringMap<GUIGroup>;
	/**
	 * to create a gui
	 */
	static var _viewsConf:StringMap<Fast>;
	/**
	 * store definitions for shared components
	 */
	static var _def:StringMap<Fast>;
	/**
	 * binded variables for textfields
	 */
	@:allow(gsui.display.GUITextField)
	static var _bindedVariables:StringMap<BindedVariables>;
	
	static var _transition:StringMap<Transition>;

	
	public static var instance(default, null):GUI;
	static var _basePath:String;
	static var _interfaceFast:Fast;
	static var _confFast:Fast;
	
	static var _package:String;
	static var _gameState:IStateManager;
	
	static var _cursor:ICustomCursor;
	static var _transitionFactory:ITransitionFactory;
	
	static public var GUI_WIDTH(default, null):Float;
	static public var GUI_HEIGHT(default, null):Float;
	static public var TONGUE:Tongue;

	/**
	 * 
	 * @param	xml interface descriptor
	 * @param	conf configuration of views
	 * @param	basePath base path of assets
	 * @param	width same as of your xml interface
	 * @param	height same as of your xml interface
	 * @param	TONGUE allow to convert variable in current language.
	 */
	public function new(xml:String, conf:String, basePath:String, width:Float, height:Float, tongue:Tongue =  null, transition:ITransitionFactory = null) 
	{
		super();
		instance = this;
		
		TONGUE = tongue;
		GUI_WIDTH = width;
		GUI_HEIGHT = height;
		
		_basePath = basePath;
		_transitionFactory = transition;
		_package = "";
		
		
		
		//InterfaceMacro.init(xml);
		
		_activeTopViews = new StringMap<GUIGroup>();
		_views = new StringMap<GUIGroup>();
		_viewsConf = new StringMap<Fast>();
		_def = new StringMap<Fast>();
		_bindedVariables = new StringMap<BindedVariables>();
		_transition = new StringMap<Transition>();
		
		
		var xmlInterface:String = Assets.getText(xml);
		var xmlConf:String		= Assets.getText(conf);
		
		_interfaceFast = new Fast(Xml.parse(xmlInterface).firstElement());
		_confFast = new Fast(Xml.parse(xmlConf).firstElement());
		
		parseConf(_interfaceFast);
		
		#if dconsole
		DC.registerFunction(GUI.drawDebug, 'boxes', 'draw all boxes from GUI');
		#end
	}
	
	public static function setDimension(width:Float, height:Float):Void
	{
		GUI_WIDTH = width;
		GUI_HEIGHT = height;
	}
	
	/**
	 * 
	 * @param	path package name where all your views are
	 */
	public static function _initConf(path:String):Void
	{
		_package = path;
	}
	
	/**
	 * 
	 * @param	state game state handler that GSUI can call to synchronise your views with your game systems
	 */
	public static function _addGameState(state:IStateManager):Void
	{
		_gameState = state;
	}
	
	/**
	 * Create a view configuration (set of groups with sync system, saturated groups, etc.)
	 * @param	conf name of the view's configuration
	 */
	public static function _createConf(conf:String):Void
	{
		var el:Fast = _confFast.node.resolve(conf);
		
		for (group in _activeTopViews) 
		{
			group.removeFromParent();
			_activeTopViews.remove(group.name);
		}
		//create hudGroup to display
		var guis:Array<String> = Std.string(el.att.groups).split(",");
		var groupRoot:GUIGroup;
		for (gui in guis)
		{
			if(!_views.exists(gui)){
				groupRoot = cast _parseGroup(_viewsConf.get(gui), GUI_WIDTH, GUI_HEIGHT);
				_views.set(gui, groupRoot);
				instance.addChild(groupRoot);
				_activeTopViews.set(gui, groupRoot);
			}else {
				groupRoot = _views.get(gui);
				instance.addChild(groupRoot);
				_activeTopViews.set(gui, groupRoot);
			}
		}
		//desaturate
		if (el.has.desaturate && el.att.desaturate == "true")
		{
			_desaturate(null);
		}
		//create dynamic class to handle elements by custom code 
		//TODO generate by macro
		/*if(el.has.classes){
			var classes:Array<String> = Std.string(el.att.classes).split(",");
			for (curClass in classes)
			{
				Type.createInstance(Type.resolveClass(_package + curClass), []);
			}
			
		}*/
		//handle state game with IStateManager
		if (_gameState != null)
		{
			var state:String = el.has.state ? Std.string(el.att.state).toUpperCase() : "";
			if(state != "")
				_gameState.changeState(state);
		}
	}
	
	/**
	 * Add a view to the current one
	 * @param	conf name
	 */
	public static function _addConf(conf:String):Void
	{
		var el:Fast = _confFast.node.resolve(conf);
		var guis:Array<String> = Std.string(el.att.groups).split(",");
		var groupRoot:GUIGroup;
		for (gui in guis)
		{
			if(!_views.exists(gui)){
				groupRoot = cast _parseGroup(_viewsConf.get(gui), GUI_WIDTH, GUI_HEIGHT);
				_views.set(gui, groupRoot);
			}else {
				groupRoot = _views.get(gui);
			}
			_activeTopViews.set(gui, groupRoot);
			if (groupRoot.isBackground)
				instance.addChildAt(groupRoot, 0);
			else
				instance.addChild(groupRoot);
		}
		//saturate
		if (el.has.saturate)
		{
			_saturate(Std.string(el.att.saturate).split(","));
		}
		//create dynamic class to handle elements by custom code
		/*
		if(el.has.classes){
			var classes:Array<String> = Std.string(el.att.classes).split(",");
			for (curClass in classes)
			{
				Type.createInstance(Type.resolveClass(_package + curClass), []);
			}
			
		}*/
		//handle state game with IStateManager
		if (_gameState != null)
		{
			var state:String = el.has.state ? Std.string(el.att.state).toUpperCase() : "";
			if(state != "")
				_gameState.changeState(state);
		}
	}
	
	/**
	 * Remove a view from the current one
	 * @param	conf name
	 */
	public static function _removeConf(conf:String):Void
	{
		var el:Fast = _confFast.node.resolve(conf);
		var guis:Array<String> = Std.string(el.att.groups).split(",");
		var groupRoot:GUIGroup;
		for (gui in guis)
		{
			if(_activeTopViews.exists(gui)){
				var groupRoot:GUIGroup = _views.get(gui);
				if (groupRoot != null) {
					groupRoot.removeFromParent();
					_activeTopViews.remove(gui);
				}
			}
		}
		//desaturate
		if (el.has.saturate)
		{
			_desaturate(Std.string(el.att.saturate).split(","));
		}
		//handle state game with IStateManager
		if (_gameState != null)
		{
			if(el.has.state)
				_gameState.getBackToPreviousState();
		}
	}
	
	/**
	 * Parse the whole xml to store all parts in a StringMap
	 * @param	fast from xml of interface
	 */
	private function parseConf(fast:Fast):Void {
		for (el in fast.elements)
		{
			if (el.name == "definitions")
			{
				for (sub in el.elements)
				{
					_def.set(sub.att.id, sub);
				}
			}
			if(el.has.id)
				_viewsConf.set(el.att.id, el);
		}
	}
	
	public static function getFast(groupName:String):Fast
	{
		return _viewsConf.get(groupName);
	}
	
	/**
	 * General Factory
	 * @param	Data
	 * @param	ContainerW
	 * @param	ContainerH
	 * @return
	 */
	public static function _parseXML(Data:Fast, ContainerW:Float, ContainerH:Float):Array<GUINode>
	{
		var _nodes:Array<GUINode> = new Array<GUINode>();
		var display:DisplayObject = null;
		var node:GUINode = null;
				
		for(el in Data.elements)
		{
			switch(Type.createEnum(EGUIType, el.name.toUpperCase()))
			{
				case IMG:
					display = _parseImage(el, ContainerW, ContainerH);
				case GRID9:
					display = _parseGrid9(el, ContainerW, ContainerH);
				case SIMPLEBUTTON:
					display = _parseSimpleButton(el, ContainerW, ContainerH);
				case BUTTON:
					display = _parseButton(el, ContainerW, ContainerH);
				case CHECKBOX:
					display = _parseCheckbox(el, ContainerW, ContainerH);
				case RADIO:
					display = _parseRadio(el, ContainerW, ContainerH);
				case SLIDER:
					display = _parseSlider(el, ContainerW, ContainerH);
				case TEXT:
					display = _parseText(el, ContainerW, ContainerH);
				case GROUP:
					display = _parseGroup(el, ContainerW, ContainerH);
				case BOXV:
					display = _parseGroup(el, ContainerW, ContainerH);
				case BOXH:
					display = _parseGroup(el, ContainerW, ContainerH);
				case RENDER:
					display = _parseRender(el, ContainerW, ContainerH);
				case SLOT:
					display = _parseSlot(el, ContainerW, ContainerH);
				case PROGRESSBAR:
					display = _parseProgress(el, ContainerW, ContainerH);
				case RECT, CIRCLE:
					display = _parseShape(el, ContainerW, ContainerH);
			}
			
			if (display != null) {
				node = new GUINode(display, el.has.state ? el.att.state : "", el);
				_nodes.push(node);
			}
		}
		return _nodes;
	}
	
	/**
	 * Image Factory
	 * @param	el
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseImage(el:Fast, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var image:DisplayObject;
		
		#if svg
		
		if (el.att.name.indexOf(".svg") != -1)
		{
			//svg
			var svg = new SVG(Assets.getText (_basePath + el.att.name));
			var shape = new Shape();
			svg.render(shape.graphics);
			image = shape;
		}else{
			image = new Bitmap(Assets.getBitmapData(_basePath + el.att.name, true), PixelSnapping.AUTO, true);
		}
		
		#else
		image = new Bitmap(Assets.getBitmapData(_basePath + el.att.name, true), PixelSnapping.AUTO, true);
		#end
		return _placeDisplay(el, image, parentWidth, parentHeight, image.width, image.height);
	}
	/**
	 * Grid 9 factory (TODO use current openfl grid9)
	 * @param	el
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseGrid9(el:Fast, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var image = new Sprite9Grid(Assets.getBitmapData(_basePath + el.att.img, true), Std.int(ParserUtils.getWidth(el, parentWidth)), Std.int(ParserUtils.getHeight(el, parentHeight)));
		return _placeDisplay(el, image, parentWidth, parentHeight, image.width, image.height);
	}
	/**
	 * Text factory
	 * @param	el
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseText(el:Fast, ?parentWidth:Float, ?parentHeight:Float):DisplayObject//TODO vAlign
	{
		
		//create textfield
		return new GUITextField(el, parentWidth, parentHeight);
	}
	/**
	 * Group factory
	 * @param	fast
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseGroup(fast:Fast, parentWidth:Float, parentHeight:Float):DisplayObject
	{	
		//TODO create GuiLayer and give ability to reorder/redispatch in realtime
		var display = new GUIGroup(fast, parentWidth, parentHeight);
		return display;
	}
	/**
	 * Render Factory (group with item renderer)
	 * @param	fast
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseRender(fast:Fast, parentWidth:Float, parentHeight:Float):DisplayObject
	{	
		var display = new GUIRender(fast, parentWidth, parentHeight);
		return display;
	}
	/**
	 * Simplebutton factory
	 * @param	el
	 * @param	group
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseSimpleButton(el:Fast, ?group:Sprite, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var _default:BitmapData = el.has.name ? Assets.getBitmapData(_basePath+el.att.name, true) : null;
		var hover:BitmapData = el.has.hover ? Assets.getBitmapData(_basePath + el.att.hover, true) : null;
		var selected:BitmapData = el.has.selected ? Assets.getBitmapData(_basePath + el.att.selected, true) : null;
		var display:SimpleButton = new SimpleButton(_default, hover, selected, el, parentWidth, parentHeight);
		display.name = el.att.id;
		return display;
		
	}
	/**
	 * Button Factory
	 * @param	el
	 * @param	group
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseButton(el:Fast, ?group:Sprite, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var display:Button = new Button(el, parentWidth, parentHeight);
		return display;
		
	}
	/**
	 * Checkbox button factory
	 * @param	el
	 * @param	group
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseCheckbox(el:Fast, ?group:Sprite, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var bg:BitmapData = el.has.bg ? Assets.getBitmapData(_basePath+el.att.bg, true) : null;
		var check:BitmapData = el.has.check ? Assets.getBitmapData(_basePath + el.att.check, true) : null;
		var display:CheckBox = new CheckBox(el, bg, check, parentWidth, parentHeight);
		return _placeDisplay(el, display, parentWidth, parentHeight, bg.width, bg.height);
		
	}
	/**
	 * Radio button factory
	 * @param	el
	 * @param	group
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseRadio(el:Fast, ?group:Sprite, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var bg:BitmapData = el.has.bg ? Assets.getBitmapData(_basePath+el.att.bg, true) : null;
		var check:BitmapData = el.has.check ? Assets.getBitmapData(_basePath + el.att.check, true) : null;
		var display:RadioButton = new RadioButton(el, bg, check, parentWidth, parentHeight);
		return _placeDisplay(el, display, parentWidth, parentHeight, bg.width, bg.height);
		
	}
	/**
	 * Slider factory
	 * @param	el
	 * @param	group
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseSlider(el:Fast, ?group:Sprite, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var display:GUISlider = new GUISlider(el, parentWidth, parentHeight);
		//TODO merge Data with sliderDef
		return _placeDisplay(el, display, parentWidth, parentHeight, display.width, display.height);
	}
	
	/**
	 * Slot factory (place to add something else, can be a UI or game object)
	 * @param	fast
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseSlot(xml:Fast, ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{			
		return new Slot(xml, parentWidth, parentHeight);
	}
	
	/**
	 * Progress Bar factory
	 * @param	fast
	 * @param	parentWidth
	 * @param	parentHeight
	 * @return
	 */
	public static function _parseProgress(fast:Fast,  ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var display = new ProgressBar(fast, parentWidth, parentHeight, _basePath);
		return _placeDisplay(fast, display, parentWidth, parentHeight, display.width, display.height);
	}
	
	public static function _parseShape(fast:Fast,  ?parentWidth:Float, ?parentHeight:Float):DisplayObject
	{
		var display = new GUIShape(fast, parentWidth, parentHeight);
		return _placeDisplay(fast, display, parentWidth, parentHeight, display.width, display.height);
	}
	
	/**
	 * Helper to positionate elements
	 * @param	el
	 * @param	display
	 * @param	parentWidth
	 * @param	parentHeight
	 * @param	displayWidth because some display object doesn't have a width yet
	 * @param	displayHeight because some display object doesn't have a height yet
	 */
	public static function _placeDisplay(el:Fast, display:DisplayObject, parentWidth:Float, parentHeight:Float, displayWidth:Float, displayHeight:Float):DisplayObject
	{
		var pos:ElementPosition = new ElementPosition(el, parentWidth, parentHeight, displayWidth, displayHeight);
		
		if(pos.mask != null)
			MaskUtils.createMask(display, pos.mask);
		
		display.x = pos.x;
		display.y = pos.y;
		
		if (el.has.scale)
			display.scaleX = display.scaleY = Std.parseFloat(Std.string(el.att.scale));
		if (el.has.sW)
			display.scaleX = Std.parseFloat(Std.string(el.att.sW));
		if (el.has.sH)
			display.scaleY = Std.parseFloat(Std.string(el.att.sH));
		if (el.has.flipX){
			display.scaleX = -1;
			display.x += display.width;
		}
		if (el.has.flipY){
			display.scaleY = -1;
			display.y += display.height;
		}
		
		if (el.has.a)
			display.rotation = Std.parseFloat(Std.string(el.att.a));
		if (el.has.visible) 
			display.visible = el.att.visible == "true";
			
		if (el.has.effect && el.att.effect != "")
			_effect(display, Type.createEnum(EGUIEffect, el.att.effect.toUpperCase()));
			
		return display;
	}
	
	public static function getTransition(name:String):Transition
	{
		if (!_transition.exists(name))
		{
			for (tween in _interfaceFast.node.transitions.nodes.tween)
			{
				if (tween.att.id == name)
				{
					_transition.set(name, _transitionFactory.create(tween));
				}
			}
		}
		return _transition.get(name);
	}
	
	/**
	 * 
	 * @param	name
	 * @param	state
	 */
	public static function _changeState(name:String, state:String):Void
	{
		//TODO fix because now we use only top active groups
		_activeTopViews.get(name).state = state;
	}
	
	public static function _mouseHandler(button:GenericButton, eventType:String, param:String):Void
	{
		if (param == "")
			return;
		var prefix:EGUIAction = Type.createEnum(EGUIAction, Std.string(param.split(":")[0]).toUpperCase());
		if (prefix == null)
			throw new Error("The Enum specified [" + param.split(":")[0] + "]doesn't exist");
		var value:String = param.split(":")[1];
		resolveGuiAction(prefix, value);
		
	}
	public static function resolveGuiAction(action:EGUIAction, value:String):Void
	{
		switch(action) {
			case GUI_CREATE:
				_createConf(value);
			case GUI_ADD:
				_addConf(value);
			case GUI_REMOVE:
				_removeConf(value);
			case GUI_STATE:
				var states:Array<String> = value.split(",");
				if (states.length != 2)
					throw new Error("States need name of a group and name of the state separated by comma");
				_changeState(states[0], states[1]);
			case GUI_VAR:
				var couple:Array<String> = value.split(",");
				if (couple.length < 2)
					throw new Error("Binded vars need name of the var and value separated by comma");
				var coupleVar:Array<String> = [for (i in 0...couple.length) if (i & 1 == 0) couple[i]];
				var coupleValue:Array<String> = [for (i in 0...couple.length) if (i & 1 != 0) couple[i]];
				for (i in 0...coupleVar.length)
				{
					var varValue:String = coupleValue[i];
					if (TONGUE != null && varValue.charAt(0) == "$")
							varValue = ReplaceUtils.replaceTongue(TONGUE.get(varValue, "interface", true), TONGUE);
					_bindVariable(coupleVar[i], varValue);
				}
		}
	}
	public static function _saturate(groups:Array<String>):Void{
		var currentGroup:GUIGroup;
		var cmFilter:ColorMatrixFilter = FilterUtils.saturate();
	
		for (group in groups)
		{
			if (_activeTopViews.exists(group))
			{
				currentGroup = _activeTopViews.get(group);
				currentGroup.filters = [cmFilter];
			}
		}
	}
	public static function _desaturate(groups:Array<String>):Void {
		if (groups == null) {//desaturate everything
			
			for (group in _activeTopViews)
			{
				group.filters = null;
			}
		}else {//desaturate only groups from args
			for (group in groups)
			{
				if (_activeTopViews.exists(group))
				{
					_activeTopViews.get(group).filters = null;
				}
			}
		}
		
	}
	public static function _effect(child:DisplayObject, effect:EGUIEffect):Void
	{
		switch(effect)
		{
			case SATURATE:
				child.filters = [FilterUtils.saturate()];
			case GLOW:
				child.filters = [new GlowFilter(0xf1eace, 0.5, 3, 3, 4)];
			case SEPIA:
				child.filters = [new ColorMatrixFilter(FilterUtils.SEPIA)];
			case HUESAT:
				child.filters = [FilterUtils.saturate(0.25), new ColorMatrixFilter(FilterUtils.hue(35 * Math.PI))];
		}
	}
	public static function _getGroup(name:String):GUIGroup
	{
		if (_activeTopViews.exists(name))
			return _activeTopViews.get(name);
		return null;
	}
	public static function _bindVariable(name:String, value:String):Void
	{
		if (_bindedVariables.exists(name)) {
			_bindedVariables.get(name).value = value;
		}else {
			_bindedVariables.set(name, new BindedVariables(name, value));
		}
	}
	public static function _getDef(id:String):Fast
	{
		if (_def.exists(id))
			return _def.get(id);
		return null;
	}
	public static function _addCursor(cursor:ICustomCursor):Void
	{
		_cursor = cursor;
	}
	public static function _cursorOver():Void
	{
		if (_cursor != null) 
		{
			_cursor.over();
		}
	}
	public static function _cursorOut():Void
	{
		if (_cursor != null) 
		{
			_cursor.up();
		}
	}
	public static function _getBitmapData(name:String):BitmapData
	{
		return Assets.getBitmapData(_basePath + name);
	}
	
	#if debug
	public static function drawDebug():Void
	{
		trace(_activeTopViews);
		for (group in _activeTopViews)
		{
			group.drawDebug();
		}
	}
	#end
}