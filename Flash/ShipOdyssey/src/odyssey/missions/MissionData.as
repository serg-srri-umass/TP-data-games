package odyssey.missions
{
	public class MissionData
	{
		import mx.graphics.LinearGradient;
		
		private static var _missionCounter:int = 1;
		private static var _missionArray:Array = new Array();
		
		private var _number:int; // the mission #.
		
		// description variables:
		public var instructions:String;	
		public var title:String;
		
		// money variables:
		public var treasureValue:int; 	// the value of a treasure here.
		public var goal:int; 			// the goal loot amount.
		public var startingLoot:int; 	// the ammount of $ you start the mission with.
		public var variableTreasures:Boolean = false; // if there is only ever 1 treasure here, set this to false.
		
		// rat variables:
		public var minRats:int = 0;		// the minimum # of rats that the stepper can go to at this level
		public var startingRats:int; 	// how many rats start in the stepper.
		public var ratCost:int = 0; 	// how many $ each rat costs here
		
		// math variables:
		public var stdDeviation:Number;	// the standard deviation of rats here
		
		// visual variables:
		public var skyGradient:LinearGradient;
		public var waterGradient:LinearGradient;
		public var cloudPattern:Array;
		
		// when a missionData is created, it's automatically enumerated.
		public function MissionData(){
			this._number = _missionCounter++;
			_missionArray.push(this);
		}
		
		public function get number():int{
			return _number;
		}
		
		//method for getting a mission, given a number
		public static function getMission(arg:int):MissionData{
			arg -= 1; //move the mission # to index origin 0.
			if(arg < 0 || arg > _missionArray.length)
				throw new Error("requested mission does not exist");
			return _missionArray[arg];
		}
	}
}