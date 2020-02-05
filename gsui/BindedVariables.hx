package gsui;
import gsui.display.GUITextField;

/**
 * Create a variable and add as many textfields you like, when the value changes, the textfields will be updated
 * //TODO use generic <T> and not TextField but what to do with textfield.text = value ? ...=>typedef ?
 * //TODO destroy on removed from stage
 * @author loudo
 */
class BindedVariables
{
	public var name:String;
	@:isVar public var value(get,set):String;
	public var bindedTextFields:Array<GUITextField> ;
	
	public function new(name:String, value:String) 
	{
		this.name = name;
		reset();
		this.value = value;
	}
	private function get_value():String {
		return value;
	}
	private function set_value(newValue:String):String {
		value = newValue;
		update();
		return value;
	}
	public function reset():Void
	{
		bindedTextFields = [];
	}
	public function registerTextField(t:GUITextField):Void
	{
		if(bindedTextFields.indexOf(t) == -1)
			bindedTextFields.push(t);
	}
	public function unregisterTextField(t:GUITextField):Void
	{
		if(bindedTextFields.indexOf(t) != -1)
			bindedTextFields.remove(t);
	}
	private function update():Void
	{
		for (textfield in bindedTextFields)
		{
			trace(textfield.sourceText);
			textfield.updateText(textfield.sourceText);
		}
	}
	
	
}