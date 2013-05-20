package odyssey
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	// The rat MovieClip.
	public class DivingRatMVC extends red_dot{	

		private static const MAX_SPEED:int = 17; //the fastest a rat can move
		private static const STARTING_DIVE_SPEED:int = 8; //how fast the rat falls when it dives
		private static const STARTING_RISE_SPEED:int = -30; //how fast rats rise when they come out of the water
		private static const DECK_TIME:int = 10;	//how many frames a rat spends on deck before it dives
		
		private var surfacingPosition:Number;
		private var _age:int = 0;	//how many frames the rat has been on-screen
		private var _speed:Number;	//how many pixels/frame the rat moves when onscreen
		private var _awake:Boolean = false;
		private var _state:int = 0;	//the states are diving(0), underwater(1), returning(2) and boarding(3).
		private var _horizontalDrift:Number = 0; //if a rat can't shoot straight up for some reason, it gets a horizontal drift.
		
		public function DivingRatMVC(finalPos:Number)
		{
			surfacingPosition = finalPos;
			
			//randomly place the rat on the boat:
			var shaker:int = Math.random()*2;		// 50/50 chance of choosing either deck.
			if(shaker == 0)
			{
				x = GameScreen.SCREEN_X + 5 + (GameScreen.UPPER_DECK_WIDTH - 5) * Math.random(); 
				// the 5 in the formula above is a buffer to keep the rat from appearing at the very edge of the screen.
				y = GameScreen.calcUpperDeckY(x) + GameScreen.SCREEN_Y;
			}else{
				x = GameScreen.LOWER_DECK_X + GameScreen.LOWER_DECK_WIDTH * Math.random();
				y = GameScreen.calcLowerDeckY(x) + GameScreen.SCREEN_Y; 
			}
		}
		
		// Getters & Setters
		public function get age():int
		{
			return _age;
		}
		public function get speed():Number
		{
			return _speed;
		}
		public function set age(arg:int):void{
			_age = arg;
		}
		public function set speed(arg:Number):void{
			_speed = arg;
		}
		public function get awake():Boolean{
			return _awake;
		}
		public function set awake(arg:Boolean):void{
			_awake = arg;
		}
		
	
	
		// Attach a rat to the screen. Called from the director.
		public function attach():void
		{
			addEventListener(Event.ENTER_FRAME, advance);
			speed = STARTING_DIVE_SPEED;
		}
		
		public function detach():void
		{
			removeEventListener(Event.ENTER_FRAME, advance);
		}
		
		// this function is called every frame. It handles the animation
		private function advance(e:Event):void
		{
			age++;
			if(age >= DECK_TIME && _state == 0)
			{	// wait X frames before jumping overboard
				if(speed < MAX_SPEED)
					speed ++; 
					// acceleration. Tops out at MAX_SPEED
				y += speed;
				if(y >= GameScreen.WATER_Y)		// the rat has hit the water
				{
					_state = 1;	// the rat is now underwater
					age = 0;
					y = GameScreen.WATER_Y;
				}
			}else if(_state == 3)
			{
				y += speed;
				x += _horizontalDrift;
				
				//deceleration:
				if(x < GameScreen.SCREEN_X + GameScreen.LOWER_DECK_X)
					speed += 2;
				else
					speed += 3;
				
				if(speed > 0)
				{
					//check if the rats are past the lip of the ship:
					/*if(x < GameScreen.SCREEN_X + GameScreen.LOWER_DECK_WIDTH && GameScreen.calcUpperDeckY(x) <= y)
					{
						_state = 4;
					}else if(x > GameScreen.SCREEN_X + GameScreen.LOWER_DECK_WIDTH && GameScreen.calcLowerDeckY(x) <= y)
					{
						_state = 4;
					}*/
					if(GameScreen.calcLowerDeckY(x) <= y)
						_state = 4;
				}
			}
		}
		
		// the rat is ready to pop back out of the water. Called from the Director.
		public function rise():void
		{
			speed = STARTING_RISE_SPEED;
			_state = 3; // the rat is re-surfacing
			trace(surfacingPosition);
			x = GameScreen.SCALE_WIDTH*(surfacingPosition/100) + GameScreen.SCREEN_X; // put the rat in a new position based off of the treasure's location
			
			//check to see if the rat is re-surfacing anywhere wierd. If it is, give it a nudge.
			if(GameScreen.SCREEN_X + GameScreen.UPPER_DECK_WIDTH < x && GameScreen.SCREEN_X + GameScreen.LOWER_DECK_X > x)
			{
				//the rat is re-surfacing in the no-man's-land between the two decks. Give it a sideways momentum.
				var shaker:int = Math.random()*2;		
				_horizontalDrift = (shaker == 0 ? -2 : 2);
			}else if(x > GameScreen.SCREEN_X + GameScreen.LOWER_DECK_X + GameScreen.LOWER_DECK_WIDTH)
			{
				//the rat is re-surfacing past the ship's decks
				_horizontalDrift = Math.random()*-5;
			}else if(x < GameScreen.SCREEN_X + 5)
			{
				//the rat is re-surfacing at the left-edge of the screen
				x = GameScreen.SCREEN_X + 5;
			}
		}
	}
}