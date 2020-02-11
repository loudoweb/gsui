package gsui;
import gsui.display.GenericButton;

/**
 * ...
 * @author loudo
 */
class GUIButtonData
{
	public var images:Array<GUIDataCouple>;
	public var texts:Array<GUIDataCouple>;
	public var state:String;
	public var onHover:String;
	public var clickHandler:GenericButton->String->String->Void;
	public var click:String;
	public function new(images:Array<GUIDataCouple>, texts:Array<GUIDataCouple>, state:String, onHover:String, click:String, ?clickHandler:GenericButton->String->String->Void ) 
	{
		this.images = images;
		this.texts = texts;
		this.state = state;
		this.onHover = onHover;
		this.clickHandler = clickHandler;
		this.click = click;
	}
	public function destroy():Void
	{
		images = null;
		texts = null;
		state = null;
		onHover = null;
		clickHandler = null;
		click = null;
	}
	
}
class GUIDataCouple
{
	public var gui:String;
	public var value:String;
	public function new(gui:String, value:String = "")
	{
		this.gui = gui;
		this.value = value;
	}
}