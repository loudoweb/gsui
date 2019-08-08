package gsui.utils;
import openfl.filters.ColorMatrixFilter;

/**
 * Filters
 * //TODO cache result
 * @author loudo
 */
class FilterUtils
{

	/**
	 * Saturation 
	 * @param	sat valeur de la saturation sur un intervale de [-1;1]
	 * @return
	 */
	public static function saturate(sat:Float = 0.5):ColorMatrixFilter
	{
		//Définition des variables de luminosité, nécessaire pour calculer la teinte
		//selon l'équation de la luminosité : Y = 0,3086xR + 0,6094xG + 0,0820xB
		var Rlum = 0.3086; //Red (Rouge)
		var Glum = 0.6094; //Green (Vert)
		var Blum = 0.0820; //Blue (Bleu)

		//Calculs des valeurs RGB (Red, Green, Blue) de la matrice
		var r = (1-sat) * Rlum;
		var v = (1-sat) * Glum;
		var b = (1-sat) * Blum;
		// create an array to store your matrix values
		var matrix:Array<Float> = [r + sat, v, b, 0, 0, r, v + sat, b, 0, 0, r, v, b + sat, 0, 0, 0, 0, 0, 1, 0];
		return new ColorMatrixFilter(matrix);
	}
	
	public static var INVERT:Array<Float> = [
					-1, 0, 0, 0, 255, 
					0, -1, 0, 0, 255, 
					0, 0, -1, 0, 255,
					0, 0,  0, 1, 0,
				];
	public static var GRAY:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0, 
					0.5, 0.5, 0.5, 0, 0, 
					0.5, 0.5, 0.5, 0, 0,
					0,     0,   0, 1, 0,
				];
	public static var DEUTERANOPIA:Array<Float> = [
					0.43, 0.72, -.15, 0, 0, 
					0.34, 0.57, 0.09, 0, 0, 
					-.02, 0.03, 1   , 0, 0,
					0,    0,    0,    1, 0,
				];
	public static var PROTANOPIA:Array<Float> = [
					0.20, 0.99, -.19, 0, 0, 
					0.16, 0.79, 0.04, 0, 0, 
					0.01, -.01, 1   , 0, 0,
					0,    0,    0,    1, 0,
				];
	public static var TRITANOPIA:Array<Float> = [
					0.97, 0.11, -.08, 0, 0, 
					0.02, 0.82, 0.16, 0, 0, 
					0.06, 0.88, 0.18, 0, 0,
					0,    0,    0,    1, 0,
				];
	public static var SEPIA:Array<Float> = [	
				0.393, 0.7689999, 0.18899999, 0, 0,
				0.349, 0.6859999, 0.16799999, 0, 0,
				0.272, 0.5339999, 0.13099999, 0, 0,
				0, 0, 0, 1, 0
			];
	public static var TECHNICOLOR:Array<Float> = [
				1.9125277891456083, -0.8545344976951645, -0.09155508482755585, 0, 11.793603434377337,
				-0.3087833385928097, 1.7658908555458428, -0.10601743074722245, 0, -70.35205161461398,
				-0.231103377548616, -0.7501899197440212, 1.847597816108189, 0, 30.950940869491138,
				0, 0, 0, 1, 0
			];
	public static var POLAROID:Array<Float> = [
				1.438, -0.062, -0.062, 0, 0,
				-0.122, 1.378, -0.122, 0, 0,
				-0.016, -0.016, 1.483, 0, 0,
				0, 0, 0, 1, 0
			];
	public static var VINTAGE:Array<Float> = [
				0.6279345635605994, 0.3202183420819367, -0.03965408211312453, 0, 9.651285835294123,
				0.02578397704808868, 0.6441188644374771, 0.03259127616149294, 0, 7.462829176470591,
				0.0466055556782719, -0.0851232987247891, 0.5241648018700465, 0, 5.159190588235296,
				0, 0, 0, 1, 0
			];
	public static var BROWNI:Array<Float> = [
        0.5997023498159715, 0.34553243048391263, -0.2708298674538042, 0, 47.43192855600873,
        -0.037703249837783157, 0.8609577587992641, 0.15059552388459913, 0, -36.96841498319127,
        0.24113635128153335, -0.07441037908422492, 0.44972182064877153, 0, -7.562075277591283,
        0, 0, 0, 1, 0
    ];
	public static var LSD:Array<Float> = [
        2, -0.4, 0.5, 0, 0,
        -0.5, 2, -0.4, 0, 0,
        -0.4, -0.5, 3, 0, 0,
        0, 0, 0, 1, 0
    ];
	public static var CODACHROME:Array<Float> = [
        1.1285582396593525, -0.3967382283601348, -0.03992559172921793, 0, 63.72958762196502,
        -0.16404339962244616, 1.0835251566291304, -0.05498805115633132, 0, 24.732407896706203,
        -0.16786010706155763, -0.5603416277695248, 1.6014850761964943, 0, 35.62982807460946,
        0, 0, 0, 1, 0
    ];
	
	public static function night(intensity:Float = 0.1):Array<Float>
	{
		var matrix = [
			intensity * ( -2.0), -intensity, 0, 0, 0,
			-intensity, 0, intensity, 0, 0,
			0, intensity, intensity * 2.0, 0, 0,
			0, 0, 0, 1, 0
		];
		return matrix;
	}
	
	public static function colorTone(desaturation:Float = 0.2, toned:Float = 0.15, lightColor:Int = 0xFFE580, darkColor:Int = 0x338000):Array<Float>
	{
		var lR = ((lightColor >> 16) & 0xFF) / 255;
		var lG = ((lightColor >> 8) & 0xFF) / 255;
		var lB = (lightColor & 0xFF) / 255;
		var dR = ((darkColor >> 16) & 0xFF) / 255;
		var dG = ((darkColor >> 8) & 0xFF) / 255;
		var dB = (darkColor & 0xFF) / 255;
		var matrix = [
			0.3, 0.59, 0.11, 0, 0,
			lR, lG, lB, desaturation, 0,
			dR, dG, dB, toned, 0,
			lR - dR, lG - dG, lB - dB, 0, 0
		];
		return matrix;
	};
	
	static var DEFAULT_ROTATION:Float = 180 * Math.PI;
	public static function hue(?rotation:Float):Array<Float>
	{
		if (rotation == null)
			rotation = DEFAULT_ROTATION;
		var cos = Math.cos(rotation),
			sin = Math.sin(rotation);
		// luminanceRed, luminanceGreen, luminanceBlue
		var lumR = 0.213, // or 0.3086
			lumG = 0.715, // or 0.6094
			lumB = 0.072; // or 0.0820
		var matrix = [
			lumR + cos * (1 - lumR) + sin * (-lumR), lumG + cos * (-lumG) + sin * (-lumG), lumB + cos * (-lumB) + sin * (1 - lumB), 0, 0,
			lumR + cos * (-lumR) + sin * (0.143), lumG + cos * (1 - lumG) + sin * (0.140), lumB + cos * (-lumB) + sin * (-0.283), 0, 0,
			lumR + cos * (-lumR) + sin * (-(1 - lumR)), lumG + cos * (-lumG) + sin * (lumG), lumB + cos * (1 - lumB) + sin * (lumB), 0, 0,
			0, 0, 0, 1, 0
		];
		
		return matrix;
	}
}