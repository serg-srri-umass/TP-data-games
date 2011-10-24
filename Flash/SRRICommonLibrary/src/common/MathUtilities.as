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
	}
}