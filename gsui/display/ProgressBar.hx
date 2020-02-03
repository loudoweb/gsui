package gsui.display;

import haxe.xml.Fast;
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

	var img:Bitmap;
	var cache:Bitmap;
	var cover:Bitmap;
	var _width:Int;
	
	public function new(Data:Fast, ContainerW:Float, ContainerH:Float, basePath:String) 
	{
		super();
		if(Data.has.id)
			name = Data.att.id;
		var pb_def:Fast = Data.has.def ? GUI._getDef(Data.att.def) : null;
		
		
		img = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.img ? pb_def.att.img : Data.att.img)), PixelSnapping.ALWAYS, true);
		cache = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.cache ? pb_def.att.cache : Data.att.cache)), PixelSnapping.ALWAYS, true);
		cover = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.cover ? pb_def.att.cover : Data.att.cover)), PixelSnapping.ALWAYS, true);
		
		_width = pb_def != null && pb_def.has.width ? Std.parseInt(pb_def.att.width) : Std.parseInt(Data.att.width);
		
		addChild(img);
		addChild(cache);
		addChild(cover);
		
		if (cover.height > img.height)
		{
			cover.y = Math.round((img.height - cover.height) * 0.5);
		}
		if (cover.width > img.width)
		{
			cover.x = Math.round((img.width - cover.width) * 0.5);
		}
		
		setProgress(0);
		
	}
	
	public function setProgress(f:Float):Void
	{
		img.scaleX = f * 0.01;
		cache.x = img.width - (img.width * cache.scaleX);
	}
}