package gsui.display;

import haxe.xml.Access;
import motion.Actuate;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

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
	var _bg:Bitmap;
	/**
	 * Resisable image 
	 */
	var _bar:Bitmap;
	/**
	 * Foreground image
	 */
	var _fg:Bitmap;
	
	var _mask:Rectangle;
	
	
	var _width:Int;
	
	
	
	public function new(Data:Access, ContainerW:Float, ContainerH:Float, basePath:String) 
	{
		super();
		if(Data.has.id)
			name = Data.att.id;
		var pb_def:Access = Data.has.def ? GUI._getDef(Data.att.def) : null;
		
		
		_bg = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.bg ? pb_def.att.bg : Data.att.bg)), PixelSnapping.ALWAYS, true);
		_bar = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.bar ? pb_def.att.bar : Data.att.bar)), PixelSnapping.ALWAYS, true);
		if( (pb_def != null && pb_def.has.cover) || Data.has.cover)
			_fg = new Bitmap(Assets.getBitmapData(basePath + (pb_def != null && pb_def.has.fg ? pb_def.att.fg : Data.att.fg)), PixelSnapping.ALWAYS, true);
		
		_width = pb_def != null && pb_def.has.width ? Std.parseInt(pb_def.att.width) : Std.parseInt(Data.att.width);
		
		addChild(_bg);
		addChild(_bar);
		
		_mask = new Rectangle(0, 0, 0, _bar.height);
		
		if (_fg != null)
		{
			addChild(_fg);
		
			if (_fg.height > _bg.height)
			{
				_fg.y = Math.round((_bg.height - _fg.height) * 0.5);
			}
			if (_fg.width > _bg.width)
			{
				_fg.x = Math.round((_bg.width - _fg.width) * 0.5);
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
		_mask.x = _bar.width - _bar.width * f;
		_mask.width = _bar.width * f;
		_bar.scrollRect = _mask;
		/*Actuate.tween(_mask, 2.3, {x: _bar.width - _bar.width * f, width: _bar.width * f})
		.onUpdate(function (){ _bar.scrollRect = _mask; });*/
	}
}