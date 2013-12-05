package odyssey.missions
{
	import mx.graphics.LinearGradient;

	// Class that holds one mission and all of its parameters, each mission is equivalent to a 'level' in other games.
	public class MissionData
	{
		public static const REGULAR_HOOK:int = 1;
		public static const SMALL_HOOK:int = 2;
		public static const kStdDeviationClear:Number = 10;// Standard deviation of rat results in clear water.
		public static const kStdDeviationDeep:Number = 15;// Standard deviation of rat results in deep water.
		
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
		public var seaWall:Boolean = false; // when true, the level has sea walls.
		
		// math variables:
		public var stdDeviation:Number = kStdDeviationClear;	// the standard deviation of rats here
		
		// visual variables:
		public var skyGradient:LinearGradient;
		public var waterGradient:LinearGradient;
		public var cloudPattern:Array;
		
		public var ratingArray:Array = new Array(0,0,0,0);	// rating minimum requirements: in order: 2 stars, 3 stars, 4 stars, 5 stars 
		private var _bestRating:int = 0;
		
		// when a missionData is created, it's automatically enumerated.
		public function MissionData( num:int ){
			this._number = num;
		}
		
		public function get number():int{
			return _number;
		}
		
		public function get bestRating():int{
			return _bestRating;
		}
		
		public function set bestRating( arg:int):void{
			if( arg < 0 || arg > 5){
				throw new Error("Ratings range from 0 - 5");
			}
			_bestRating = arg;
		}
		
		public function getRating(arg:int):int{
			var output:int;
			if(arg >= ratingArray[3])
				output = 5;
			else if(arg >= ratingArray[2])
				output = 4;
			else if(arg >= ratingArray[1])
				output = 3;
			else if(arg >= ratingArray[0])
				output = 2;
			else
				output = 1;
			
			if( output > _bestRating)
				_bestRating = output;
			
			return output;
		}
	}
}