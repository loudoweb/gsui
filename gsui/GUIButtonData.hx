package gsui;
import gsui.display.Button.EButtonBehavior;
import gsui.display.GenericButton;

/**
 * Data to render a Button contained in a GUIRender
 * @author loudo
 */
class GUIButtonData
{
	/**
	 * Images in Slots to update
	 */
	public var images:Array<GUIDataCouple>;
	/**
	 * Texts to update
	 */
	public var texts:Array<GUIDataCouple>;
	public var state:String;
	/**
	 * Custom hover parameter
	 */
	public var onHover:String;
	/**
	 * Custom click parameter
	 */
	public var onClick:String;
	/**
	 * Mouse Handler (over, out, click)
	 */
	public var mouseCallback:GenericButton->String->String->Void;
	/**
	 * Behavior when the Button is clicked
	 */
	public var behaviour:EButtonBehavior;

	public var x:Null<Float>;
	public var y:Null<Float>;

	/**
	 * [Description]
	 * @param images Images in Slots to update
	 * @param texts Texts to update
	 * @param state state of the Button to update
	 * @param onHover Custom hover parameter
	 * @param click Custom click parameter
	 * @param mouseCallback Mouse Handler (over, out, click)
	 * @param behaviour Behavior when the Button is clicked
	 */
	public function new(images:Array<GUIDataCouple>, texts:Array<GUIDataCouple>, state:String = "", onHover:String = "", onClick:String = "", ?mouseCallback:GenericButton->String->String->Void, ?behaviour:EButtonBehavior ) 
	{
		this.images = images;
		this.texts = texts;
		this.state = state;
		this.onHover = onHover;
		this.mouseCallback = mouseCallback;
		this.onClick = onClick;
		this.behaviour = behaviour != null ? behaviour : NONE;
	}
	public function destroy():Void
	{
		images = null;
		texts = null;
		state = null;
		onHover = null;
		mouseCallback = null;
		onClick = null;
		x = null;
		y = null;
	}
	
}
class GUIDataCouple
{
	public var gui:String;
	public var value:String;
	/**
	 * Allow to associate an element of the gui to a value to change an image or a text dynamically
	 * @param gui 
	 * @param value 
	 */
	inline public function new(gui:String, value:String = "")
	{
		this.gui = gui;
		this.value = value;
	}
}