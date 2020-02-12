package gsui.display;

import gsui.interfaces.IDestroyable;
import gsui.utils.ParserUtils;
import haxe.xml.Fast;
import lime.app.Event;
import openfl.events.Event in OpenEvent;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

using gsui.utils.AlignUtils;
using gsui.utils.MaskUtils;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class Base extends Sprite implements IDestroyable
{

	public var initX:Float;
	public var initY:Float;
	public var initScaleX:Float;
	public var initScaleY:Float;
	public var initWidth:Float;
	public var initHeight:Float;
	
	public var usePercentX:Bool;
	public var usePercentY:Bool;
	public var usePercentWidth:Bool;
	public var usePercentHeight:Bool;
	
	public var pivotX:Float;
	public var pivotY:Float;

	public var useParentWidth:Bool;
	public var parentWidth:Float;
	public var useParentHeight:Bool;
	public var parentHeight:Float;
	
	public var onResize:Event<Int->Int->Void>;
	
	public var hasBottom:Bool;
	public var hasRight:Bool;
	public var hasFlipX:Bool;
	public var hasFlipY:Bool;
	
	public var _mask:Rectangle;
	
	public function new(xml:Fast, parentWidth:Float, parentHeight:Float) 
	{
		super();
		
		this.parentWidth = parentWidth;
		this.parentHeight = parentHeight;
		
		onResize = new Event<Int->Int->Void>();
		
		this.addEventListener(OpenEvent.ADDED_TO_STAGE, onAdded);
		
		parse(xml);
		
		init();
		
	}
	
	function onAdded(e:OpenEvent):Void
	{
		this.removeEventListener(OpenEvent.ADDED_TO_STAGE, onAdded);
		this.addEventListener(OpenEvent.REMOVED_FROM_STAGE, onRemoved);
		
		if (usePercentX || usePercentY || hasBottom || hasRight || usePercentWidth || usePercentHeight)
		{
			//TODO call init
			if (Std.is(this.parent, Base))
			{
				var p:Base = cast this.parent;
				if(p != null)
					p.onResize.add(onParentResize);
			}
		}
	}
	
	function onRemoved(e:OpenEvent):Void
	{
		this.removeEventListener(OpenEvent.REMOVED_FROM_STAGE, onRemoved);
		this.addEventListener(OpenEvent.ADDED_TO_STAGE, onAdded);
		
		onResize.removeAll();
		
		if (usePercentX || usePercentY || hasBottom || hasRight || usePercentWidth || usePercentHeight)
		{
			//TODO call init
			if (Std.is(this.parent, Base))
			{
				var p:Base = cast this.parent;
				if(p != null)
					p.onResize.remove(onParentResize);
			}
		}
	}
	
	function onParentResize(parentWidth:Int, parentHeight:Int):Void{
		this.parentWidth = parentWidth;
		this.parentHeight = parentHeight;
		
		init();
	}
	
	function parse(xml:Fast):Void
	{
		
		if (xml.has.id)
			this.name = xml.att.id;
		
		//{ SIZE
		
		if (xml.has.width)
		{
			useParentWidth = false;
			usePercentWidth = ParserUtils.hasPercent(xml.att.width);
			initWidth = ParserUtils.getWidth(xml, parentWidth);
		}else{
			useParentWidth = true;
			usePercentWidth = false;
			initWidth = parentWidth;
		}
	
		if (xml.has.height)
		{
			useParentHeight = false;
			usePercentHeight = ParserUtils.hasPercent(xml.att.height);
			initHeight = ParserUtils.getHeight(xml, parentHeight);
		}else{
			useParentHeight = true;
			usePercentHeight = false;
			initHeight = parentHeight;
		}
		//}
		
		//{ POSITION
		
		hasFlipX = xml.has.flipX;
		hasFlipY = xml.has.flipY;
		
		hasBottom = xml.has.bottom;
		hasRight = xml.has.right;
		
		if (xml.has.pivot)
		{
			var pivots = xml.att.pivot.split(',');
			pivotX = Std.parseFloat(pivots[0]);
			pivotY = Std.parseFloat(pivots[1]);
		}
		
		if (xml.has.x)
		{
			if (xml.att.x == "center")
			{
				usePercentX = true;
				initX = 0.5;
				pivotX = 0.5;
			}else{
				usePercentX = ParserUtils.hasPercent(xml.att.x);
				initX = ParserUtils.getAttFloat(xml, "x", 0);
			}
		}else if (hasRight){
			usePercentX = ParserUtils.hasPercent(xml.att.right);
			initX = ParserUtils.getAttFloat(xml, "right", 0);
			pivotX = 1;
		}else{
			initX = 0;
			usePercentX = false;
		}
		
		if (xml.has.y)
		{
			if (xml.att.y == "center")
			{
				usePercentY = true;
				initY = 0.5;
				pivotY = 0.5;
			}else{
				usePercentY = ParserUtils.hasPercent(xml.att.y);
				initY = ParserUtils.getAttFloat(xml, "y", 0);
			}
		}else if (hasBottom){
			usePercentY = ParserUtils.hasPercent(xml.att.bottom);
			initY = ParserUtils.getAttFloat(xml, "bottom", 0);
			pivotY = 1;
		}else{
			initY = 0;
			usePercentY = false;
		}
		
		//}
		
		//{ MASK
		
		/*if (xml.has._maskW && xml.has._maskH)
		{
			_mask = new Rectangle(0, 0, Std.parseFloat(xml.att._maskW), Std.parseFloat(xml.att._maskH));
		}
		
		if(pos._mask != null)
			this.create_mask(pos._mask);*/
			
		//}
		
			
		if (xml.has.scale)
			initScaleX = initScaleY = Std.parseFloat(Std.string(xml.att.scale));
		if (xml.has.sW)
			initScaleX = Std.parseFloat(Std.string(xml.att.sW));
		if (xml.has.sH)
			initScaleY = Std.parseFloat(Std.string(xml.att.sH));
		
		
		if (xml.has.a)
			rotation = Std.parseFloat(Std.string(xml.att.a));
		if (xml.has.visible) 
			visible = xml.att.visible == "true";
			
		/*if (el.has.effect && el.att.effect != "")
			_effect(this, Type.createEnum(EGUIEffect, el.att.effect.toUpperCase()));*/
		
		xml = null;
	}
	
	public function init():Void
	{
		
		if (usePercentX &&  !hasRight)
		{
			x = initX * parentWidth - pivotX * initWidth;
		}else if (hasRight)
		{
			if (usePercentX)
			{
				x = parentWidth - initX * parentWidth - pivotX * initWidth;
			}else{
				x = parentWidth - initX - pivotX * initWidth;
			}
			
			
		}else{
			x = initX;
		}
			
		if (usePercentY && !hasBottom)
		{
			y = initY * parentHeight - pivotY * initHeight;
		}else if (hasBottom)
		{
			if (usePercentY)
			{
				y = parentHeight - initY * parentHeight - pivotY * initHeight;
			}else{
				y = parentHeight - initY - pivotY * initHeight;
			}
			
		}else{
			y = initY;
		}
		
		if (hasFlipX){
			scaleX = -initScaleX;
			x += width;
		}
		if (hasFlipY){
			scaleY = -initScaleY;
			y += height;
		}
		
	}
	
	public function destroy():Void
	{
		_mask = null;
		if (onResize != null)
			onResize.removeAll();
	}
}