package odyssey
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	// The rat MovieClip.
	public class DivingRatMVC extends red_dot{	

		private static const MAX_SPEED:int = 17; // the fastest a rat can move
		private static const STARTING_DIVE_SPEED:int = 8; // how fast the rat falls when it dives
		private static const STARTING_RISE_SPEED:int = -30; // how fast rats rise when they come out of the water
		private static const DECK_TIME:int = 3;	// how many frames a rat spends on deck before it dives
		
		private var surfacingPosition:Number;
		private var _age:int = 0;
		private var _speed:Number;	// how many pixels/frame the rat moves when onscreen
		private var _state:int = 0;	// the states are diving(0), underwater(1), returning(2)
		private var _horizontalDrift:Number = 0; // if a rat can't shoot straight up for some reason, it gets a horizontal drift.
		private var crested:Boolean = false; // used for animating the rats return to the ship.
				
		public function DivingRatMVC(finalPos:Number)
		{
			var colorFrame:int = Math.random()*3 + 1;
			gotoAndStop(colorFrame);	//determines the rat's color
			
			surfacingPosition = finalPos;	// where the rat will resurface. 
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
	
	
		// Attach a rat to the screen. Called from the director.
		public function attach():void
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
			_speed = STARTING_DIVE_SPEED;
			rat.gotoAndPlay(1);
		}
		
		public function detach():void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		// this function is called every frame. It handles the animation
		private function enterFrame(e:Event):void
		{
			_age++;
			if(_age >= DECK_TIME && _state == 0)
			{	// wait X frames before jumping overboard
				if(_speed < MAX_SPEED)
					_speed ++; 
					// acceleration. Tops out at MAX_SPEED
				y += _speed;
				if(y >= GameScreen.WATER_Y)		// the rat has hit the water
				{
					_state = 1;	// the rat is now underwater
					_age = 0;
					y = GameScreen.WATER_Y;
					rat.gotoAndPlay("splash");
					DivingRatDirector.addSplash(x);
				}
			}else if(_state == 2)
			{				
				//the rats leap out of the water
				y += _speed;
				x += _horizontalDrift;
				
				//deceleration:
				if(x < GameScreen.SCREEN_X + GameScreen.UPPER_DECK_WIDTH)
					_speed += 2;	//if the rat is landing on the upper deck, decelerate slower
				else
					_speed += 3;
				
				if(_speed > 0)
				{
					if(!crested)
					{	// at the height of the rat's jump, change the animation.
						crested = true;
						rat.gotoAndPlay("peak");
					}
					
					if(x > GameScreen.SCREEN_X + GameScreen.UPPER_DECK_WIDTH){
						if(GameScreen.calcLowerDeckY(x) + GameScreen.SCREEN_Y < y + 5){
							_state = 4;
							y = GameScreen.SCREEN_Y + GameScreen.calcLowerDeckY(x) - 10;
							rat.gotoAndPlay("disappear");
							DivingRatDirector.countRat();
						}
					}else
					{
						if(GameScreen.calcUpperDeckY(x) + GameScreen.SCREEN_Y < y + 5)
						{
							_state = 4;
							y = GameScreen.SCREEN_Y + GameScreen.calcUpperDeckY(x) - 10;
							rat.gotoAndPlay("disappear");
							DivingRatDirector.countRat();
						}
					}
				}
			}
		}
		
		// the rat is ready to pop back out of the water.
		public function rise():void
		{
			_speed = STARTING_RISE_SPEED;
			rat.gotoAndPlay("leap");
			_state = 2; // the rat is re-surfacing
			// put the rat in a new position based off of the treasure's location
			x = GameScreen.SCALE_WIDTH*(surfacingPosition/100) + GameScreen.SCREEN_X + GameScreen.DISTANCE_TO_SCALE; 
			//check to see if the rat is re-surfacing anywhere wierd. If it is, give it a nudge.
			if(GameScreen.SCREEN_X + GameScreen.UPPER_DECK_WIDTH < x && GameScreen.SCREEN_X + GameScreen.LOWER_DECK_X > x)
			{
				//the rat is re-surfacing in the no-man's-land between the two decks. Give it a sideways momentum.
				var shaker:int = Math.random()*2;		
				_horizontalDrift = (shaker == 0 ? -1 : 1);
			}else if(x > GameScreen.LOWER_DECK_X + GameScreen.LOWER_DECK_WIDTH)
			{
				//the rat is re-surfacing past the ship's decks
				_horizontalDrift = -15;
			}else if(x < GameScreen.SCREEN_X + 5)
			{
				//the rat is re-surfacing at the left-edge of the screen
				x = GameScreen.SCREEN_X + 5;
			}
			DivingRatDirector.addSplash(x);
		}
	}
}