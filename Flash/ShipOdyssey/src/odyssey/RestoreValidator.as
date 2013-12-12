package odyssey
{
	public class RestoreValidator
	{
		public function RestoreValidator(){}
		
		// validates Odyssey-level restore data.
		public function validateOdysseyRestore( iState:Object):Boolean{
			if(iState.ratings == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.ratings");
				return false;
			}
			
			if(iState.deleteDataEachSite == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.deleteDataEachSite");
				return false;
			}
			
			if(iState.gameSerialNum == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.gameSerialNum");
				return false;
			}
			
			if(iState.siteSerialNum == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.siteSerialNum");
				return false;
			}
			
			return true;
		}
		
		/*
		public function validateGameRestore( iState:Object):Boolean{
			if(iState.mission == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.mission");
				return false;
			}
			
			if(iState.gameSerialNum == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.gameSerialNum");
				return false;
			}
			
			if(iState.siteSerialNum == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.siteSerialNum");
				return false;
			}
			
			if(iState.sitesVisitedThisGame == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.sitesVisitedThisGame");
				return false;
			}
			
			if(iState.remainingRats == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.remainingRats");
				return false;
			}
			
			if(iState.remainingMisses == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.remainingMisses");
				return false;
			}
			
			if(iState.treasuresFoundThisGame == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.treasuresFoundThisGame");
				return false;
			}
			
			if(iState.wasInSite == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.wasInSite");
				return false;
			}
			
			return true;
		}
		
		public function validateSiteRestore( iState:Object):Boolean{
			if(iState.treasuresFoundThisSite == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.treasuresFoundThisSite");
				return false;
			}
			
			if(iState.treasuresRemaining == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.treasuresRemaining");
				return false;
			}
			
			if(iState.hooksDroppedArray == undefined){
				trace(" VALIDATE ODYSSEY FAILED AT iState.hooksDroppedArray");
				return false;
			}
			
			return true;
		}*/
	}
}