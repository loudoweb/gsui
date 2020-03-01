package gsui.utils;
#if html5
import js.Browser;
#end

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class PlatformUtils 
{

	public static var browserType(get, null):String;
	static var _browserType:String = "";
	
	public static var isSafariMobile(get, null):Bool = false;
	static var _isSafariMobile:Bool = false;
	
	public static var isIOSWebview(get, null):Bool = false;
	static var _isIOSWebview:Bool = false;
	
	public static function get_browserType(): String {
		if (_browserType != "")
				return _browserType;
		
		_browserType = "None";
		#if html5
		var browserAgent : String = Browser.navigator.userAgent;
		
		if (browserAgent != null) {
			
			if	(	browserAgent.indexOf("Mobile") >= 0
				||	browserAgent.indexOf("Android") >= 0
				||	browserAgent.indexOf("BlackBerry") >= 0
				||	browserAgent.indexOf("iPhone") >= 0
				||	browserAgent.indexOf("iPad") >= 0
				||	browserAgent.indexOf("iPod") >= 0
				||	browserAgent.indexOf("Opera Mini") >= 0
				||	browserAgent.indexOf("IEMobile") >= 0
				) {
				_browserType = "MOBILE";
			}
			else {
				_browserType = "DESKTOP";
			}
		}
		Browser.document.getElementsByTagName("html")[0].classList.add(_browserType.toLowerCase());
		#end	
		return _browserType;
	}
	

		
	static function get_isSafariMobile():Bool
	{
		#if html5
		var browserAgent : String = Browser.navigator.userAgent.toLowerCase();
		
		_isSafariMobile = browserAgent.indexOf("iphone") != -1 && browserAgent.indexOf("safari") != -1;
		
		if (_isSafariMobile){
			Browser.document.getElementsByTagName("html")[0].classList.add("safari");
			Browser.document.getElementsByTagName("html")[0].classList.add("iphone");
		}
		#end	
		return _isSafariMobile;
	}
	
	static function get_isIOSWebview():Bool
	{
		#if html5
		var browserAgent : String = Browser.navigator.userAgent.toLowerCase();
		
		_isIOSWebview = browserAgent.indexOf("iphone") != -1 && browserAgent.indexOf("safari") == -1;
		
		if (_isIOSWebview){
			Browser.document.getElementsByTagName("html")[0].classList.add("iphone");
			Browser.document.getElementsByTagName("html")[0].classList.add("webview");
		}
		#end	
		return _isIOSWebview;
	}
	
	
	public static function fixMobileHeight():Void
	{
		#if html5
		Browser.document.body.style.height = Browser.window.innerHeight + "px";
		#end
	}
	
	
}