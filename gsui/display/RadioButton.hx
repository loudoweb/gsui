package gsui.display;
import haxe.xml.Fast;
import openfl.display.BitmapData;

/**
 * Radio button
 * @author loudo
 */
class RadioButton extends CheckBox
{

	public var groupName:String;
	
	public function new(data:Fast, bg:BitmapData, check:BitmapData, containerW:Float, containerH:Float) 
	{
		groupName = data.has.groupName ? data.att.groupName : "";
		super(data, bg, check, containerW, containerH);
	}
	
	override public function select():Void
	{
		if (_check != null) {
			if (!checked) {
				checked = true;
				addChild(_check);
				if (parent != null) {
					var connectedRadio = cast(parent, GUIGroup).getChildrenByType(RadioButton);
					for (it in connectedRadio) 
					{
						if(it != this)
							it.unselect();
					}
				}
			}
		}
	}
	
}