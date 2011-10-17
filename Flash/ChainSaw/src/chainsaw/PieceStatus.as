package chainsaw
{
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

		public function PieceStatus(
			iLength:Number,			// Piece length
			iLogNumber:uint, 		// Number of log ( 1 is at top).
			iIsEndPiece:Boolean, 	// True if end piece.
			iLeftToRight:Boolean,	// True if cutting left to right.
			iIsNewLog:Boolean,		// True if measuring on new log for first time.
			iFuelUsed:Number,		// Raw fuel used at the time of piece creation.
			iPrevXCut:Number	= 0,// Cut before this cut or game end.
			iCutX:Number		= 0,// X cut location on log. 0 if end piece.
			iCutNumber:uint		= 0	// Cut number.
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
		}
	}
}