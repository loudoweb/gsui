package gsui;
import openfl.geom.Rectangle;
import haxe.xml.Access;

/**
 * Helper to calculate position of element when the element is created
 * @author loudo
 */
class ElementPosition
{
	public var x:Float = 0;
	public var y:Float = 0;
	
	public var hasOver:Bool = false;
	public var x_hover:Float = 0;
	public var y_hover:Float = 0;
	
	public var pivotX:Float = 0;
	public var pivotY:Float = 0;
	
	public var hasSelected:Bool = false;
	public var x_selected:Float = 0;
	public var y_selected:Float = 0;
	
	public var mask:Rectangle = null;//mask isn't working everywhere so use scrollrect
	public var maskOver:Rectangle = null;
	public var maskSelected:Rectangle = null;
	
	public var parentWidth:Float;
	public var parentHeight:Float;
	
	public function new(fast:Access, parentWidth:Float, parentHeight:Float, elementWidth:Float, elementHeight:Float) 
	{
		init(fast, parentWidth, parentHeight, elementWidth, elementHeight);
	}
	
	public function init(fast:Access, parentWidth:Float, parentHeight:Float, elementWidth:Float, elementHeight:Float)
	{
		this.parentWidth = parentWidth;
		this.parentHeight = parentHeight;
		
		if (fast != null) {
			
			if (fast.has.pivot)
			{
				var pivots = fast.att.pivot.split(',');
				pivotX = Std.parseFloat(pivots[0]);
				pivotY = Std.parseFloat(pivots[1]);
			}
			
			if (fast.has.x) {
				x = fast.att.x == "center" ? (parentWidth  - elementWidth) * 0.5 : Std.parseFloat(fast.att.x) - pivotX * elementWidth;
			}else if (fast.has.right) {
				x = parentWidth  - Std.parseFloat(fast.att.right) - elementWidth - pivotX * elementWidth;
			}
			if (fast.has.y) {
				y =  fast.att.y == "center" ? (parentHeight  - elementHeight) * 0.5 : Std.parseFloat(fast.att.y) - pivotY * elementHeight;
			}else if (fast.has.bottom) {
				y = parentHeight - Std.parseFloat(fast.att.bottom) - elementHeight - pivotY * elementHeight;
			}
			
			if (fast.has.maskW && fast.has.maskH)
			{
				mask = new Rectangle(0, 0, Std.parseFloat(fast.att.maskW), Std.parseFloat(fast.att.maskH));
			}
			//other states
			hasOver = fast.has.hover || fast.has.hoverX || fast.has.hoverY ? true : false;
			if (hasOver) {
				if (fast.has.hoverX) {
					x_hover = fast.att.hoverX == "center" ? (parentWidth  - elementWidth) * 0.5 : Std.parseFloat(fast.att.hoverX);
				}
				if (fast.has.hoverY) {
					y_hover =  fast.att.hoverY == "center" ? (parentHeight  - elementHeight) * 0.5 : Std.parseFloat(fast.att.hoverY);
				}
				if (fast.has.hoverMaskW && fast.has.hoverMaskH)
				{
					maskOver = new Rectangle(0, 0, Std.parseFloat(fast.att.hoverMaskW), Std.parseFloat(fast.att.hoverMaskH));
				}
			}
			hasSelected = fast.has.selected || fast.has.selectedX || fast.has.selectedY ? true : false;
			if (hasSelected) {
				if (fast.has.selectedX) {
					x_selected = fast.att.selectedX == "center" ? (parentWidth  - elementWidth) * 0.5 : Std.parseFloat(fast.att.selectedX);
				}
				if (fast.has.selectedY) {
					y_selected =  fast.att.selectedY == "center" ? (parentHeight  - elementHeight) * 0.5 : Std.parseFloat(fast.att.selectedY);
				}
				if (fast.has.selectedMaskW && fast.has.selectedMaskH)
				{
					maskSelected = new Rectangle(0, 0, Std.parseFloat(fast.att.selectedMaskW), Std.parseFloat(fast.att.selectedMaskH));
				}
			}
			fast = null;
		}else {
			trace("ElementPosition don't have any parameter");
		}
	}
	
	public function vAlign(elementHeight:Float):Float
	{
		y =  (parentHeight  - elementHeight) * 0.5;
		return y;
	}
	public function hAlign(elementWidth:Float):Float
	{
		x = (parentWidth - elementWidth) * 0.5;
		return x;
	}
	
}