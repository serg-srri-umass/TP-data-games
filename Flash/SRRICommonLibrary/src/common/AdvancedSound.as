package common{
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.utils.describeType;

	/* AdvancedSound adds functionality to the AS3 Sound class. Each AdvancedSound contains 
	a regular Flash sound. This class adds the ability to fade sounds in and out based on a
	millisecond duration, and the ability to trigger any function on a 'pecent played' of a 
	certain sound. It also provides a series of setters and getters for getting information 
	like 'is this sound playing?' (_isPlaying:Boolean) */
	public class AdvancedSound extends EventDispatcher{
		
		private static const TICK_TIME:int = 40; //40 miliseconds between each timer tick on fade out. Roughly equivolent to 24fps.
		
		private var sound:Sound;	// the sound file.
		
		private var _channel:SoundChannel = new SoundChannel();
		private var _volume:Number = 1;
		private var fadeTimer:Timer; // used to fade out the sound
		private var ticker:int;	// counts for fading.
		private var ticksToComplete:int; // how many ticks must elapse to meet a certain duration. 
		private var soundID:String; //randomly generated ID for debugging multiple instances of this class 

		private var _isPlaying:Boolean = false;		
		private var percentageCounter:Timer = new Timer(1, 1); // used to dispatch events based on percentage reached
		
		private var startPosition:Number = 0; //records the starting positon in ms for fading in this sound. 
											 //changed every time a fadeIn is called; if no start position 
											 //is passed to fadeIn, gets set to 0. 
		
		private var isFadingOut:Boolean = false; //to keep track of state of fades, to throw errors
		private var isFadingIn:Boolean = false; 
		

		//constructor
		public function AdvancedSound(s:Sound, traceEveryFrame:Boolean = false){
			sound = s;
			if(traceEveryFrame){
				var timer:Timer = new Timer(46, 0);
				timer.addEventListener(TimerEvent.TIMER, onEnterFrameHandler);
				timer.start();
			}
			
			soundID = String(Math.round(Math.random()*1000)/1000) //random ID truncated to .000 places
		}
		
		//setters and getters
		public function getChannel():SoundChannel{
			return _channel;
		}
		
		public function getLength():Number{
			return sound.length;
		}
		
		public function setStartPosition(sp:Number):void{
			startPosition = sp;
		}
		
		public function getStartPosition():Number{
			return startPosition;
		}
		
		public function isPlaying():Boolean{
			return _isPlaying;
		}
		
		//cancels the timer set to trigger doOnPercentPlayed functions
		public function stopOnPercentPlayedTimer():void{
			percentageCounter.stop();
		}
		
		//works exactly like sound.play
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel{
			_channel.stop();
			_channel = sound.play(startTime, loops, sndTransform);
			percentageCounter.reset();
			percentageCounter.start();
			_isPlaying = true;
			return _channel;
		}
		
		//stops & resets the sound
		public function stop():SoundChannel{
			_channel.stop();	
			percentageCounter.stop();
			_isPlaying = false;
			return _channel;
		}
		
		//fades sound in linearly over a given millisecond duration
		public function fadeOut(duration:Number = 1000):void{
			if(isFadingOut){
				return; //if sound is already fading out, return without doing anything
			}
			if(isFadingIn){
				cleanFadeIn(new Event("e"));
				fadeOut(duration);
				return;
			}
			//var date:Date = new Date(); UNUSED
			
			trace("fadeOut ID:" + soundID + " Sound:" + sound.toString() + "PercentPlayed: " + (_channel.position/sound.length)*100);
			
			if(duration < 1){
				throw new Error("fade duration must be longer than 1 millisecond.");
			}
			
			ticksToComplete = Math.ceil(duration/40);
			
			ticker = ticksToComplete;
			fadeTimer = new Timer(TICK_TIME, ticksToComplete);
			fadeTimer.addEventListener(TimerEvent.TIMER, tickFadeOut);
			fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeOut);
			fadeTimer.start();
			isFadingOut = true; 
		}
		
		//takes number of times you want to loop the sound after fading, and startPosition if you want 
		//to fade in part-way through the sound. fades sound in linearly over a given millisecond duration. 
		public function fadeIn(duration:Number = 1000, numLoops:int = 0, startPos:Number = 0):void{
			if(isFadingIn){
				return; //if sound is already fading in, return without doing anything. 
			}
			if(isFadingOut){
				cleanFadeOut(new Event("e"));
				fadeIn(duration);
				return;
			}
			//var date:Date = new Date(); UNUSED
			
			if(startPos != 0){
				trace("start position: " + startPos); // for debugging
			}
			
			if(duration < 1){
				throw new Error("fade duration must be longer than 1 millisecond.");
			}
			
			ticksToComplete = Math.ceil(duration/40);
			
			ticker = 0;
			fadeTimer = new Timer(TICK_TIME, ticksToComplete);
			fadeTimer.addEventListener(TimerEvent.TIMER, tickFadeIn);
			fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeIn);
			fadeTimer.start();
			isFadingIn = true; 
			
			_volume = 0;
			startPosition = startPos; 
			_channel = play(startPos, numLoops, null);
			trace("fadeIn ID:" + soundID + " Sound:" + sound.toString() + "PercentPlayed: " + (_channel.position/sound.length)*100);
		}
		
		private var _toDoFunction:Function = function():void{};
		
		//triggers a function (func:Function) after a certain percentage of this sound has been played. 
		//takes percent as a number  0 < x < 1 (arg:Number)
		public function doOnPercentPlayed(arg:Number, func:Function):void{
			if(arg < 0 || arg > 1)
				throw new Error("Percent must range from 0 to 1.");
			
			var percentLength:int = arg * (sound.length-startPosition); //accounting for start position in timer length
			
			if(_isPlaying){
					throw new Error("Cannot add function to an already playing sound.");
			}
			percentageCounter = new Timer(percentLength, 1);
			
			_toDoFunction = func;
			percentageCounter.addEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}		
		
		private function onEnterFrameHandler(e:Event):void{
			trace("Name: " + sound.toString(), "Position: " + (_channel.position/sound.length)*100, "Volume: " + _volume);
		}
			
		public function removeDoOnPercentPlayed():void{
			percentageCounter.removeEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}
		
		public function restoreDoOnPercentPlayed():void{			
			percentageCounter.addEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}
		
		//trigger the function you want to doOnPercentPlayed
		private function onPercentPlayedHandler(e:Event):void{
			_toDoFunction(e);
		}
		
		//ticks through slices of the sound to split volume changes into small increments to 
		//build fadeOut. 
		private function tickFadeOut(e:Event):void{
			ticker--;
			volumeChanger();
		}
		
		//disconnects the fadeOut ticking function from the fade timer, and sets its volume 
		//the rest of the way to 0. Also stops the sound. 
		private function cleanFadeOut(e:Event):void{
			fadeTimer.removeEventListener(TimerEvent.TIMER, tickFadeOut);
			fadeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeOut);	
			_volume = 0;
			stop();
			isFadingOut = false;
		}
		
		//ticks through slices of the sound to split volume changes into small increments to 
		//build fadeIn. 
		private function tickFadeIn(e:Event):void{
			ticker++;
			volumeChanger();
		}
		
		//disconnects the fadeIn ticking function from the fade timer, and sets its volume the 
		//rest of the way to 0. Also stops sound. 
		private function cleanFadeIn(e:Event):void{
			fadeTimer.removeEventListener(TimerEvent.TIMER, tickFadeIn);
			fadeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeIn);
			_volume = 1;
			
			//setting actual soundChannel volume 
			var st:SoundTransform = _channel.soundTransform;
			st.volume = _volume;
			_channel.soundTransform = st;
			
			dispatchEvent(new AdvancedSoundEvent(AdvancedSoundEvent.FULL_VOL));
			isFadingIn = false; 
		}
		
		// sets the volume based on ticker & ticksToComplete
		private function volumeChanger():void{
			_volume = ticker/ticksToComplete;
			var st:SoundTransform = _channel.soundTransform;
			st.volume = _volume;
			_channel.soundTransform = st;
		}
	}
}