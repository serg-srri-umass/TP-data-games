package chainsaw
{
	import chainsaw.ChainSaw;
	
	import flash.display.MovieClip;
	
	// This class is used in evaluating the piece's acceptance status.
	public class PieceStatus
	{
		public var mLength:Number;			// Piece length
		public var mLogNumber:uint; 		// Number of log ( 1 is at top).
		public var mIsEndPiece:Boolean; 	// True if end piece.
		public var mLeftToRight:Boolean;	// True if cutting left to right.
		public var mIsNewLog:Boolean;		// True if measuring on new log for first time.
		public var mFuelUsed:Number;		// Raw fuel used at the time of piece creation.
		public var mPrevXCut:Number	= 0;	// Cut before this cut or game end.
		public var mCutX:Number		= 0;	// X cut location on log. 0 if end piece.
		public var mCutNumber:uint	= 0;	// Cut number.
		public var mLogArray:Array;			// The Array containing the four logs

		public function PieceStatus(
			iLength:Number,			// Piece length
			iLogNumber:uint, 		// Number of log ( 1 is at top).
			iIsEndPiece:Boolean, 	// True if end piece.
			iLeftToRight:Boolean,	// True if cutting left to right.
			iIsNewLog:Boolean,		// True if measuring on new log for first time.
			iFuelUsed:Number,		// Raw fuel used at the time of piece creation.
			iPrevXCut:Number,		// Cut before this cut or game end.
			iCutX:Number,			// X cut location on log. 0 if end piece.
			iCutNumber:uint,		// Cut number.
			iLogArray:Array			// The Array containing the four logs
			):void
		{
			mLength			= iLength;
			mLogNumber		= iLogNumber;
			mIsEndPiece		= iIsEndPiece;
			mLeftToRight	= iLeftToRight;
			mIsNewLog		= iIsNewLog;
			mFuelUsed		= iFuelUsed;
			mPrevXCut		= iPrevXCut;
			mCutX			= iPrevXCut;
			mCutNumber		= iCutNumber;
			mLogArray		= iLogArray;
		}
		
		public function isAccepted():Boolean
		{
			return (mLength >= ChainSaw.kMinCutLength) && (this.mLength <= ChainSaw.kMaxCutLength);
		}
		public function isRemnant():Boolean
		{
			var currentLog:MovieClip = mLogArray[mLogNumber-1][0] as MovieClip; // The current log
			var logLength:Number = currentLog['LogLength']; // get the length of the current log
			
			var remnant:Boolean = false; // Initialize to false
			
			if(isAccepted()) return false;
			
			if(mIsEndPiece)
			{
				// if there is not enough room for two cuts at the (but more than one)
				if(mLeftToRight && (logLength - mPrevXCut) < ChainSaw.kReferenceLength*2) //left to right cut
				{
					remnant = true;
				}
				else if(mPrevXCut < ChainSaw.kReferenceLength*2) //right to left cut
				{
					remnant = true;
				}
			}
			
			if(mLength <= ChainSaw.kReferenceLength/2) // a piece less than or equal to half the reference length
			{
				remnant = true;
			}
			if(mLength >= ChainSaw.kReferenceLength+(ChainSaw.kReferenceLength * .75)) // a piece over 1.75 times the reference length
			{
				remnant = true;
			}
			return remnant;
		}
		public function getAcceptString():String
		{
			if (isAccepted()){
				return ChainSaw.kAcceptString;
			}else if (isRemnant()){
				return ChainSaw.kRemnantString;
			}else{
				if(mLength < ChainSaw.kMinCutLength){
					return ChainSaw.kRejectShortString;
				}else{
					return ChainSaw.kRejectLongString;
				}
			}
		}
	}
}