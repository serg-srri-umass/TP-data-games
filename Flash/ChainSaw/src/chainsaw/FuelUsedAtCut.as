package chainsaw
{
	public class FuelUsedAtCut
	{
		public var mCutX:Number;		// X position of cut in log's coordinate system.
		public var mFuelUsed:Number;	// Fuel used at time of cut.
		public var mCutNumber:uint;		// Chronological cut number. 
										//   Begins at 1 with first cut of each individual game.
		
		public function FuelUsedAtCut(iCutX:Number, iFuelUsed:Number, iCutNumber:uint)
		{
			this.mCutX 		= iCutX;
			this.mFuelUsed 	= iFuelUsed;
			this.mCutNumber	= iCutNumber;
		}
	}
}
	
