// MathUtilities.as
// Copyright (c) 2011 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

package common
{
	public class MathUtilities
	{
		// Taken from Stack Overflow at 
		// http://stackoverflow.com/questions/632802/how-to-deal-with-number-precision-in-actionscript on 9/9/2011.
		// The original questioner was mike-sickler at http://stackoverflow.com/users/16534/mike-sickler.
		// fraser at http://stackoverflow.com/users/74861/fraser responded to mike-sickler.
		// user186920 (no user link available on the site on 10/21/2011) responded to fraser's post, and the code  
		// snippet below was taken from user186920's response.
		// Stack Overflows states that "user contributions licensed under cc-wiki with attribution required."
		// cc-wiki is at http://creativecommons.org/licenses/by-sa/3.0/ and is the Creative Commons license
		// "Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)"
		// Parameter and variable names in setPrecision() have been modified to fit project naming conventions.
		
		// setPrecision() takes in a number and a precision and returns the number's value using the input precision.
		public function setPrecision(iNumber:Number, iPrecision:int):Number
		{
			iPrecision = Math.pow(10, iPrecision);
			return (Math.round(iNumber * iPrecision)/iPrecision);
		}
		// end code from stack overflow
		
		// give this method an array and it will shuffle it, based on the given start and end index
		public static function shuffleArray(targetArray:Array, startIndex:int = 0, endIndex:int = int.MAX_VALUE):void{
			if(endIndex > targetArray.length - 1)
				endIndex = targetArray.length - 1; // if no end index is given, assume the entirety of the array is to be shuffled.
			// first, ensure the parameters are valid:
			if(startIndex > targetArray.length || startIndex < 0)
				throw new Error("invalid start index.");
			if(endIndex < startIndex)
				throw new Error("invalid end index.");
			
			// if the end and start index are identical, there's nothing to do.
			if(endIndex == startIndex)
				return;
			
			var startingPosition:int = startIndex; 
			while(startingPosition < endIndex){
				var range:int = endIndex - startingPosition + 1; 
				var randomPosition:int = Math.random()*range + startingPosition;
				
				//make the swap:
				var swapHolder:* = targetArray[randomPosition];
				targetArray[randomPosition] = targetArray[startingPosition];
				targetArray[startingPosition] = swapHolder;
				
				startingPosition++;
			}
		}
		
		//https://gist.github.com/robinhouston/6200770
		// from Robin Huston
		private static function integrate_one_slice(f:Function, a:Number, b:Number):Number {
			return (b-a) * ( f(a) + 4*f((a+b)/2) + f(b)) / 6;
		}
		
		public static function integrate(f:Function, a:Number, b:Number, DELTA:Number):Number {
			var x:Number = a;
			var integral:Number = 0;
			while (x < b) {
				integral += integrate_one_slice(f, x, Math.min(x+DELTA, b));
				x += DELTA;
			}
			return integral;
		}
		
		//
		private static function calculateZ( intervalWidth:Number, n:Number, SD:Number):Number{
			var top:Number =  intervalWidth * Math.sqrt(n);
			var bottom:Number = 2 * SD;
			return top / bottom;
		}
		
		private static function bellCurveFormula( mean:Number):Number{
			var first:Number = 1 / (Math.sqrt( 2 * Math.PI));
			var exponent:Number = -1 * (mean*mean) / 2;
			var second:Number = Math.pow( Math.E, exponent);
			return first * second;
		}
		
		public static function calculateAreaUnderBellCurve(intervalWidth:Number, n:Number, SD:Number):Number{
			var z:Number = calculateZ(intervalWidth, n, SD);
			return integrate(bellCurveFormula, -z, z, 0.01);
		}
	}
}