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
		
		// bell curve is a normal curve. 
		public static function calculateAreaUnderBellCurve(intervalWidth:Number, n:Number, SD:Number):Number{
			var z:Number = calculateZ(intervalWidth, n, SD);
			return integrate(bellCurveFormula, -z, z, 0.01);
		}
		
		public static function SD_to_IQR(SD:Number):Number{
			return SD * 1.34896;
		}
		
		public static function IQR_to_SD(IQR:Number):Number{
			return IQR / 1.34896;
		}
		
		/**
		 * Compute the median of an array of finite numeric values.
		 * Warning, the input array is sorted, on the assumption that it is most
		 * computationally efficient to directly modify a temporary array.  Caller
		 * should make a copy of the array if this is undesired behavior.
		 * @param ioArray array of numbers (will be sorted ascending)
		 * @return {Number} median value or undefined if ioArray.length===0
		 */
		public static function medianOfNumericArray( ioArray:Array ):Number {
			
			function median( iSortedArray:Array ):Number {
				var i:Number = (iSortedArray.length - 1)/ 2, // middle index in 0-(n-1) array
					i1:Number = Math.floor(i),
					i2:Number = Math.ceil(i);
				if( i < 0 ) {
					return undefined; // length === 0
				} else if( i===i1 ) {
					return iSortedArray[i];
				} else {
					return (iSortedArray[i1]+iSortedArray[i2]) / 2;
				}
			}
			
			ioArray.sort( Array.NUMERIC ); // ascending numeric sort()
			return median( ioArray );
		}
		
		
		
		
		
		// RANDOM NUMBER GENRATORS:
		public static function randomBoolean():Boolean{
			var i:int = Math.random() * 2;
			return i == 0;
		}
		
		// returns a random int ranging from the lowEnd (inclusive) to the highEnd (exclusive) 
		public static function randomIntBetween( lowEndInclusive:int, highEndExclusive:int):int{
			if( lowEndInclusive >= highEndExclusive){
				throw new Error("Low end must be lower than high end.");
			}
			var spread:Number = highEndExclusive - lowEndInclusive;
			var randomSeed:Number = Math.random();
			return lowEndInclusive + (randomSeed * spread);
		}
		
		// returns a random number ranging from the lowEnd (inclusive) to the highEnd (exclusive) 
		public static function randomNumberBetween( lowEndInclusive:Number, highEndExclusive:Number):Number{
			if( lowEndInclusive >= highEndExclusive){
				throw new Error("Low end must be lower than high end.");
			}
			var spread:Number = highEndExclusive - lowEndInclusive;
			var randomSeed:Number = Math.random();
			return lowEndInclusive + (randomSeed * spread);
		}
		
		// put utilities to test out the randomizers here.
		public static function testRandomizers( testBoolean:Boolean = true, testInt:Boolean = true, testNumber:Boolean = true, runs:int = 10000000):void{
			trace("-------------------");
			trace("TESTING RANDOMIZERS");
			trace("-------------------");
			
			var wins:int, i:int, current:Number;

			if(testBoolean){
				// boolean tester
				wins = 0;
				for(i = 0; i < runs; i++){
					if( MathUtilities.randomBoolean()){
						wins++;
					}
				}
				trace( "Random Boolean Win %: ", wins / runs);
				trace( "Test should return approx 0.5 ");
				trace( "---------------------");
			}
			
			if(testInt){
			// int tester
				wins = 0;
				for( i = 0; i < runs; i++){
					current = MathUtilities.randomIntBetween(0, 10);
					if( current == 0){
						wins++;
					}
				}
				trace( "Random Int Win %: ", wins / runs);
				trace( "Test should return approx 0.1");
				trace( "---------------------");
			}
			
			if(testNumber){
				// number tester
				wins = 0;
				for( i = 0; i < runs; i++){
					current = MathUtilities.randomNumberBetween(0, 10);
					if( current < 1){
						wins++;
					}
				}
				trace( "Random Number Win %: ", wins / runs);
				trace( "Test should return approx 0.099999");
				trace( "---------------------");
			}
		}
		
	}
}