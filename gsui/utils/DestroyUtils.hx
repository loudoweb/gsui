package gsui.utils;
import gsui.interfaces.IDestroyable;
import openfl.display.BitmapData;

/**
 * @author flixel
 * @author loudo
 */
class DestroyUtils
{
	/**
	 * Checks if an object is not null before calling destroy(), always returns null.
	 * 
	 * @param	object	An IDestroyable object that will be destroyed if it's not null.
	 */
	public static function destroy<T:IDestroyable>(object:Null<IDestroyable>):IDestroyable
	{
		if (object != null)
			object.destroy(); 
		return null;
	}
	
	/**
	 * Completely destroys an Array of destroyable objects:
	 * 1) Clears the array structure
	 * 2) Calls DestroyUtil.destroy() on every element
	 *
	 * @param	array	An Array of IDestroyable objects
	 */
	public static function destroyArray<T:IDestroyable>(array:Array<T>):Array<T>
	{
		if (array != null)
		{
			while (array.length > 0)
			{
				destroy(array.pop());
			}
		}
		return null;
	}
	
	/**
	 * Checks if a BitmapData object is not null before calling dispose() on it, always returns null.
	 * 
	 * @param	Bitmap	A BitampData to be disposed if not null
	 */
	public static function dispose(Bitmap:BitmapData):BitmapData
	{
		if (Bitmap != null)
			Bitmap.dispose();
		return null;
	}
}