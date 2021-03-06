package gsui.display;

import haxe.xml.Access;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;

/**
 * Place Holder for whatever you want
 * @author loudo
 */
class Slot extends Base
{

	public function new(xml:Access, parentWidth:Float, parentHeight:Float) 
	{
		super(xml, parentWidth, parentHeight);
		
	}
	
	override public function init():Void 
	{
		super.init();
		
		//TODO image resize
	}
	
	public function removeAll():Void
	{
		removeChildren();
		/*for (i in 0...numChildren)
		{
			removeChildAt(i);
		}*/
		
	}
	
	public function addImage(name:String, useCache:Bool = true):Void
	{
		if (Assets.isLocal(name))
		{
			//TODO Bitmap OR Atlas
			addChild(imageResize(new Bitmap(Assets.getBitmapData(name, useCache), PixelSnapping.AUTO, true)));
			//addChild(imageResize(new Bitmap(Assets.getBitmapData(name), PixelSnapping.AUTO, true)));
			setDirty();
		}else if (Assets.exists(name)){
			//TODO signal download
			Assets.loadBitmapData(name, useCache).onComplete(onMediaComplete);
		}
		
	}
	
	public function addGroup(name:String, useCache:Bool = true):GUIGroup
	{
		var group = GUI.getGroup(name, initWidth, initHeight, useCache);
		//group.init();
		addChild(group);
		setDirty();
		return cast group;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		removeAll();
	}
	
	function onMediaComplete(bm:BitmapData):Void
	{
		//TODO signal download ended
		addChild(imageResize(new Bitmap(bm, PixelSnapping.AUTO, true)));
		setDirty();
	}
	
	function imageResize(image:Bitmap):Bitmap
	{
		var wRatio =  initWidth / image.width;
		var hRatio = initHeight / image.height;
		
		if (wRatio < hRatio)
		{
			image.scaleX = image.scaleY = wRatio;
			image.y = (initHeight - image.height) * 0.5;
			image.x = 0;
		}else {
			image.scaleX = image.scaleY = hRatio;
			image.x = (initWidth - image.width) * 0.5;
			image.y = 0;
		}
		return image;
	}
	
}