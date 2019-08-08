package gsui.utils;
import gsui.GUI.Tongue;

/**
 * ...
 * @author Loudo
 */
class ReplaceUtils
{

	public static function replaceTongue(str:String, _tongue:Tongue):String{
		//auto replace
		var ereg:EReg = ~/{\$?[0-9a-zA-Z_-]*}/g;
		var newStr:String;
		while (ereg.match(str)) {
				var variable:String = ereg.matched(0);
				variable = variable.substring(1, variable.length - 1);//remove { and }
				if (variable.indexOf("$") == 0)
				{
					str = StringTools.replace(str, "{" + variable + "}", _tongue.get(variable, "interface", true));
				}
				else{
					str = StringTools.replace(str,  "{" + variable + "}", "unknownVar");//TODO if not replace tag and not textList, so take elsewhere
				}
				
		}
		return str;
	}
	
}