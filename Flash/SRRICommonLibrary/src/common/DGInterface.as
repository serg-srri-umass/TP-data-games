package common
{
	import com.adobe.serialization.json.JSON;
	
	/*	Data Games (DG) Interface Class
	   	A singleton object that extends the KCPT Script Interface,
		and adds uniform error handling for a Flash Builder game
		that is communicating with its Data Games (DG) container.
		Note: DG is a javascript/sproutcore web application that can contain Flash games.
	*/
	public class DGInterface
	{
		private const kSuppressDGTraceStatments:Boolean = false;		// set to false to suppress debugging code for this class only
		
		private var mDebugMode:Boolean = false;		// if true we do extra trace and error checking
		private var mDebugNumCases:int = 0;			// count number of game-level cases for debugging only
		private	var	mParentCaseID:int = -2;			// parent (game-level) case ID for DG; -2 means DG data not yet initialized, -1 means that no game case is open, 0+ is valid ID

		
		// constructor
		public function DGInterface( inDebugMode:Boolean )
		{
			this.mDebugMode = inDebugMode && ! kSuppressDGTraceStatments;
		}
		
		//--------- Collection and Case Data ---------
		
		// Send the Game-level and Event-level structure to DG, if connected to DG.  
		// 		The collections are the tables of cases and attributes.
		public function initGame( iInitGameArgs:Object ):void {
			var doCommandObj:Object = {
					action: "initGame",
					args: iInitGameArgs
				};
			var result:String = ScriptInterface.doCommand( JSON.encode( doCommandObj ) ); // note: as of 2013-07-23 initGame always returns null
			mParentCaseID = -1; // change from -2 to -1 to indicate game data sent (for error detection only)
			debugTrace( "DG interface: initGame" );
		}
		
		// open a game case data to DG, if connected to DG.
		//		Throws an error if the last game case was not closed.
		// 		iCollectionName is the name corresponding to the Event collection
		// 		iCaseValueArray is an array of initial case-attribute values for that case (to be updated later by updateOrCloseGameCase())
		public function openGameCase( iCollectionName:String, iCaseValueArray:Array ):void {
			var doCommandObj:Object = {
				action: "openCase",
				args: { 
					collection: iCollectionName,
					values: iCaseValueArray
				} 	
			};
			
			if( this.mParentCaseID >= 0 ) {
				throw new Error("DG interface error: openCase without closing previous parent case ID (" + this.mParentCaseID + ")" );
			} else {
				var	resultString:String = ScriptInterface.doCommand( JSON.encode( doCommandObj ));
				var resultObj:Object = (resultString ? JSON.decode( resultString ) : null );
				this.mParentCaseID = (resultObj && resultObj.success ? resultObj.caseID : -1 );
				if( mDebugMode && this.mParentCaseID == -1 ) {
					this.mParentCaseID = ++mDebugNumCases; // fake a valid case ID for validating sendGameDataUpdate() when not connected to DG
					debugTrace("DG interface: simulating openCase with parent case ID "+this.mParentCaseID+" (debug only)");
				} else {
					debugTrace( "DG interface: openCase with parent case ID "+this.mParentCaseID );
				}
			}
		}
		
		// Send a game case data to DG, if connected to DG.
		//		Throws an error if there is not a currently open game case.
		// 		iCollectionName is the name corresponding to the Event collection
		// 		iCaseValueArray is an array of case-attribute values for that case 
		//			(corresponding to the game attributes previously sent)
		public function updateOrCloseGameCase( iCollectionName:String, iCaseValueArray:Array, iWantCaseClosed:Boolean = false ):void {
			var	whichAction:String = (iWantCaseClosed ? "closeCase" : "updateCase" ),
				doCommandObj:Object = { 
					action: whichAction,
					args: { 
						collection: iCollectionName,
						caseID: this.mParentCaseID,
						values: iCaseValueArray
					}
				};
			if( this.mParentCaseID >= 0 ) {
				debugTrace( "DG interface: "+whichAction+" with parent case ID "+this.mParentCaseID );
				ScriptInterface.doCommand( JSON.encode( doCommandObj ));
			} else {
				throw new Error("DG interface error: " + whichAction + " with invalid parent case ID (" + this.mParentCaseID + ")" );
			}
			
			if( iWantCaseClosed )
				this.mParentCaseID = -1;	// set to invalid ID after close so we can detect errors
		}
		
		public function isGameCaseOpen():Boolean {
			return( this.mParentCaseID >= 0);
		}
		
		// Send event case data to DG, if connected to DG.
		//		Throws an error if there is not a currently open game case.
		// 		iCollectionName is the name corresponding to the Event collection
		// 		iCaseValueArrays is an array of cases, each case is a array of attribute values for that case 
		//			(corresponding to the event attributes previously sent)
		public function createEventCases( iCollectionName:String, iCaseValueArrays:Array ):void {
			
			var doCommandObj:Object = 
				{
					action: "createCases",
					args: {
						collection: iCollectionName,
						parent: this.mParentCaseID,
						values: iCaseValueArrays
					}
				};				
			
			if( this.mParentCaseID >= 0 ) {
				debugTrace( "DG interface: createCases ("+iCaseValueArrays.length+") with parent case ID "+this.mParentCaseID );
				ScriptInterface.doCommand( JSON.encode( doCommandObj ));
			} else {
				throw new Error("DG interface error: createCases (Event level) with invalid parent case ID ("+this.mParentCaseID+")" );
			}
		}
		
		//--------- Other ---------
		
		// send a statement to DG's log of user actions; used to record actions like "Dropped hook at 56.7" in DG.
		public function sendLog( logStatment:String, stringParameters:Array = null ):void {
			var doCommandObj:Object = {  
				action: "logAction", // delete all closed cases
				args: { 
					formatStr: logStatment + " [flash]", // the statement string, with optional use of %@
						replaceArgs: stringParameters // optional array of values to replace %@ with
				}
			};
			var result:String = ScriptInterface.doCommand( JSON.encode( doCommandObj ));
			debugTrace( "DG interface: log "+doCommandObj.args.formatStr );
		}
		
		// ask DG to create a Graph object.  It should ignore this request if a Graph already exists.
		public function createGraphIfNone():void {
			var doCommandObj:Object = {
				action: "createComponent",
				args: { type: "DG.GraphView" }
			};
			var result:String = ScriptInterface.doCommand( JSON.encode( doCommandObj ));
			debugTrace( "DG interface: createComponent type:DG.GraphView" );
		}
		
		// ask DG to delete event-level cases of finished games (where the game-level case has been closed). This helps keep the Graph clutter-free.
		public function deletePreviousCaseData():void {
			var doCommandObj:Object = {  
				action: "deleteAllCaseData", // delete all closed cases
				args: { preserveGameCollectionCases: true } // except for game collection cases (but not children of game collection cases)
			};
			var result:String = ScriptInterface.doCommand( JSON.encode( doCommandObj ));
			debugTrace( "DG interface: deleteAllCaseData preserveGameCollectionCases:true" );
		}
		
		// trace in debug mode only
		private function debugTrace( str:String ):void { if( mDebugMode ) trace( str ); }
	}
}