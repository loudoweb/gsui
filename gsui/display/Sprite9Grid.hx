package gsui.display;

import gsui.utils.DestroyUtils;
import haxe.xml.Fast;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * @author Lars Doucet
 * @author loudo
 */
class Sprite9Grid extends Base
{
	private var _bmpCanvas:BitmapData; //drives the 9-slice drawing
	
	private var _slice9:Array<Int> = null;
	
	//TODO utiliser pour cacher tous les sprites créés par cette classe
	/*
	private static var useSectionCache:Bool = true;
	private static var sectionCache:Map<String,BitmapData>;
	private var _asset_id:String = "";
	*/
	
	private var _raw_pixels:BitmapData;
	
	//for internal static use
	private static var _staticPoint:Point = new Point();
	private static var _staticRect:Rectangle = new Rectangle();
	private static var _staticRect2:Rectangle = new Rectangle();
	
	private static var _staticPointZero:Point = new Point(0, 0);	//ALWAYS 0,0
	private static var _staticMatrix:Matrix = new Matrix();
	
	private static var _staticFlxRect:Rectangle = new Rectangle();
	private static var _staticFlxRect2:Rectangle = new Rectangle();
	
	//specialty smoothing modes	
	public static inline var TILE_NONE:Int = 0x00;
	public static inline var TILE_BOTH:Int = 0x11;
	public static inline var TILE_H:Int = 0x10;
	public static inline var TILE_V:Int = 0x01;
	
	//rectangle map
	private static var _staticRects:Map<String,Rectangle>;
	
	/**
	 * 
	 * @param	Graphic
	 * @param	Width
	 * @param	Height
	 */
	public function new(xml:Fast, Graphic:BitmapData, Width:Int, Height:Int) 
	{
		_raw_pixels = Graphic;
		super(xml, Width, Height);
		mouseEnabled = false;
	}
	
	override function onAdded(e:Event):Void 
	{
		super.onAdded(e);
	}
	
	override public function init():Void 
	{
		resize(Std.int(initWidth), Std.int(initHeight));
		super.init();
	}
	
	public function resize(w:Int, h:Int):Void {
		var ptX:Int = Std.int(_raw_pixels.width / 3);
		var ptY:Int = Std.int(_raw_pixels.width / 3);
		
		_slice9 = [ptX, ptY, _raw_pixels.width-ptX, _raw_pixels.height-ptY];
		
		
		_bmpCanvas = new BitmapData(Std.int(w), Std.int(h));
		
		_staticFlxRect.x = 0;
		_staticFlxRect.y = 0;
		_staticFlxRect.width = w;
		_staticFlxRect.height = h;
		
		paintScale9(_bmpCanvas, _raw_pixels, _staticFlxRect);
		
		addChild(new Bitmap(_bmpCanvas, PixelSnapping.ALWAYS, true));
	}
	
		
	//These functions were borrowed from:
	//https://github.com/ianharrigan/YAHUI/blob/master/src/yahui/style/StyleHelper.hx
	
	/**
	 * Does the actual drawing for a 9-slice scaled graphic
	 * @param	g the graphics object for drawing to
	 * @param 	raw raw pixels supplied, if any
	 * @param	rc rectangle object defining how big you want to scale it to
	 */
	
	public function paintScale9(g:BitmapData, raw:BitmapData, rc:Rectangle):Void {
		if (_slice9 != null) { // create parts
			
			var w:Int = raw.width;
			var h:Int = raw.height;
			
			var x1:Int = _slice9[0];
			var y1:Int = _slice9[1];
			var x2:Int = _slice9[2];
			var y2:Int = _slice9[3];

			if (_staticRects == null) {
				_staticRects = new Map<String,Rectangle>();
				_staticRects.set("top.left", new Rectangle(0, 0, x1, y1));
				_staticRects.set("top", new Rectangle(x1, 0, x2-x1, y1));
				_staticRects.set("top.right", new Rectangle(x2, 0, w-x2, y1));
				_staticRects.set("left", new Rectangle(0, y1, x1, y2-y1));
				_staticRects.set("middle", new Rectangle(x1, y1, x2-x1, y2-y1));
				_staticRects.set("right", new Rectangle(x2, y1, w-x2, y2-y1));
				_staticRects.set("bottom.left", new Rectangle(0, y2, x1, h-y2));
				_staticRects.set("bottom", new Rectangle(x1, y2, x2-x1, h-y2));
				_staticRects.set("bottom.right", new Rectangle(x2, y2, w-x2, h-y2));
			}
			
			paintCompoundBitmap(g, _staticRects, rc, raw);
		}
	}

