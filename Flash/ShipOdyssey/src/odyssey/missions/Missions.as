package odyssey.missions
{

	// Singleton class that holds data for each of 5 missions of ShipOdyssey, so that games can reference the mission variables.
	public class Missions
	{
		
		private static var _missionArray:Array = null;
		
		private static function createMissions():void {

			_missionArray = new Array();
						
			//NOTE: ON THE MAP, Titles are set in the .swc. If they're changed, the .swc has to be updated as well.
			for( var i:int=1; i<=6; i++ ) {
				
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
					
					m.instructions = "Send down 100 rats at a time to guess the treasure's location. When you think you know where the treasure is, position the hook and drop it. The game is over when you miss twice with the hook or use up your 800 rats.";
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
					
					m.instructions = "Send down as few rats as you can to estimate the treasure's location. But remember, the game is over when you miss twice with the hook or use up your 400 rats.";
					m.ratingArray = new Array(2, 4, 5, 7);
					break;
			
				case 3:
					m.title = "Treasure or Not";
					
					m.startingRats = 500;
					m.missesAllowed = 2;
					m.variableTreasures = true;
					
					m.fixedRats = true;
					m.ratsInStepper = 100;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.grayClouds;
					
					m.instructions = "Send down 100 rats at a time to guess the treasure's location.  At each site, there may be 0, 1, or 2 treasures.  Click 'Next Site' when you think there are no more treasures at a site. The game is over when you miss twice with the hook or use up your 500 rats.";
					m.ratingArray = new Array(2, 3, 4, 5);
					break;
			
				case 4:
					m.title = "Deep Water";
				
					m.startingRats = 750;
					m.missesAllowed = 2;
				
					m.ratsInStepper = 5;
					m.stdDeviation = MissionData.kStdDeviationDeep;
				
					m.skyGradient = VisualVariables.darkDay;
					m.waterGradient = VisualVariables.murkyWater;
					m.cloudPattern = VisualVariables.grayClouds;
				
					m.instructions = "Send down as few rats as you can to estimate the treasure's location. But this is deep water, so the rat readings are less accurate. The game is over when you miss twice with the hook or use up your 750 rats.";
					m.ratingArray = new Array(2, 3, 4, 6);
					break;
			
				case 5:
					m.title = "Small Hook";
				
					m.startingRats = 1000;
					m.missesAllowed = 2;
				
					m.ratsInStepper = 5;
					m.hookSize = MissionData.SMALL_HOOK;
					m.hookRadius = 1;
				
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.fluffyClouds;
				
					m.instructions = "Send down as few rats as you can to estimate the treasure's location.  But your hook is now only 2 units wide rather than 4. The game is over when you miss twice with the hook or use up your 1000 rats.";
					m.ratingArray = new Array(2, 3, 4, 5);
					break;
				
				case 6:
					m.title = "Sea Walls";
					
					m.startingRats = 800;
					m.missesAllowed = 2;
					
					m.ratsInStepper = 100;
					m.fixedRats = true;
					
					m.skyGradient = VisualVariables.daylight;
					m.waterGradient = VisualVariables.clearWater;
					m.cloudPattern = VisualVariables.fluffyClouds;
					
					m.instructions = "Send down 100 rats at a time to guess the treasure's location.  Sea walls keep the rats from surfacing below 0 or above 100. The game is over when you miss twice with the hook or use up your 800 rats."
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
		
		// returns an array of your score on all missions
		public static function getBestRatings():Array{
			var ratingArray:Array = new Array();
			for( var i:int = 0; i < _missionArray.length; i++){
				ratingArray.push(_missionArray[i].bestRating);
			}
			return ratingArray;
		}
	}
}