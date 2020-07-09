package gsui.transition;
import haxe.Constraints.Function;
import haxe.Json;
import haxe.xml.Access;

/**
 * @usage <actuate id="theme-button-in" type="tween" duration="0.7" properties="{height:305}" ease="Linear.easeNone" delay="0.5"/>
 * @author Ludovic Bas - www.lugludum.com
 */
enum ETransitionType
{
	TWEEN;
	APPLY;
	TRANSFORM;
	EFFECTS;
}
class Transition 
{
	public var id:String;
	public var duration:Float;
	public var properties:Dynamic;
	public var type:ETransitionType;
	public var ease:String;
	public var delay:Float;
	
	public var autoVisible:Null<Bool>;
	public var repeat:Null<Int>;
	public var reflect:Null<Bool>;
	public var reverse:Null<Bool>;
		
	public function new(id:String, properties:Dynamic, duration:Float ) 
	{
		this.id = id;
		this.duration = duration;
		this.properties = properties;
		
		this.type = TWEEN;
		this.delay = 0;
	}
	
	public function start(target:Dynamic, ?onComplete:Function):Void
	{
		throw "please override";
	}
	
	public static function create(xml:Access):Transition
	{
		return new Transition(xml.att.id,
							Json.parse(xml.att.properties),
							xml.has.duration ? Std.parseFloat(xml.att.duration) : 1);
	}
	
	public function parse(xml:Access):Transition
	{
		
		if (xml.has.type)
			this.type = Type.createEnum(ETransitionType, xml.att.type.toUpperCase());
			
		if (xml.has.ease)
		{
			this.ease = xml.att.ease;
		}
		
		if (xml.has.delay)
			this.delay = Std.parseFloat(xml.att.delay);
			
		if (xml.has.autoVisible)
			this.autoVisible = xml.att.autoVisible == "true";
			
		if (xml.has.repeat)
			this.repeat = Std.parseInt(xml.att.repeat);
			
		if (xml.has.reflect)
			this.reflect = xml.att.reflect == "true";
			
		if (xml.has.reverse)
			this.reverse = xml.att.reverse == "true";
			
		return this;
	}
	
}