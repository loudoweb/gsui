package gsui.utils;

import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * A class containing a set of math-related functions.
 * @author flixel
 */
class MathUtils {
	#if (flash || js || ios)
	/**
	 * Minimum value of a floating point number.
	 */
	public static inline var MIN_VALUE:Float = 0.0000000000000001;
	#else

	/**
	 * Minimum value of a floating point number.
	 */
	public static inline var MIN_VALUE:Float = 5e-324;
	#end

	/**
	 * Maximum value of a floating point number.
	 */
	public static inline var MAX_VALUE:Float = 1.79e+308;

	/**
	 * Approximation of Math.sqrt(2).
	 */
	public static inline var SQUARE_ROOT_OF_TWO:Float = 1.41421356237;

	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 * Ex: roundDecimal(1.2485, 2) -> 1.25
	 * 
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimal points to leave in float. Should be a positive number
	 * @return	The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float {
		var mult:Float = 1;
		for (i in 0...Precision) {
			mult *= 10;
		}
		return Math.round(Value * mult) / mult;
	}

	/**
	 * Bound a number by a minimum and maximum. Ensures that this number is 
	 * no smaller than the minimum, and no larger than the maximum.
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	public static inline function bound(Value:Float, Min:Float, Max:Float):Float {
		var lowerBound:Float = (Value < Min) ? Min : Value;
		return (lowerBound > Max) ? Max : lowerBound;
	}

	/**
	 * Returns linear interpolated value between Max and Min numbers
	 *
	 * @param Min 		Lower bound.
	 * @param Max	 	Higher bound.
	 * @param Ratio 	Defines which number is closer to desired value.
	 * @return 			Interpolated number.
	 */
	public static inline function lerp(Min:Float, Max:Float, Ratio:Float):Float {
		return Min + Ratio * (Max - Min);
	}

	/**
	 * Checks if number is in defined range.
	 *
	 * @param Value		Number to check.
	 * @param Min		Lower bound of range.
	 * @param Max 		Higher bound of range.
	 * @return Returns true if Value is in range.
	 */
	public static inline function inBounds(Value:Float, Min:Float, Max:Float):Bool {
		return ((Value > Min) && (Value < Max));
	}

