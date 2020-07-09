package gsui.display;

import gsui.ElementPosition;
import gsui.utils.GraphicsUtils;
import gsui.utils.ParserUtils;
import haxe.xml.Access;
import openfl.display.Shape;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
enum EShapeType {
	RECT;
	CIRCLE;
}
class GUIShape extends Base 
{
	var color:Int;
	var colorAlpha:Float;
	var hasFill:Bool;
	var stroke:Int;
	var type:EShapeType;
	
	public function new(Data:Access, ContainerW:Float, ContainerH:Float) 
	{
		
		super(Data, ContainerW, ContainerH);
		
	}
	
	override function parse(xml:Access):Void 
	{
		super.parse(xml);
		color = ParserUtils.getColor(xml);
		colorAlpha = ParserUtils.getColorAlpha(xml);
		hasFill = !xml.has.fill || xml.att.fill == "true";
		stroke = ParserUtils.getAttInt(xml, "stroke", 1);
		type = Type.createEnum(EShapeType, xml.name.toUpperCase());
	}
	
	override public function init():Void 
	{
		
		
		this.graphics.clear();
		
		switch(type)
		{
			case RECT:
				if (hasFill) 
					GraphicsUtils.drawRectFill(this.graphics, initWidth, initHeight, color, colorAlpha);
				else
					GraphicsUtils.drawRect(this.graphics, initWidth, initHeight, color, stroke );
			case CIRCLE:
				if (hasFill) 
					GraphicsUtils.drawCircleFill(this.graphics, initWidth, color, colorAlpha);
				else
					GraphicsUtils.drawCircle(this.graphics, initWidth, color, stroke );
		}
		
		super.init();
	}
	
}