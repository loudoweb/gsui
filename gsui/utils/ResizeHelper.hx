package gsui.utils;
import lime.app.Event;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.geom.Point;

enum EOrientation {
	LANDSCAPE;
	PORTRAIT;
}
/**
 * Resize Helper. Resize content for you and allow to retrieve easily information about current size of resizing.
 * @author Loudo
 */
class ResizeHelper
{
	public static var RATIO:Float;
	
	public static var WIDTH:Int;
	public static var HEIGHT:Int;
	
	/**
	 * recommended width for standard resizing is standard HD = 1920
	 * recommended width for responsive resizing is iphone width = 750
	 */
	public static var ORIGIN_WIDTH:Int = 1920;
	/**
	 * recommended width for standard resizing is standard HD = 1080
	 * recommended width for responsive resizing is iphone height = 1334
	 */
	public static var ORIGIN_HEIGHT:Int = 1080;
	
	public static var ORIENTATION:EOrientation = LANDSCAPE;
	public static var STAGE:Stage;
	
	/**
	 * Position of the container on the screen
	 */
	public static var POS:Point = new Point();
	
	//events
	public static var onResize:Event<Void -> Void> = new Event<Void -> Void>();

	/**
	 * Standard letter-boxed resizing. The container will be centered and resized proportionnaly to the origin width and height.
	 * You should set STAGE first.
	 * @param	container to resize
	 * @parem	mask to resize if any
	 */
	public static function resize(container:DisplayObject, ?mask:DisplayObject):Void
	{
		WIDTH = STAGE.stageWidth;
		HEIGHT = STAGE.stageHeight;
				
		ORIENTATION = WIDTH > HEIGHT ? LANDSCAPE : PORTRAIT;
		
		var wRatio = WIDTH / ORIGIN_WIDTH;
		var hRatio = HEIGHT / ORIGIN_HEIGHT;
		
		if (wRatio < hRatio)
		{
			container.scaleX = container.scaleY = RATIO = wRatio;
			container.y = (HEIGHT - ORIGIN_HEIGHT * wRatio) * 0.5;
			container.x = 0;
		}else {
			container.scaleX = container.scaleY = RATIO = hRatio;
			container.x = (WIDTH - ORIGIN_WIDTH * hRatio) * 0.5;
			container.y = 0;
		}
		
		
		POS.x = container.x;
		POS.y = container.y;
		
		if (mask != null)
		{
			mask.x = container.x;
			mask.y = container.y;
			mask.scaleX = mask.scaleY = RATIO;
		}
		
		
		trace(WIDTH + ' x ' + HEIGHT, RATIO, POS, ORIGIN_WIDTH, ORIGIN_HEIGHT);
		
		onResize.dispatch();
	}
	
	/**
	 * Standard letter-boxed resizing on LANDSCAPE and width-based resizing on PORTRAIT.
	 * The container will be centered and resized proportionnaly to the origin width and height on LANDSCAPE.
	 * The container will be resized to full width on PORTRAIT, scrolling could be needed to see the bottom of the container
	 * It is recommmended to make your mock-up on 750x1334 and use floating group to fill the empty space on left and right in LANDSCAPE mode to have maximum readability on both orientations.
	 * You should set STAGE first.
	 * @param	container to resize
	 * @parem	mask to resize if any
	 */
	public static function resizeResponsive(container:DisplayObject, ?mask:DisplayObject):Void
	{
		WIDTH = STAGE.stageWidth;
		HEIGHT = STAGE.stageHeight;
				
		ORIENTATION = WIDTH > HEIGHT ? LANDSCAPE : PORTRAIT;
				
		switch(ORIENTATION)
		{
			case PORTRAIT:
				
				var wRatio = WIDTH / ORIGIN_WIDTH;
				container.scaleX = container.scaleY = RATIO = wRatio;
				
				container.y = 0;
				container.x = 0;
				
				if (mask != null)
				{
					mask.x = 0;
				}
				
			case LANDSCAPE:
				var hRatio = HEIGHT / ORIGIN_HEIGHT;

				container.scaleX = container.scaleY = RATIO = hRatio;
				container.x = (WIDTH - ORIGIN_WIDTH * hRatio) * 0.5;
				container.y = 0;
				
				if (mask != null)
				{
					mask.x = (WIDTH - ORIGIN_WIDTH * hRatio) * 0.5;
				}
				
		}
		
		POS.x = container.x;
		POS.y = container.y;
		
		if (mask != null)
		{
			mask.y = 0;
			mask.scaleX = mask.scaleY = RATIO;
		}

		
		trace(WIDTH + ' x ' + HEIGHT, RATIO, POS, ORIGIN_WIDTH, ORIGIN_HEIGHT);
		
		onResize.dispatch();
		
	}
	
	/**
	 * Standard letter-boxed resizing on LANDSCAPE and width-based resizing on PORTRAIT.
	 * The container will be centered and resized proportionnaly to the origin width and height on LANDSCAPE.
	 * The container will be resized to full width on PORTRAIT, scrolling could be needed to see the bottom of the container
	 * It is recommmended to make your mock-up on 750x1334 and use floating group to fill the empty space on left and right in LANDSCAPE mode to have maximum readability on both orientations.
	 * You should set STAGE first.
	 * @param	container to resize
	 * @parem	mask to resize if any
	 */
	public static function resizeScrollable(container:DisplayObject, ?mask:DisplayObject):Void
	{
		WIDTH = STAGE.stageWidth;
		HEIGHT = STAGE.stageHeight;
				
		ORIENTATION = WIDTH > HEIGHT ? LANDSCAPE : PORTRAIT;
				
		
				
		var wRatio = WIDTH / ORIGIN_WIDTH;
		container.scaleX = container.scaleY = RATIO = wRatio;
		
		container.y = 0;
		container.x = 0;
		
		if (mask != null)
		{
			mask.x = 0;
		}
				
			
		
		POS.x = container.x;
		POS.y = container.y;
		
		if (mask != null)
		{
			mask.y = 0;
			mask.scaleX = mask.scaleY = RATIO;
		}

		
		trace(WIDTH + ' x ' + HEIGHT, RATIO, POS, ORIGIN_WIDTH, ORIGIN_HEIGHT);
		
		onResize.dispatch();
		
	}
	
}