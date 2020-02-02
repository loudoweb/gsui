package gsui.transition;
import gsui.utils.ParserUtils;
import haxe.Constraints.Function;
import haxe.Json;
import haxe.xml.Fast;
import motion.Actuate;
import motion.actuators.GenericActuator;
import motion.actuators.IGenericActuator;
import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.IEasing;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

/**
 * ...
 * @author Ludovic Bas - www.lugludum.com
 */
class ActuateTransition extends Transition 
{

	public function new(id:String, properties:Dynamic, duration:Float) 
	{
		super(id, properties, duration);
	}
	
	public static function create(xml:Fast):Transition
	{
		return new ActuateTransition(xml.att.id,
							Json.parse(xml.att.properties),
							xml.has.duration ? Std.parseFloat(xml.att.duration) : 1);
	}
	
	override public function start(target:Dynamic, ?onComplete:Function):Void 
	{
		var tween:IGenericActuator;
		switch(type)
		{
			case TWEEN:
				tween = Actuate.tween(target, duration, properties);
				
			case APPLY:
				tween = Actuate.apply(target, properties);
			case TRANSFORM:
				var str = Reflect.hasField(properties, "strength") ? properties.strength : 1;
				var alpha = Reflect.hasField(properties, "alpha") ? properties.alpha : null;
				tween = Actuate.transform(target, duration).color(ParserUtils.parseColor(properties.color), str, alpha);
			case EFFECTS:
				trace('${properties.filter} not implemented yet');
				tween = Actuate.effects(target, duration).filter(null, properties);
		}
		
		if (delay > 0)
			tween.delay(delay);
		
		if (ease != null)
			tween.ease(convertEase());
		
		if (autoVisible != null)
			tween.autoVisible(autoVisible);
			
		if (repeat != null)
			tween.repeat(repeat);
			
		if (reflect != null)
			tween.reflect(reflect);
			
		if (reverse != null)
			tween.reverse(reverse);
			
		if (onComplete != null)
			tween.onComplete(onComplete);
		
	}
	
	inline function convertEase():IEasing
	{
		switch(ease.toUpperCase())
		{
			case "BACK.EASEIN":
				return Back.easeIn;
			case "BACK.EASEOUT":
				return Back.easeOut;
			case "BACK.EASEINOUT":
				return Back.easeInOut;
			case "BOUNCE.EASEIN":
				return Bounce.easeIn;
			case "BOUNCE.EASEOUT":
				return Bounce.easeOut;
			case "BOUNCE.EASEINOUT":
				return Bounce.easeInOut;
			case "CUBIC.EASEIN":
				return Cubic.easeIn;
			case "CUBIC.EASEOUT":
				return Cubic.easeOut;
			case "CUBIC.EASEINOUT":
				return Cubic.easeInOut;
			case "ELASTIC.EASEIN":
				return Elastic.easeIn;
			case "ELASTIC.EASEOUT":
				return Elastic.easeOut;
			case "ELASTIC.EASEINOUT":
				return Elastic.easeInOut;
			case "EXPO.EASEIN":
				return Expo.easeIn;
			case "EXPO.EASEOUT":
				return Expo.easeOut;
			case "EXPO.EASEINOUT":
				return Expo.easeInOut;
			case "QUAD.EASEIN":
				return Quad.easeIn;
			case "QUAD.EASEOUT":
				return Quad.easeOut;
			case "QUAD.EASEINOUT":
				return Quad.easeInOut;
			case "QUART.EASEIN":
				return Quart.easeIn;
			case "QUART.EASEOUT":
				return Quart.easeOut;
			case "QUART.EASEINOUT":
				return Quart.easeInOut;
			case "QUINT.EASEIN":
				return Quint.easeIn;
			case "QUINT.EASEOUT":
				return Quint.easeOut;
			case "QUINT.EASEINOUT":
				return Quint.easeInOut;
			case "SINE.EASEIN":
				return Sine.easeIn;
			case "SINE.EASEOUT":
				return Sine.easeOut;
			case "SINE.EASEINOUT":
				return Sine.easeInOut;
			default:
				return Linear.easeNone;
		}
	}
	
}