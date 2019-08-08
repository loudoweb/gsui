package gsui;

/**
 * Create a variable and add as many textfields you like, when the value changes, the textfields will be updated
 * //TODO use generic <T> and not TextField but what to do with textfield.text = value ? ...=>typedef ?
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
		bindedTextFields.push(t);
	}
	private function update():Void
	{
		for (textfield in bindedTextFields)
		{
			textfield.text = value;
		}
	}
	
	
}