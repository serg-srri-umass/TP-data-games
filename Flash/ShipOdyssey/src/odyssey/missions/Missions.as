package odyssey.missions
{
	public class Missions
	{
		import common.TextFormatter;
		
		public static const mission1:MissionData = new MissionData();
		public static const mission2:MissionData = new MissionData();
		public static const mission3:MissionData = new MissionData();
		public static const mission4:MissionData = new MissionData();
		public static const mission5:MissionData = new MissionData();
		
		//NOTE: ON THE MAP, Titles are set in the .swc. If they're changed, the .swc has to be updated as well.
		with( mission1){ 		// Mission 1 section:
			title = "Hundreds o' Rats";

			startingRats = 800;
			missesAllowed = 2;
			
			ratsInStepper = 100;
			fixedRats = true;
			
			skyGradient = VisualVariables.daylight;
			waterGradient = VisualVariables.clearWater;
			cloudPattern = VisualVariables.fluffyClouds;
			
			instructions = "Send down 100 rats at a time to guess the treasure's location.  Position the hook, then drop it. Be careful: when you miss twice, your mission is over.";
			
			ratingArray = new Array(4, 5, 6, 7);
		}
		
		with( mission2){		// Mission 3 section:
			title = "Rat Shortage";
			
			startingRats = 400;
			missesAllowed = 2;
			
			ratsInStepper = 5;
			
			skyGradient = VisualVariables.daylight;
			waterGradient = VisualVariables.clearWater;
			cloudPattern = VisualVariables.grayClouds;
			
			instructions = "You start this mission with 400 rats.  Send down as few as you can to estimate the treasure's location.  The mission is over when you miss twice with the hook.";
			
			ratingArray = new Array(2, 4, 5, 7);
		}
		
		with( mission3){		// Mission 2 section:
			title = "Treasure or Not";
			
			startingRats = 500;
			missesAllowed = 2;
			variableTreasures = true;
			
			ratsInStepper = 100;
			
			skyGradient = VisualVariables.daylight;
			waterGradient = VisualVariables.clearWater;
			cloudPattern = VisualVariables.grayClouds;
			
			instructions = "You start this mission with 600 rats.  But there may be 0, 1, or even 2 treasures at each site.  Click the next site button when you think there are no more treasures.";
			
			ratingArray = new Array(2, 3, 4, 5);
		}
		
		with( mission4){		// Mission 4 section:
			title = "Deep Water";
			
			startingRats = 750;
			missesAllowed = 2;
			
			ratsInStepper = 5;
			stdDeviation = MissionData.kStdDeviationDeep;
			
			skyGradient = VisualVariables.darkDay;
			waterGradient = VisualVariables.murkyWater;
			cloudPattern = VisualVariables.grayClouds;
			
			instructions = "You start this mission with 750 rats.  This is deep water, so the rat readings are less accurate. The mission is over when you miss twice with the hook.";
			
			ratingArray = new Array(2, 3, 4, 6);
		}
		
		with( mission5){		// Mission 5 section:
			title = "Small Hook";
			
			startingRats = 1000;
			missesAllowed = 2;
			
			ratsInStepper = 100;
			hookSize = MissionData.SMALL_HOOK;
			hookRadius = 1;
			
			skyGradient = VisualVariables.daylight;
			waterGradient = VisualVariables.clearWater;
			cloudPattern = VisualVariables.fluffyClouds;
			
			instructions = "You start this mission with 1000 rats.  But your hook is only two units wide rather than 4.  The mission is over when you miss twice with the hook.";
		
			ratingArray = new Array(2, 3, 4, 5);
		}
		
		
		// pass this function a #, and it will return the cooresponding MissionData object.
		public static function getMission(arg:Number):MissionData{
			return MissionData.getMission(arg);
		}
		
		public static function getMissionTitle(arg:Number):String {
			return getMission(arg).title;
		}
	}
}