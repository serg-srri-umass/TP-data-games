// ParkMiller.as
// Copyright (c) 2011 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

package common
{
	public class ParkMiller
	{
		public function ParkMiller()
		{
			var date:Date = new Date();
			var seedStarter:uint = date.getTime();	// Start with any number.
			seed(seedStarter);			// Seed the generator.
		}
		
		// Taken from http://blog.controul.com/2009/04/standard-normal-distribution-in-as3/ on 11/19/2010
		// No copyright information found on website.
		/**
		 *	Seeds the prng.
		 */
		private var s : int;
		public function seed ( seed : uint ) : void
		{
			s = seed > 1 ? seed % 2147483647 : 1;
		}
		
		/**
		 *	Returns a Number ~ U(0,1)
		 */
		public function uniform () : Number
		{
			return ( ( s = ( s * 16807 ) % 2147483647 ) / 2147483647 );
		}
		
		/** Returns a random number with range (0-N) and uniform distribution. */
		public function uniformToN( iLowEnd:Number, iHighEnd:Number ):Number {
			return( iLowEnd + (uniform() * (iHighEnd - iLowEnd)));
		}
		
		/** Returns a random number with range (N-M) and uniform distribution. */
		public function uniformNtoM( iLowEnd:Number, iHighEnd:Number ):Number {
			return( iLowEnd + (uniform() * (iHighEnd - iLowEnd)));
		}
		
		/**
		 *	Returns a Number ~ N(-1,1);
		 */
		private var ready : Boolean;
		private var cache : Number;
		public function standardNormal () : Number
		{
			if ( ready )
			{						//  Return a cached result
				ready = false;		//  from a previous call
				return cache;		//  if available.
			}
			
			var	x : Number,			//  Repeat extracting uniform values
			y : Number,				//  in the range ( -1,1 ) until
			w : Number;				//  0 < w = x*x + y*y < 1
			do
			{
				x = ( s = ( s * 16807 ) % 2147483647 ) / 1073741823.5 - 1;
				y = ( s = ( s * 16807 ) % 2147483647 ) / 1073741823.5 - 1;
				w = x * x + y * y;
			}
			while ( w >= 1 || !w );
			
			w = Math.sqrt ( -2 * Math.log ( w ) / w );
			
			ready = true;
			cache = x * w;			//  Cache one of the outputs
			return y * w;			//  and return the other.
		}
		
		/**
		 *	Return a random Number with Normal distribution and the given Mean and Standard Deviation.
		 */
		public function normalWithMeanSD( iMean:Number=0, iSD:Number=1 ):Number {
			DebugUtilities.assert( iSD > 0, "invalid Standard Deviation" );
			return(( standardNormal() * iSD ) + iMean );
		}
		
		/**
		 *	Return a random Number with Normal distribution and the given Mean and InterQuartileRange.
		 */
		public function normalWithMeanIQR( iMean:Number=0, iIQR:Number=1 ):Number {
			DebugUtilities.assert( iIQR > 0, "Invalid IQR" );
			return(( standardNormal() * MathUtilities.IQR_to_SD( iIQR )) + iMean );
		}
	}
}