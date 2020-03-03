package gsui;
import gsui.display.GUIGroup;
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
	public var value(default,set):String;
	public var bindedTextFields:Array<GUITextField> ;
	public var bindedGroups:Array<GUIGroup> ;
	
	public function new(name:String, value:String) 
	{
		this.name = name;
		bindedTextFields = [];
		bindedGroups = [];
		this.value = value;
	}
	private function set_value(newValue:String):String {
		value = newValue;
		update();
		return value;
	}
	public function reset():Void
	{
		bindedTextFields.splice(0, bindedTextFields.length);
		bindedGroups.splice(0, bindedGroups.length);
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
	public function registerGroup(t:GUIGroup):Void
	{
		if(bindedGroups.indexOf(t) == -1)
			bindedGroups.push(t);
	}
	public function unregisterGroup(t:GUIGroup):Void
	{
		if(bindedGroups.indexOf(t) != -1)
			bindedGroups.remove(t);
	}
	private function update():Void
	{
		for (textfield in bindedTextFields)
		{
			textfield.updateText(textfield.sourceText);
		}
		for (group in bindedGroups)
		{
			group.state = value;
		}
	}
	public function destroy():Void
	{
		bindedTextFields = null;
		bindedGroups = null;
	}
	
	
}