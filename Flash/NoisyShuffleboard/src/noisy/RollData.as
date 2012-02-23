// RollData.as
// Copyright (c) 2012 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License http://www.opensource.org/licenses/mit-license.php

package noisy
{
	// RollData holds data for a single rock roll. This data is saved for
	// later transmission to TinkerPlots/Fathom.
	public class RollData
	{
		public var mGameNumber:uint;	// Game number starting with 1 since launch of application.
		public var mRollOrder:uint;		// Roll order within the current game being played.
		public var mCourt:String;		// Rock was rolled in which court: "Top" or "Bottom".
		public var mColorString:String;	// Name of first attribute, such as "Color"
		public var mPatternString:String;// Name of second attribute, such as "Pattern"
		public var mShapeString:String;	// Name of third attribute, such as "Shape"
		public var mSizeString:String;	// Name of fourth attribute, such as "Size"
		public var mStrength:Number;	// Strength at which this roll was executed.
		public var mDistance:uint;		// Distance rocked reached once it stopped rolling.
		public var mRollScore:uint;		// Score earned by this roll of the rock.
		
		public function RollData(	iGameNumber:uint,
									iRollOrder:uint,
									iCourt:String,
									iColorString:String,
									iPatternString:String,
									iShapeString:String,
									iSizeString:String,
									iStrength:Number,
									iDistance:uint,
									iRollScore:uint)
		{
			mGameNumber		= iGameNumber;
			mRollOrder		= iRollOrder;
			mCourt			= iCourt;
			mColorString	= iColorString;
			mPatternString	= iPatternString;
			mShapeString	= iShapeString;
			mSizeString		= iSizeString;
			mStrength		= iStrength;
			mDistance		= iDistance;
			mRollScore		= iRollScore;
		}
	}
}