	/**
	 * Returns true if the number given is odd.
	 * 
	 * @param	n	The number to check 
	 * @return	True if the given number is odd. False if the given number is even.
	 */
	public static function isOdd(n:Float):Bool {
		if ((Std.int(n) & 1) != 0) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Returns true if the number given is even.
	 * 
	 * @param	n	The number to check
	 * @return	True if the given number is even. False if the given number is odd.
	 */
	public static function isEven(n:Float):Bool {
		if ((Std.int(n) & 1) != 0) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * Compare two numbers.
	 * 
	 * @param	num1	The first number
	 * @param	num2	The second number
	 * @return	-1 if num1 is smaller, 1 if num2 is bigger, 0 if they are equal
	 */
	public static function numericComparison(num1:Float, num2:Float):Int {
		if (num2 > num1) {
			return -1;
		} else if (num1 > num2) {
			return 1;
		}
		return 0;
	}

	/**
	 * Returns true if the given x/y coordinate is within the given rectangular block
	 * 
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rectX		The X value of the region to test within
	 * @param	rectY		The Y value of the region to test within
	 * @param	rectWidth	The width of the region to test within
	 * @param	rectHeight	The height of the region to test within
	 * 
	 * @return	true if pointX/pointY is within the region, otherwise false
	 */
	public static function pointInCoordinates(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float):Bool {
		if (pointX >= rectX && pointX <= (rectX + rectWidth)) {
			if (pointY >= rectY && pointY <= (rectY + rectHeight)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Returns true if the given x/y coordinate is within the quadrilaterl
	 * @param	pointX
	 * @param	pointY
	 * @param	tl quadrilateral top left point
	 * @param	tr quadrilateral top right point
	 * @param	bl quadrilateral bottom left point
	 * @param	br quadrilateral bottom right point
	 * @return
	 */
	public static function pointInQuadrilateral(pointX:Float, pointY:Float, tl:Point, tr:Point, bl:Point, br:Point):Bool {
		if (leftSide(pointX, pointY, bl, tl) && rightSide(pointX, pointY, br, tr)) {
			if (leftSide(pointX, pointY, tl, tr) && rightSide(pointX, pointY, bl, br)) {
				return true;
			}
		}
		return false;
	}

	inline public static function leftSide(x:Float, y:Float, a:Point, b:Point):Bool {
		return ((b.x - a.x) * (y - a.y) - (b.y - a.y) * (x - a.x)) >= 0;
	}

	inline public static function rightSide(x:Float, y:Float, a:Point, b:Point):Bool {
		return ((b.x - a.x) * (y - a.y) - (b.y - a.y) * (x - a.x)) <= 0;
	}

	/**
	 * Returns true if the mouse world x/y coordinate are within the given rectangular block
	 * 
	 * @param	useWorldCoords	If true the world x/y coordinates of the mouse will be used, otherwise screen x/y
	 * @param	rect			The rectangle to test within. If this is null for any reason this function always returns true.
	 * 
	 * @return	true if mouse is within the Rectangle, otherwise false
	 */
	public static function mouseInRectangle(useWorldCoords:Bool, rect:Rectangle, mouseP:Point):Bool {
		if (rect == null) {
			return true;
		}

		if (useWorldCoords) {
			return pointInRectangle(Math.floor(mouseP.x), Math.floor(mouseP.y), rect);
		} else {
			return pointInRectangle(Math.floor(mouseP.x), Math.floor(mouseP.y), rect); // TODO screen X screen Y
		}
	}

	/**
	 * Returns true if the given x/y coordinate is within the Rectangle
	 * 
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rect		The Rectangle to test within
	 * @return	true if pointX/pointY is within the Rectangle, otherwise false
	 */
	public static function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool {
		if (pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom) {
			return true;
		}
		return false;
	}

	/**
	 * Adds the given amount to the value, but never lets the value
	 * go over the specified maximum or under the specified minimum.
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @param 	min 	The minimum the value is allowed to be
	 * @return The new value
	 */
	public static function maxAdd(value:Int, amount:Int, max:Int, min:Int = 0):Int {
		value += amount;

		if (value > max) {
			value = max;
		} else if (value <= min) {
			value = min;
		}

		return value;
	}

	/**
	 * Adds value to amount and ensures that the result always stays between 0 and max, by wrapping the value around.
	 * Values must be positive integers, and are passed through Math.abs
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrapValue(value:Int, amount:Int, max:Int):Int {
		var diff:Int;

		value = Std.int(Math.abs(value));
		amount = Std.int(Math.abs(amount));
		max = Std.int(Math.abs(max));

		diff = (value + amount) % max;

		return diff;
	}

	/**
	 * Finds the dot product value of two vectors
	 * 
	 * @param	ax		Vector X
	 * @param	ay		Vector Y
	 * @param	bx		Vector X
	 * @param	by		Vector Y
	 * 
	 * @return	Result of the dot product
	 */
	public static inline function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float {
		return ax * bx + ay * by;
	}

	/**
	 * Finds the length of the given vector
	 * 
	 * @param	dx
	 * @param	dy
	 * 
	 * @return The length
	 */
	public static inline function vectorLength(dx:Float, dy:Float):Float {
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * Returns the amount of decimals a Float has
	 * 
	 * @param	Number	The floating point number
	 * @return	Amount of decimals
	 */
	public static function getDecimals(Number:Float):Int {
		var helperArray:Array<String> = Std.string(Number).split(".");
		var decimals:Int = 0;

		if (helperArray.length > 1) {
			decimals = helperArray[1].length;
		}

		return decimals;
	}

	public static inline function equal(aValueA:Float, aValueB:Float, aDiff:Float = 0.00001):Bool {
		return (Math.abs(aValueA - aValueB) <= aDiff);
	}

	/**
	 * Returns -1 if the number is smaller than 0 and 1 otherwise
	 */
	public static inline function signOf(f:Float):Int {
		return (f < 0) ? -1 : 1;
	}

	/**
	 * Checks if two numbers have the same sign (using signOf()).
	 */
	public static inline function sameSign(f1:Float, f2:Float):Bool {
		return signOf(f1) == signOf(f2);
	}

	/**
	 * Distance between 2 points
	 */
	public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.abs(Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2)));
	}

	/**
	 * Find x on line knowing y
	 */
	public static inline function findX(p1:Point, p2:Point, y:Float):Float {
		var _slope = slope(p1, p2);
		return (yIntercept(_slope, p1) - y) / -_slope;
	}

	/**
	 * Find slope of 2 points
	 */
	public static inline function slope(p1:Point, p2:Point):Float {
		return (p2.y - p1.y) / (p2.x - p1.x);
	}

	/**
	 * Find y intercept of 2 points
	 */
	public static inline function yIntercept(Slope:Float, P:Point):Float {
		return P.y - Slope * P.x;
	}
}
