// MathUtils.as
// Copyright (c) 2012 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License http://www.opensource.org/licenses/mit-license.php

package monster
{
	public class MathUtils
	{
		// degreesToRadians() takes an input value in degrees and returns radians.
		public function degreesToRadians(iDegrees:Number):Number
		{
			return (iDegrees * (Math.PI / 180));
		}
		
		// radiansToDegrees() takes an input value in radians and returns degrees.
		public function radiansToDegrees(iRadians:Number):Number
		{
			return (iRadians * (180 / Math.PI));
		}
	}
}