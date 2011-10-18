// MathUtilities.as
// Copyright (c) 2011 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

package common
{
	public class MathUtilities
	{
		// Taken from http://stackoverflow.com/questions/632802/how-to-deal-with-number-precision-in-actionscript on 9/9/2011.
		public function setPrecision(number:Number, precision:int):Number
		{
			precision = Math.pow(10, precision);
			return (Math.round(number * precision)/precision);
		}
	}
}