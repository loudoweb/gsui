package gsui.display;

import haxe.xml.Fast;
import motion.Actuate;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * Progress bar
 * TODO animate
 * @author loudo
 */
class ProgressBar extends Sprite
{
	@:isVar public var value(default, set):Float;
	/**
	 * Background
	 */
	var _img:Bitmap;
	/**
	 * Resisable image 
	 */
	var _cache:Bitmap;
	/**
	 * Foreground image
	 */
	var _cover:Bitmap;
	var _width:Int;
	
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float, basePath:String) 
	{
		super();
		if(Data.has.id)
			name = Data.att.id;
		var pb_def:Fast = Data.has.def ? GUI._getDef(Data.att.def) : null;
		
		
		_img = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.img ? pb_def.att.img : Data.att.img)), PixelSnapping.ALWAYS, true);
		_cache = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.cache ? pb_def.att.cache : Data.att.cache)), PixelSnapping.ALWAYS, true);
		if( (pb_def != null && pb_def.has.cover) || Data.has.cover)
			_cover = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.cover ? pb_def.att.cover : Data.att.cover)), PixelSnapping.ALWAYS, true);
		
		_width = pb_def != null && pb_def.has.width ? Std.parseInt(pb_def.att.width) : Std.parseInt(Data.att.width);
		
		addChild(_img);
		addChild(_cache);
		
		if (_cover != null)
		{
			addChild(_cover);
		
			if (_cover.height > _img.height)
			{
				_cover.y = Math.round((_img.height - _cover.height) * 0.5);
			}
			if (_cover.width > _img.width)
			{
				_cover.x = Math.round((_img.width - _cover.width) * 0.5);
			}
		}
		
		value = 0;
		
	}
	
	public function set_value(f:Float):Float
	{
		value = f;
		setProgress(f);
		return f;
	}
	
	public function setProgress(f:Float):Void
	{
		_img.scaleX = f * 0.01;
		_cache.x = _img.width - (_img.width * _cache.scaleX);
		//Actuate.tween(_img, 0.4, {scaleX: f * 0.01});
		//Actuate.tween(_cache, 0.4, {x: _img.width - (_img.width * _cache.scaleX)});
	}
}