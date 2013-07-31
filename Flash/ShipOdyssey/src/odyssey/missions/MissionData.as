package odyssey.missions
{
	import mx.graphics.LinearGradient;

	public class MissionData
	{
		public static const REGULAR_HOOK:int = 1;
		public static const SMALL_HOOK:int = 2;
		public static const kStdDeviationClear:Number = 10;// Standard deviation of rat results in clear water.
		public static const kStdDeviationDeep:Number = 15;// Standard deviation of rat results in deep water.
		
		private static var _missionCounter:int = 1;
		private static var _missionArray:Array = new Array();
		
		private var _number:int; // the mission #.
		
		// description variables:
		public var instructions:String;	
		public var title:String;
		
		// rat & hook variables:
		public var startingRats:int; 	// the ammount of $ you start the mission with.
		public var missesAllowed:int;
		public var variableTreasures:Boolean = false; // if true, player cannot change the rat stepper.
		public var fixedRats:Boolean = false;		//if > 0, only this many rats can be sent on a level.
		public var ratsInStepper:int; 	// how many rats start in the stepper.
		public var ratCost:int = 1; 	// how many $ each rat costs here
		
		public var hookSize:int = REGULAR_HOOK; // what frame to show the hook at.
		public var hookRadius:int = 2; // how big in units the hook is (multiply this by 2 for the full interval)
		
		// math variables:
		public var stdDeviation:Number = kStdDeviationClear;	// the standard deviation of rats here
		
		// visual variables:
		public var skyGradient:LinearGradient;
		public var waterGradient:LinearGradient;
		public var cloudPattern:Array;
		
		public var ratingArray:Array = new Array(0,0,0,0);	// in order: 2 stars, 3 stars, 4 stars, 5 stars minimum requirement
		
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
		
		public function getRating(arg:int):int{
			if(arg >= ratingArray[3])
				return 5;
			if(arg >= ratingArray[2])
				return 4;
			if(arg >= ratingArray[1])
				return 3;
			if(arg >= ratingArray[0])
				return 2;
			
			return 1;
		}
	}
}