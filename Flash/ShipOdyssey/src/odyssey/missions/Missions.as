package odyssey.missions
{

	// Singleton class that holds data for each of 5 missions of ShipOdyssey, so that games can reference the mission variables.
	public class Missions
	{
		
		private static var _missionArray:Array = null;
		
		private static function createMissions():void {

			_missionArray = new Array();
						
			//NOTE: ON THE MAP, Titles are set in the .swc. If they're changed, the .swc has to be updated as well.
			for( var i:int=1; i<=5; i++ ) {
				
				var m:MissionData = new MissionData( i );
				
				_missionArray.push( m );
				
				switch(i) {
				case 1:
					m.title = "Hundreds o' Rats";
		
					m.startingRats = 800;
					m.missesAllowed = 2;
					
					m.ratsInStepper = 100;
					m.fixedRats = true;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.fluffyClouds;
					
					m.instructions = "Send down 100 rats at a time to guess the treasure's location.  Position the hook, then drop it. Be careful: when you miss twice, your game is over.";
					m.ratingArray = new Array(4, 5, 6, 7); // rating minimum requirements: in order: 2 stars, 3 stars, 4 stars, 5 stars 
					break;
				
				case 2:
					m.title = "Rat Shortage";
					
					m.startingRats = 400;
					m.missesAllowed = 2;
					
					m.ratsInStepper = 5;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.grayClouds;
					
					m.instructions = "You start this mission with 400 rats.  Send down as few as you can to estimate the treasure's location.  The game is over when you miss twice with the hook.";
					m.ratingArray = new Array(2, 4, 5, 7);
					break;
			
				/*case 3:
					m.title = "Treasure or Not";
					
					m.startingRats = 500;
					m.missesAllowed = 2;
					m.variableTreasures = true;
					
					m.ratsInStepper = 5;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.grayClouds;
					
					m.instructions = "You start this mission with 600 rats.  But there may be 0, 1, or even 2 treasures at each site.  Click the Next Site button when you think there are no more treasures.";
					m.ratingArray = new Array(2, 3, 4, 5);
					break;*/
			
				case 3:
					m.title = "Deep Water";
				
					m.startingRats = 750;
					m.missesAllowed = 2;
				
					m.ratsInStepper = 5;
					m.stdDeviation = MissionData.kStdDeviationDeep;
				
					m.skyGradient = VisualVariables.darkDay;
					m.waterGradient = VisualVariables.murkyWater;
					m.cloudPattern = VisualVariables.grayClouds;
				
					m.instructions = "You start this mission with 750 rats.  This is deep water, so the rat readings are less accurate. The game is over when you miss twice with the hook.";
					m.ratingArray = new Array(2, 3, 4, 6);
					break;
			
				case 4:
					m.title = "Small Hook";
				
					m.startingRats = 1000;
					m.missesAllowed = 2;
				
					m.ratsInStepper = 5;
					m.hookSize = MissionData.SMALL_HOOK;
					m.hookRadius = 1;
				
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.fluffyClouds;
				
					m.instructions = "You start this mission with 1000 rats.  But your hook is only 2 units wide rather than 4.  The mission is over when you miss twice with the hook.";
					m.ratingArray = new Array(2, 3, 4, 5);
					break;
				
				case 5:
					m.title = "Sea Wall";
					
					m.startingRats = 500;
					m.missesAllowed = 2;
					
					m.ratsInStepper = 5;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.fluffyClouds;
					
					m.instructions = "You start this mission with 500 rats. There's a  wall beneath the ocean that affects where the treasure can be found. The game is over when you miss twice with the hook."
					m.ratingArray = new Array(4, 5, 6, 7); // rating minimum requirements: in order: 2 stars, 3 stars, 4 stars, 5 stars 
					
					m.seaWall = true;
					break;
				}
			}
		}
		
		// pass this function a #, and it will return the corresponding MissionData object.
		public static function getMission(arg:Number):MissionData{
			
			if( ! _missionArray ) {
				createMissions(); // construct our missions the first time through
			}

			arg -= 1; //move the mission # to index origin 0.
			if( arg < 0 || arg > _missionArray.length)
				throw new Error("requested mission does not exist");
			return _missionArray[arg];
		}
		
		public static function getMissionTitle(arg:Number):String {
			return getMission(arg).title;
		}
	}
}