package gsui;

/**
 * ...
 * @author loudo
 */
class GuiButtonData
{
	public var images:Array<GuiDataCouple>;
	public var texts:Array<GuiDataCouple>;
	public var state:String;
	public var onHover:String;
	public var clickHandler:AbstractButton->String->String->Void;
	public var click:String;
	public function new(images:Array<GuiDataCouple>, texts:Array<GuiDataCouple>, state:String, onHover:String, click:String, ?clickHandler:AbstractButton->String->String->Void ) 
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
class GuiDataCouple
{
	public var gui:String;
	public var value:String;
	public function new(gui:String, value:String = "")
	{
		this.gui = gui;
		this.value = value;
	}
}