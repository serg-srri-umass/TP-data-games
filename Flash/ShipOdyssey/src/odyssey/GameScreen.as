package odyssey
{
	// This class holds constant data about the game screen.
	public class GameScreen
	{
		// screen window attributes:
		public static const SCREEN_X:int = 120;
		public static const SCREEN_Y:int = 50;
		public static const SCREEN_WIDTH:int = 395;
		public static const SCREEN_HEIGHT:int = 286;
		
		// art asset attributes:
		public static const DISTANCE_TO_SCALE:int = 64;
		public static const SCALE_WIDTH:int = 265;
		public static const SHIP_WIDTH:int = 322;
		public static const UPPER_DECK_WIDTH:int = 126;
		public static const LOWER_DECK_WIDTH:int = 179;
		public static const LOWER_DECK_X:int = 260;
		public static const WATER_Y:int = 336;
		
		//given an X position, returns the cooresponding Y value from the upper deck	
		public static function calcUpperDeckY(arg:Number):Number
		{
			return ((-1/18) * arg + 145)
		}
		//given an X position, returns the cooresponding Y value from the lower deck	
		public static function calcLowerDeckY(arg:Number):Number
		{
			return ((-17/179) * arg + 214)
		}
	}
}