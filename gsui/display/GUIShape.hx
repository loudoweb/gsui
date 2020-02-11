package gsui.display;

import gsui.ElementPosition;
import gsui.utils.GraphicsUtils;
import gsui.utils.ParserUtils;
import haxe.xml.Fast;
import openfl.display.Shape;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class GUIShape extends Shape 
{
	var _width:Float;
	var _height:Float;
	var _containerW:Float;
	var _containerH:Float;
	var _positions:ElementPosition;
	
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float) 
	{
		super();
		
		_width = ParserUtils.getWidth(Data, ContainerW);
		_height = ParserUtils.getHeight(Data, ContainerH);
		_containerW = ContainerW;
		_containerH = ContainerH;
		
		trace(_width, _height, _containerW, _containerH, Data.has.width, Data.has.height);
		
		if(Data.has.id)
			name = Data.att.id;
		
		var color = ParserUtils.getColor(Data);
		var alpha = ParserUtils.getColorAlpha(Data);
		
		if (Data.name == "rect")
		{
			if (!Data.has.fill || Data.att.fill == "true") 
				GraphicsUtils.drawRectFill(this.graphics, _width, _height, color, alpha);
			else
				GraphicsUtils.drawRect(this.graphics, _width, _height, color, ParserUtils.getAttInt(Data, "stroke", 1) );
		}else if (Data.name == "circle")
		{
			if (!Data.has.fill || Data.att.fill == "true") 
				GraphicsUtils.drawCircleFill(this.graphics, _width, color, alpha);
			else
				GraphicsUtils.drawCircle(this.graphics, _width, color, ParserUtils.getAttInt(Data, "stroke", 1) );
		}
		
		_positions = new ElementPosition(Data, ContainerW, ContainerH, _width, _height);
	}
	
}