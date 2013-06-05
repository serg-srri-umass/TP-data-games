package odyssey
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import odyssey.events.RatEventDispatcher;
	
	// Manages the behavior of all rat sprites.
	public class DivingRatDirector
	{	
		private static const MAX_RATS_ONSCREEN:int = 150;	//  how many sprites can be on-screen at once.
		private static const MAX_UNDERWATER_TIME:int = 25;		// how many frames pass between when the last rat goes underwater, and the first resurfaces.
	
		public static var ratArray:Array = new Array();	// This array holds all rats that currently exist.	
		private static var removalRatArray:Array = new Array();	// Holds all rats that will need to be removed from the screen
		
		private static var _container:UIComponent;  // the UI component where Rats will be drawn to. It's set in the init function.
		private static var _dispatcher:RatEventDispatcher = new RatEventDispatcher(); // object that dispatches rat events		
		private static var _frameCounter:Timer = new Timer(37, 0);	// this timer ticks at roughly 24fps. Used to manage animations
		private static var _endSwitch:Timer = new Timer(100, 1);	// this timer counts down the time between when the last rat goes back onboard and the button is clear to press again
		private static var _killSwitch:Timer;	// a failsafe: if the animation doesn't stop itself after completing, the killswitch will stop it after X miliseconds.

		private static var _ratsAttached:int; //how many rats have dived
		private static var _ratsToAttach:int; //how many rats should dive on the current frame
		private static var _timeUnderwater:int;	//how many frames have elapsed since the last rat to dive went underwater
		private static var _ratCounter:int = 1; 	//counts how many rats have returned to the ship
		
		public static function get dispatcher():RatEventDispatcher
		{						
			return _dispatcher;		
		}
	
		// This method tells the DivingRatManager where to draw its rats to. It has to be called from ShipOdyssey.mxml when everything else is init'd.
		public static function init( in_container:UIComponent):void
		{
			_container = in_container;
			_frameCounter.addEventListener( TimerEvent.TIMER, manageRats);
			_endSwitch.addEventListener( TimerEvent.TIMER, completeDive);
		}
		
		// pass this method a point on the scale, and it will create a rat at that point
		public static function addRat( in_x:Number):Boolean
		{
			if( ratArray.length < MAX_RATS_ONSCREEN)
			{
				ratArray.push( new DivingRatMVC( in_x));
				return true;
			}else{
				// no rat is added (because the max rats onscreen was exceeded)
				return false;		
			}
		}
		
		public static function releaseRats():void
		{
			_dispatcher.dispatchReleased(); // dispatch a RatEvent, that says the rats have been released.

			_ratsAttached = 0;	//no rats have been released so far
			_ratsToAttach = 1;	//start out by releasing 1 rat.
			_timeUnderwater = 0;
			_ratCounter = 0;
			
			//every frame the rats are out, the function "manageRats" will be called.
			_killSwitch = new Timer(4000, 1)
			_frameCounter.start();
			_killSwitch.addEventListener( TimerEvent.TIMER, completeDive);
			_killSwitch.start();
		}
		
		//every frame the rats are out, this method is called. 
		private static function manageRats(e:Event):void
		{
			if( _timeUnderwater == 0 && _ratsAttached < ratArray.length)
			{
				// if there are still rats on board, pour them out!
				manageBellCurve( true);
			} else if( _timeUnderwater < MAX_UNDERWATER_TIME)
			{
				//wait the MAX_UNDERWATER_TIME has elapsed. Then resurface the rats
				_timeUnderwater++;
				if(_timeUnderwater == MAX_UNDERWATER_TIME)
				{
					_ratsAttached = 0;		//reset these values, because rising uses the same logic as diving.
					_ratsToAttach = 1;
				}
			}else if( _ratsAttached < ratArray.length){
				manageBellCurve( false);
			}
		}
		
		// Activates rats in a bell curve. This function is used both to tell rats to dive, and to rise back out of the water.
		// If diving is true, it pours rats out of the ship. If it's false, it tells already existing rats to jump out of the water.
		private static function manageBellCurve(diving:Boolean = true):void{
			if( _ratsAttached + _ratsToAttach <= (ratArray.length / 2))
			{
				// every frame, increase how many rats activate, until 1/2 of the rats are active
				if(diving)
					attachRats(_ratsToAttach);
				else
					riseRats(_ratsToAttach);
				
				_ratsAttached += _ratsToAttach;
				_ratsToAttach++;
			} else if( _ratsToAttach > 0 && _ratsAttached + _ratsToAttach > (ratArray.length / 2) && _ratsAttached + _ratsToAttach < ratArray.length)
			{
				//after 1/2 of the rats are active, slow down how many active per frame
				if(diving)
					attachRats(_ratsToAttach);
				else
					riseRats(_ratsToAttach);
				
				_ratsAttached += _ratsToAttach;
				_ratsToAttach--;
			} else if( _ratsAttached < ratArray.length)
			{
				//activate the remainder:
				_ratsToAttach = ratArray.length - _ratsAttached;

				if(diving)
					attachRats(_ratsToAttach);
				else
					riseRats(_ratsToAttach);
				
				_ratsAttached += _ratsToAttach;
			}
		}
		
		// attaches X rats to the screen
		private static function attachRats(arg:int):void
		{
			for( var i:int = 0; i < arg; i++){
				var thisRat:DivingRatMVC = ratArray[i + _ratsAttached];
				_container.addChild(thisRat);
				thisRat.attach();
				removalRatArray.push(thisRat);
			}
		}
		
		// tells X rats to return from under water
		private static function riseRats( arg:int):void
		{
			for(var i:int = 0; i < arg; i++){
				var thisRat:DivingRatMVC = ratArray[i + _ratsAttached];
				thisRat.rise();
			}
		}

		// Splashing code. The splash clip removes itself when it's done playing.
		public static function addSplash( x:Number):void
		{
			const SPLASH1_CHANCE:Number = 0.2;	// the chance of using the rarer splash animation
			var s:MovieClip = new splash();
			if( Math.random() < SPLASH1_CHANCE)
				s.gotoAndStop(1);	// there are two splash animations; this one is rarer.
			else
				s.gotoAndStop(2);
			const SPLASH_WIDTH:int = 20;
			const SPLASH_HEIGHT:int = 15;
			s.x = x - SPLASH_WIDTH;
			s.y = GameScreen.WATER_Y - SPLASH_HEIGHT + Math.random()*5;	//add some Y-jitter to the splashes
			_container.addChild(s);
		}
		
		// finish up the dive. Take off any rats who are still on screen. 
		private static function completeDive( e:TimerEvent = null):void
		{
			while( removalRatArray.length > 0)
			{
				// go through the rat array, and throw away everything in it.
				var screenRat:DivingRatMVC = removalRatArray.pop();
				screenRat.detach();
				screenRat.parent.removeChild(screenRat);		
			}
			ratArray = new Array();			
			_frameCounter.stop();	//stop the timers that were started when the rats were dispatched.
			_killSwitch.stop();
			_endSwitch.stop();
			
			//if the "complete dive" was called because the animation was aborted, dispatch the appropriate event.
			if(e.type == "abortDive")
				_dispatcher.dispatchCancelled();
			else
				_dispatcher.dispatchReturned();	// dispatch a RatEvent, that says the rats are gone.
		}
		
		// cancel an ongoing animation:
		public static function abortDive():void
		{
			if(removalRatArray.length > 0)
				completeDive(new TimerEvent("abortDive"));
		}
		
		// when a ratMVC finishes up its animation, it calls this function.
		// tallies up if all the rats have returned. If they have, it prepares to end the dive
		public static function countRat():void
		{
			_ratCounter++;
			if(_ratCounter >= ratArray.length)
				_endSwitch.start();	
				// the end switch creates a buffer between when the last rat returns to the ship, and the dive is called over. 
		}
	}
}