	public function paintCompoundBitmap(g:BitmapData, sourceRects:Map<String,Rectangle>, targetRect:Rectangle, raw:BitmapData=null):Void {
		var fillcolor = #if (neko) { rgb:0x00FFFFFF, a:0 }; #else 0x00FFFFFF; #end
		
		// top row
		var tl:Rectangle = sourceRects.get("top.left");
		if (tl != null) {
			_staticFlxRect2.setTo(0, 0, tl.width, tl.height);
			paintBitmapSection(g, tl, _staticFlxRect2,null,TILE_NONE,raw);
		}

		var tr:Rectangle = sourceRects.get("top.right");
		if (tr != null) {
			_staticFlxRect2.setTo(targetRect.width - tr.width, 0, tr.width, tr.height);
			paintBitmapSection(g, tr, _staticFlxRect2,null,TILE_NONE,raw);
		}

		var t:Rectangle = sourceRects.get("top");
		if (t != null) {
			_staticFlxRect2.setTo(tl.width, 0, (targetRect.width - tl.width - tr.width), t.height);
			paintBitmapSection(g, t, _staticFlxRect2,null,TILE_H,raw);
		}

		// bottom row
		var bl:Rectangle = sourceRects.get("bottom.left");
		if (bl != null) {
			_staticFlxRect2.setTo(0, targetRect.height - bl.height, bl.width, bl.height);
			paintBitmapSection(g, bl, _staticFlxRect2,null,TILE_NONE,raw);
		}

		var br:Rectangle = sourceRects.get("bottom.right");
		if (br != null) {
			_staticFlxRect2.setTo(targetRect.width - br.width, targetRect.height - br.height, br.width, br.height);
			paintBitmapSection(g, br, _staticFlxRect2,null,TILE_NONE,raw);
		}

		var b:Rectangle = sourceRects.get("bottom");
		if (b != null) {
			_staticFlxRect2.setTo(bl.width, targetRect.height - b.height, (targetRect.width - bl.width - br.width), b.height);
			paintBitmapSection(g, b, _staticFlxRect2,null,TILE_H,raw);
		}

		// middle row
		var l:Rectangle = sourceRects.get("left");
		if (l != null) {
			_staticFlxRect2.setTo(0, tl.height, l.width, (targetRect.height - tl.height - bl.height));
			paintBitmapSection(g, l, _staticFlxRect2,null, TILE_V,raw);
		}

		var r:Rectangle = sourceRects.get("right");
		if (r != null) {
			_staticFlxRect2.setTo(targetRect.width - r.width, tr.height, r.width, (targetRect.height - tl.height - bl.height));
			paintBitmapSection(g, r, _staticFlxRect2,null, TILE_V,raw);
		}

		var m:Rectangle = sourceRects.get("middle");
		if (m != null) {
			_staticFlxRect2.setTo(l.width, t.height, (targetRect.width - l.width - r.width), (targetRect.height - t.height - b.height));
			paintBitmapSection(g, m, _staticFlxRect2,null,TILE_BOTH,raw);
		}
	}

	public function paintBitmapSection(g:BitmapData, src:Rectangle, dst:Rectangle, srcData:BitmapData = null, tile:Int = TILE_NONE, raw:BitmapData):Void {
		if (srcData == null) {
			srcData = raw;
		}

		src.x = Std.int(src.x);
		src.y = Std.int(src.y);
		src.width = Std.int(src.width);
		src.height = Std.int(src.height);
		
		dst.x = Std.int(dst.x);
		dst.y = Std.int(dst.y);
		dst.width = Std.int(dst.width);
		dst.height = Std.int(dst.height);

		var fillcolor = 0x00FFFFFF;
		var section:BitmapData = new BitmapData(Std.int(src.width), Std.int(src.height), true, fillcolor);
		
		_staticRect2.x = src.x;
		_staticRect2.y = src.y;
		_staticRect2.width = src.width;
		_staticRect2.height = src.height;
		
		section.copyPixels(srcData, _staticRect2, _staticPointZero);	

		if (dst.width > 0 && dst.height > 0) {
			
			_staticRect2.x = dst.x;
			_staticRect2.y = dst.y;
			_staticRect2.width = dst.width;
			_staticRect2.height = dst.height;
			
			bitmapFillRect(g, _staticRect2, section, tile);
		}
	}
	
