package odyssey
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	// Manages the behavior of all rat sprites.
	public class DivingRatDirector
	{	
		private static const SCALE_WIDTH:int = 265;
		
		private static var _container:UIComponent;  // the UI component where Rats will be drawn to. It's set in the init function.
		private static var _dispatcher:RatEventDispatcher = new RatEventDispatcher(); // object that dispatches rat events
		public static var ratArray:Array = new Array();	// This array holds all rats that currently exist.	
		
		public static function get dispatcher():RatEventDispatcher
		{						
			return _dispatcher;		
		}
	
		// This method tells the DivingRatManager where to draw its rats to. It has to be called from ShipOdyssey.mxml when everything else is init'd.
		public static function init( in_container:UIComponent):void
		{
			_container = in_container;
		}
		
		// pass this method a point on the scale, and it will create a rat at that point
		public static function addRat( in_x:Number):DivingRatMVC
		{
			var newRat:DivingRatMVC = new DivingRatMVC(in_x);
			ratArray.push(newRat);
			return newRat;
		}

		// These functions are modded from Russ' Code:
		public static function initDots():void
		{
			_dispatcher.dispatchReleased();	// dispatch a RatEvent, that says the rats have been released.
			for(var i:int = 0; i < ratArray.length; i++)
			{
				ratArray[i].x = SCALE_WIDTH * (ratArray[i].x/100);
				_container.addChild(ratArray[i]);
			}
			var timerObj:Timer = new Timer(300, 1);
			timerObj.addEventListener(TimerEvent.TIMER, completeDive);
			timerObj.start();
		}
		
		//unloads the blips; the rats are done.
		private static function completeDive(eventObject:TimerEvent):void
		{	
			while(ratArray.length > 0)
			{
				// go through the rat array, and throw away everything in it.
				var screenRat:DivingRatMVC = ratArray.pop();
				screenRat.parent.removeChild(screenRat);		
			}
			_dispatcher.dispatchReturned();	//dispatch a RatEvent, that says the rats are gone.
		}
	}
}