package chainsaw.sound{
	
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import common.SafeTimer;
	import flash.utils.describeType;

	/* AdvancedSound adds functionality to the AS3 Sound class. Each AdvancedSound contains 
	a regular Flash sound. This class adds the ability to fade sounds in and out based on a
	millisecond duration, and the ability to trigger any function on a 'pecent played' of a 
	certain sound. It also provides a series of setters and getters for getting information 
	like 'is this sound playing?' (_isPlaying:Boolean) */
	public class AdvancedSound extends EventDispatcher{
		
		private static const TICK_TIME:int = 40; //40 milliseconds between each timer tick on fade out. Roughly equivolent to 24fps.
		
		private var sound:Sound = null;	// the sound file.
		
		private var _channel:SoundChannel = new SoundChannel();
		private var _volume:Number = 1;
		private var fadeTimer:SafeTimer = new SafeTimer(1,1); // used to fade out the sound
		private var ticker:int;	// counts for fading.
		private var ticksToComplete:int; // how many ticks must elapse to meet a certain duration. 
		private var soundID:int; //serially generated ID for debugging multiple instances of this class 
		private var name:String;
		
		private var _isPlaying:Boolean = false;		
		private var percentageCounter:SafeTimer = new SafeTimer(1,1); // used to dispatch events based on percentage reached
		
		private var startPosition:Number = 0; //records the starting positon in ms for fading in this sound. 
											 //changed every time a fadeIn is called; if no start position 
											 //is passed to fadeIn, gets set to 0. 
		
		private var isFadingOut:Boolean = false; //to keep track of state of fades, to throw errors
		private var isFadingIn:Boolean = false; 
	
		public static var debug:SoundDebug = new SoundDebug(); //static instance of SoundDebug for all AdvancedSounds
		
		public static var nextSoundID:int = 0;
		private var debugTimer:SafeTimer = new SafeTimer(46, 0); //for printing out things every frame


		//constructor
		public function AdvancedSound(s:Sound, traceEveryFrame:Boolean = false){
			sound = s;
			name = sound.toString();
			name = name.slice(21); //trim out unnecessary information 
			//if( nextSoundID == 9) { throw new Error("creating 10th sound"); }		
			soundID = ++nextSoundID; //making ID into next serial

			
			//adds entry for this sound to the stateList in SoundDebug
			debug.addEntry(new AdvancedSoundState(name, soundID, _isPlaying, this.isFadingIn, this.isFadingOut));

			checkSounds("AdvancedSound constructor ID "+soundID);
			debugTimer.addEventListener(TimerEvent.TIMER, onEnterFrameHandler);
			debugTimer.start();
			
			/*if(traceEveryFrame){
				var timer:SafeTimer = new SafeTimer(46, 0);
				timer.addEventListener(TimerEvent.TIMER, onEnterFrameHandler);
				timer.start();
			}old debug code*/
			
			//soundID = String(Math.round(Math.random()*1000)/1000) //random ID truncated to .000 places
		}
		
		// Called just before we destroy this object. We want to stop our sound and free up resources that is uses.
		public function shutDown():void {
			if(fadeTimer){ //if it exists, stop it 
				fadeTimer.clean();
			}
			if(percentageCounter){ //if it exists, stop it 
				percentageCounter.clean();
			}
				
			if(_channel){
				_channel.stop();
			} 
			
			if(debugTimer){
				debugTimer.clean();
			}

			this.sound = null;
			this._channel = null;
			this.fadeTimer = null;
			this.percentageCounter = null;
			
			debug.removeEntry(this.soundID);
		}
		
		public static function checkSounds( where:String ):void{
			if(debug.getNumSounds() > 12){
				throw new Error("there are more than twelve sounds instantiated");
			}else{
				trace("checkSounds: there are " + debug.getNumSounds() + " sounds instantiated");
			}
			trace( where+": Num sounds playing "+debug.getNumSoundsPlaying());
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
			percentageCounter.clean();
		}
		
		public function getDebug():SoundDebug{
			return debug;
		}

		public function getIsFadingOut():Boolean{
			return this.isFadingOut;
		}
		
		public function getIsFadingIn():Boolean{
			return this.isFadingIn;
		}
		
		//works exactly like sound.play
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel{
			if(_channel){
				_channel.stop();
			}
			
			_channel = sound.play(startTime, loops, sndTransform);
			
			if(percentageCounter){
				percentageCounter.reset();
				percentageCounter.start();
			}
			_isPlaying = true;
			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsPlaying(true);
			}
			checkSounds("AdvancedSound.play: ");
			return _channel;
		}
		
		//stops & resets the sound
		public function stop():SoundChannel{
			if(_channel){
				_channel.stop();	
				_channel = new SoundChannel();
			}
			if(percentageCounter){
				percentageCounter.stop();
				percentageCounter.reset();
			}
			_isPlaying = false;
			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsPlaying(false);
			}
			return _channel;
		}
		
		//fades sound in linearly over a given millisecond duration
		public function fadeOut(duration:Number = 1000):void{
			if(this.isFadingOut){
				return; //if sound is already fading out, return without doing anything
			}
			if(this.isFadingIn){
				cleanFadeIn(new Event("e"));
				fadeOut(duration);
				return;
			}
			//var date:Date = new Date(); UNUSED
			
			// if(_channel && sound){
			// 	trace("fadeOut ID:" + soundID + " Sound:" + sound.toString() + "PercentPlayed: " + (_channel.position/sound.length)*100);
			// }
			
			if(duration < 1){
				throw new Error("fade duration must be longer than 1 millisecond.");
			}
			
			ticksToComplete = Math.ceil(duration/40);
			
			ticker = ticksToComplete;
			if(fadeTimer){
			fadeTimer.clean();
			}
			fadeTimer = new SafeTimer(TICK_TIME, ticksToComplete);
			fadeTimer.addEventListener(TimerEvent.TIMER, tickFadeOut);
			fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeOut);
			fadeTimer.start();
			this.isFadingOut = true;
			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsFadingOut(true);
			}
		}
		
		//takes number of times you want to loop the sound after fading, and startPosition if you want 
		//to fade in part-way through the sound. fades sound in linearly over a given millisecond duration. 
		public function fadeIn(duration:Number = 1000, numLoops:int = 0, startPos:Number = 0):void{
			if(this.isFadingIn){
				return; //if sound is already fading in, return without doing anything. 
			}
			if(this.isFadingOut){
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
			fadeTimer.clean();
			fadeTimer = new SafeTimer(TICK_TIME, ticksToComplete);
			fadeTimer.addEventListener(TimerEvent.TIMER, tickFadeIn);
			fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cleanFadeIn);
			fadeTimer.start();
			this.isFadingIn = true;
			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsFadingIn(true);
			}

			_volume = 0;
			startPosition = startPos; 
			_channel = play(startPos, numLoops, null);
			//trace("fadeIn ID:" + soundID + " Sound:" + sound.toString() + "PercentPlayed: " + (_channel.position/sound.length)*100);
		}
		
		private var _toDoFunction:Function = function():void{};
		
		//triggers a function (func:Function) after a certain percentage of this sound has been played. 
		//takes percent as a number  0 < x < 1 (arg:Number)
		public function doOnPercentPlayed(arg:Number, func:Function):void{
			if(arg < 0 || arg > 1)
				throw new Error("Percent must range from 0 to 1.");
			
			var percentLength:int = arg * (sound.length-startPosition); //accounting for start position in SafeTimer length
			
			if(_isPlaying){
					throw new Error("Cannot add function to an already playing sound.");
			}
			percentageCounter.clean();
			percentageCounter = new SafeTimer(percentLength, 1);
			
			_toDoFunction = func;
			percentageCounter.addEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}		
		
		private function onEnterFrameHandler(e:Event):void{
			//trace("Name: " + sound.toString(), "Position: " + (_channel.position/sound.length)*100, "Volume: " + _volume);
			// if(sound){
			// 	if(sound.toString() == "[object SoundHandler_revUpSoundMP3]"){
			// 		trace("revUp position: " + Math.round((_channel.position/sound.length) *100) + "%");
			// 	}else if(sound.toString() == "[object SoundHandler_revDownSoundMP3]"){
			// 		trace("revDown position: " + Math.round((_channel.position/sound.length) *100) + "%");
			// 	}
			// }
		}
			
		/*public function removeDoOnPercentPlayed():void{
			percentageCounter.removeEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}*/
		
		/*public function restoreDoOnPercentPlayed():void{			
			percentageCounter.addEventListener(TimerEvent.TIMER_COMPLETE, onPercentPlayedHandler);
		}*/
		
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
			//dispatches event for sound having finished fading out
			dispatchEvent(new AdvancedSoundEvent(AdvancedSoundEvent.FADED_OUT));
			if(fadeTimer){
				fadeTimer.clean();
			}
			
			_volume = 0;
			stop();
			_channel = new SoundChannel();
			this.isFadingOut = false;
			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsFadingOut(false);
			}
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
			//dispatches event for sound having finished fading in
			dispatchEvent(new AdvancedSoundEvent(AdvancedSoundEvent.FADED_IN));
			if(fadeTimer){
				fadeTimer.clean();
			}
		
			_volume = 1;
			
			//setting actual soundChannel volume 
			if(_channel){
				var st:SoundTransform = _channel.soundTransform;
				st.volume = _volume;
				_channel.soundTransform = st;
			}
			this.isFadingIn = false;

			if(debug.stateList[soundID]){
				debug.stateList[soundID].setIsFadingIn(false);
			}
		}
		
		// sets the volume based on ticker & ticksToComplete
		private function volumeChanger():void{
			if(_channel){_volume = ticker/ticksToComplete;
				var st:SoundTransform = _channel.soundTransform;
				st.volume = _volume;
				_channel.soundTransform = st;
			}
		}
	}
}