	private function bitmapFillRect(g:BitmapData, dst:Rectangle, section:BitmapData, tile:Int=TILE_NONE, smooth_:Bool=false):Void {
		
		//Optimization TODO:
		//You can remove the extra bitmap being created by smartly figuring out
		//the necessary math for drawing directly to g rather than a temp bmp
		
		//temporary bitmap data, representing the area we want to fill
		var final_pixels:BitmapData = new BitmapData(Std.int(dst.width), Std.int(dst.height),true,0x00000000);
		
		_staticMatrix.identity();
		
		//_staticRect represents the size of the section object, after any scaling is done
		_staticRect.x = 0;
		_staticRect.y = 0;
		_staticRect.width = section.width;
		_staticRect.height = section.height;
		
		if (tile & 0x10 == 0) {							//TILE H is false
			_staticMatrix.scale(dst.width / section.width, 1.0);	//scale H
			_staticRect.width = dst.width;				//_staticRect reflects scaling
		}
		if (tile & 0x01 == 0) {							//TILE V is false
			_staticMatrix.scale(1.0, dst.height / section.height);//scale V
			_staticRect.height = dst.height;			//_staticRect reflects scaling
		}
		
		//draw the first section
		//if tiling is false, this is all that needs to be done as
		//the section's h&v will exactly equal the destination size
		//final_pixels.draw(section, _staticMatrix, null, null, null, smooth);
				
		if (section.width == dst.width && section.height == dst.height) {
			_staticPoint.x = 0;
			_staticPoint.y = 0;
			final_pixels.copyPixels(section, section.rect, _staticPoint);
		}else {
			if(smooth_){
				final_pixels.draw(section, _staticMatrix, null, null, null, true);
			}else {
				final_pixels.draw(section, _staticMatrix, null, null, null, false);
			}
		}
		
		//if we are tiling, we need to keep drawing
		if (tile != TILE_NONE) {
			
			//_staticRect currently represents rect of what we've drawn so far
			
			var th:Int = tile & 0x10;
			
			if (tile & 0x10 == 0x10) {	//TILE H is true
				
				_staticPoint.x = 0;	//drawing destination
				_staticPoint.y = 0;
				
				while (_staticPoint.x < dst.width) {		//tile across the entire width
					_staticPoint.x += _staticRect.width;	//jump to next drawing location
					
					//copy section drawn so far, re-draw at next tiling point
					final_pixels.copyPixels(final_pixels, _staticRect, _staticPoint);
					
					//NOTE:
					//This method assumes that copyPixels() will safely observe
					//buffer boundaries on all targets. If this is not true, a
					//buffer overflow vunerability could exist here and would
					//need to be fixed by checking the boundary size and using
					//a custom-sized final call to fill in the last few pixels
				}
			}
			if (tile & 0x01 == 0x01) {	//TILE V is true
				
				_staticPoint.x = 0;	//drawing destination
				_staticPoint.y = 0;
				
				//assume that the entire width has been spanned by now
				_staticRect.width = final_pixels.width;	
				
				while (_staticPoint.y < dst.height) {		//tile across the entire height
					_staticPoint.y += _staticRect.height;	//jump to next drawing location
					
					//copies section drawn so far, like above, but starts with 
					//the entire first row of drawn pixels
					final_pixels.copyPixels(final_pixels, _staticRect, _staticPoint);
					
					//NOTE: 
					//See note above, same thing applies here.
				}
			}
		}
		
		//set destination point
		_staticPoint.x = dst.x;
		_staticPoint.y = dst.y;
		
		//copy the final filled area to the original target bitmap data
		g.copyPixels(final_pixels, final_pixels.rect, _staticPoint);
		
		//now that the pixels have been copied, trash the temporary bitmap data:
		final_pixels = DestroyUtils.dispose(final_pixels);
	}
}