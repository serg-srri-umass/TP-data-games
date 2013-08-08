package chainsaw{
	public class SoundHandler{
		
		//our imports
		import common.AdvancedSound;
		import common.AdvancedSoundEvent;
		
		import flash.events.Event;
		import flash.media.*;
		
		//constructor
		public function SoundHandler(){
			initSounds();
		}
		
		/* This class handles all sounds related the chainsaw in the Chainsaw game. It has 6 public 
		functions that respond to events in the game: onStart, onGameEnd, onMouseDown, onMouseUp, 
		onMouseOverLog, and onMouseOutLog. These functions trigger all necessary fades and transition 
		for the chainsaw to behave according to these events. The calls to the public event functions 
		can all be found in Chainsaw.mxml Author: Russell Phelan, russ.phelan@gmail.com */
		
		//begin sound embeds
		//looped sounds
		//runSound. Is looped when mouseDown. High-rpm sound with no loading or revving. 
		[Embed("../src/embedded_assets/runSound.mp3")]
		private var runSoundMP3:Class;
		private var mRunSound:AdvancedSound = new AdvancedSound(new runSoundMP3() as Sound);
		
		//loadSound. Is looped when mouseDown, and mouse is over log. Loaded down engine sound. 
		[Embed("../src/embedded_assets/loadSound.mp3")]
		private var loadSoundMP3:Class;
		private var mLoadSound:AdvancedSound = new AdvancedSound(new loadSoundMP3() as Sound);

		//idleSound. Is looped when mouseUp, and the chainsaw is at rest. Steady idle. 
		[Embed("../src/embedded_assets/idleSound.mp3")]
		private var idleSoundMP3:Class;
		private var mIdleSound:AdvancedSound = new AdvancedSound(new idleSoundMP3() as Sound);
		
		//transition sounds
		//startUpSound. Is played when the start button is pressed. Chainsaw is pulled twice, then comes to life. 
		[Embed("../src/embedded_assets/startUpSound.mp3")]
		private var StartUpSoundMP3:Class;
		private var mStartUpSound:AdvancedSound = new AdvancedSound(new StartUpSoundMP3() as Sound);
		
		//shutDownSound. Played when you run out of gas, or hit the stop button. Is linked to endGame function in Chainsaw.mxml
		[Embed("../src/embedded_assets/shutDownSound.mp3")]
		private var shutDownSoundMP3:Class;
		private var mShutDownSound:AdvancedSound = new AdvancedSound(new shutDownSoundMP3() as Sound);
		
		//revUpSound. Played when you mouseDown during an idle. Transitions into runSound. A revving up of the chainsaw motor. 
		[Embed("../src/embedded_assets/revUpSound.mp3")]
		private var revUpSoundMP3:Class;
		private var mRevUpSound:AdvancedSound = new AdvancedSound(new revUpSoundMP3() as Sound);
		
		//revDownSound. Played when you mouseUp during the runSound. Transitions into idleSound. A revving down of the chainsaw motor. 
		[Embed("../src/embedded_assets/revDownSound.mp3")]
		private var revDownSoundMP3:Class;
		private var mRevDownSound:AdvancedSound = new AdvancedSound(new revDownSoundMP3() as Sound);
		
		//loadUpSound. Played when you mouseOut from a log. Transitions from loadSound to runSound. Chainsaw is revving back up, but is still loaded. 
		[Embed("../src/embedded_assets/loadUpSound.mp3")]
		private var loadUpSoundMP3:Class;
		private var mLoadUpSound:AdvancedSound = new AdvancedSound(new loadUpSoundMP3() as Sound, false);
		
		//loadDownSound. Played when you mouseOver a log, with mouseDown. Sound of chainsaw loading down into log, decreasing rpms. 
		[Embed("../src/embedded_assets/loadDownSound.mp3")]
		private var loadDownSoundMP3:Class;
		private var mLoadDownSound:AdvancedSound = new AdvancedSound(new loadDownSoundMP3() as Sound);
		
		//instance variables
		private var mIdleSound2:AdvancedSound; //references the new instance of idle sound that we fade into when looping idle sound
		private var mRunSound2:AdvancedSound;
		private var mLoadSound2:AdvancedSound;
		private var loopIdleSound:Boolean 	= false;
		private var loopRunSound:Boolean 	= true;
		private var loopLoadSound:Boolean 	= false;
		private var mouseEnabled:Boolean 	= false; //used to disable functions that listen to mouse events. 
		private var doNotRun:Boolean 		= false; /*used to keep loadUpSound from triggering loadToRunTrans if we have already 
													 initiated a loadUpToLoadDownTrans()*/
		private var inLog:Boolean			= false;  //keeps trackof whether we are in a log, which determines whether or not we should be hearing load sounds.
		
		//fade time constants, in milliseconds
		private static const runLoopFadeTime:Number 				= 100;
		private static const loadLoopFadeTime:Number 				= 100;
		private static const idleLoopFadeTime:Number 				= 100;
		private static const startToIdleFadeTime:Number 			= 100;
		private static const idleToRunFadeTime:Number 				= 100;
		private static const runToIdleFadeTime:Number 				= 100;
		private static const runToLoadFadeTime:Number 				= 100;
		private static const loadToRunFadeTime:Number 				= 100;
		private static const revToRunTransFadeTime:Number 			= 100;
		private static const revToIdleTransFadeTime:Number 			= 100;
		private static const loadToRunTransFadeTime:Number 			= 100;
		private static const runToLoadTransFadeTime:Number 			= 100;
		private static const revUpToLoadDownTransFadeTime:Number 	= 100;
		private static const revUpToRevDownTransFadeTime:Number	    = 100;
		private static const revDownToRevUpTransFadeTime:Number 	= 100;
		private static const loadDownToLoadUpTransFadeTime:Number   = 100;
		private static const loadUpToLoadDownTransFadeTime:Number   = 100;
		private static const startUpToRunFadeTime:Number 			= 100;
		
		//public functions
		public function setMouseEnabled(bool:Boolean):void{
			mouseEnabled = bool;
		}
		
		//start and end event handlers
		public function onStart():void{
			mStartUpSound.doOnPercentPlayed(0.9, startToIdle);
			mStartUpSound.play();
		}
		
		//fades the startUp sound out so that we can cancel it when someone presses 'stop' during countdown 
		public function cancelStart():void{
			mStartUpSound.fadeOut(100);
		}
		
		public function onGameEnd():void{
			trace("onGameEnd");
			//all these 'ifs' check if sounds are playing, and fade them out if they are
			if(mRunSound && mRunSound.isPlaying()){
				mRunSound.fadeOut(100);
				mRunSound.stopOnPercentPlayedTimer();
			}
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(100);
				mRunSound2.stopOnPercentPlayedTimer();
			}
			if(mIdleSound && mIdleSound.isPlaying()){
				mIdleSound.fadeOut(100);
				mIdleSound.stopOnPercentPlayedTimer();
			}
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(100);
				mIdleSound2.stopOnPercentPlayedTimer();
			}
			if(mRevUpSound && mRevUpSound.isPlaying()){
				mRevUpSound.fadeOut(100);
				mRevUpSound.stopOnPercentPlayedTimer();
			}
			if(mRevDownSound && mRevDownSound.isPlaying()){
				mRevDownSound.fadeOut(100);
				mRevDownSound.stopOnPercentPlayedTimer();
			}
			if(mLoadDownSound && mLoadDownSound.isPlaying()){
				mLoadDownSound.fadeOut(100);
				mLoadDownSound.stopOnPercentPlayedTimer();
			}
			if(mLoadUpSound && mLoadUpSound.isPlaying()){
				mLoadUpSound.fadeOut(100);
				mLoadUpSound.stopOnPercentPlayedTimer();
			}
			if(mLoadSound && mLoadSound.isPlaying()){
				mLoadSound.fadeOut(100);
				mLoadSound.stopOnPercentPlayedTimer();
			}
			//bring in the shutdown sound 
			mShutDownSound.fadeIn(100);
			mouseEnabled = false; 
		}
		
		//MouseEvent handling functions
		public function onMouseDown(e:Event):void{
			if(mouseEnabled){
				trace("mouseDown");
				if(mRevDownSound.isPlaying() && !mRevUpSound.isPlaying()){
					revDownToRevUpTrans();
				}else if(mStartUpSound && mStartUpSound.isPlaying()){
					startUpToRun();
				}else{
					idleToRun();
				}
			}
			return;
		}
		
		public function onMouseUp(e:Event):void{
			if(mouseEnabled){
				trace("mouseUp");
				if(mRevUpSound.isPlaying() && !mRevDownSound.isPlaying()){
					revUpToRevDownTrans();
				}else{
					runToIdle();
				}
				if(mLoadSound && mLoadSound.isPlaying()){
					mLoadSound.fadeOut(100);
				}
				if(mLoadDownSound && mLoadDownSound.isPlaying()){
					mLoadDownSound.fadeOut(100);
				}
				if(mLoadUpSound && mLoadUpSound.isPlaying()){
					mLoadUpSound.fadeOut(100);
				}
			}
			return;
		}
		
		public function onMouseOverLog(e:Event):void{
			if(mouseEnabled){
				inLog = true;
				trace("mouseOverLog");
				if(mLoadSound && mLoadUpSound.isPlaying()){
					loadUpToLoadDownTrans();
				}else if(mRunSound && mRunSound.isPlaying()){
					runToLoad();
				}else if(mRunSound2 && mRunSound2.isPlaying()){
					runToLoad();
				}else if(mRevUpSound && mRevUpSound.isPlaying()){
					revUpToLoadDownTrans();
				}
				return;
			}
			return;
		}
		
		public function onMouseOutLog(e:Event):void{
			if(mouseEnabled){
				inLog = false;
				trace("mouseOutLog");
				loopLoadSound = false;
				if(mLoadDownSound && mLoadDownSound.isPlaying()){
					loadDownToLoadUpTrans();
				}
				if(mLoadSound && mLoadSound.isPlaying()){
					loadToRun();
				}else if(mLoadSound2 && mLoadSound2.isPlaying()){
					loadToRun();
				}
			}
			return;
		}
		
		//used to cause a mouseUp when player leaves the stage with the chainsaw revved up 
		public function onMouseOutStage(e:Event):void{
			onMouseUp(e);
		}
		
		//initialization 
		private function initSounds():void{
			//doOnPercentPlayeds
			mIdleSound.doOnPercentPlayed(.92, idleLoop);
			mRevUpSound.doOnPercentPlayed(.92, revToRunTrans);
			mRevDownSound.doOnPercentPlayed(.95, revToIdleTrans);
			mRunSound.doOnPercentPlayed(.92, runLoop);		
			mLoadDownSound.doOnPercentPlayed(.92, runToLoadTrans);
			mLoadUpSound.doOnPercentPlayed(.92, loadToRunTrans);
			mLoadSound.doOnPercentPlayed(.92, loadLoop);
		}
		
		//fade handling
		private function startToIdle(e:Event):void{
			trace("startToIdle");
			mStartUpSound.fadeOut(startToIdleFadeTime);
			mIdleSound.fadeIn(startToIdleFadeTime);
			loopIdleSound = true;
		}
		
		private function idleToRun():void{
			trace("idleToRun");
			loopIdleSound = false; 
			mIdleSound.fadeOut(idleToRunFadeTime);
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(idleToRunFadeTime);
			}
			mRevUpSound.fadeIn(idleToRunFadeTime);
		}
		
		//triggered when mouseDown is pressed during startUpSound 
		private function startUpToRun():void{
			trace("startUpToRun");
			mStartUpSound.fadeOut(startUpToRunFadeTime);
			mRevUpSound.fadeIn(startUpToRunFadeTime);
		}
			
		private function runToIdle():void{
			trace("runToIdle");
			loopRunSound = false; 
			mRunSound.fadeOut(runToIdleFadeTime);
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if( mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(runToIdleFadeTime);
			}
			mRevDownSound.fadeIn(runToIdleFadeTime);
		}
		
		private function runToLoad():void{
			trace("runToLoad");
			if(inLog){
			mRunSound.fadeOut(runToLoadFadeTime);
			loopRunSound = false;
			
			//mLoadUpSound.restoreDoOnPercentPlayed();
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(runToLoadFadeTime);
			}
			mLoadDownSound.fadeIn(runToLoadFadeTime);
			}else{
				return;
			}
		}
		
		private function loadToRun():void{
			trace("loadToRun");
			loopLoadSound = false; 

			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if( mLoadSound2 && mLoadSound2.isPlaying()){
				mLoadSound2.fadeOut(loadToRunFadeTime);
			}
			if(mLoadSound && mLoadSound.isPlaying()){
				mLoadSound.fadeOut(loadToRunFadeTime);
			}
			mLoadUpSound.fadeIn(loadToRunFadeTime);
		}
		
		//transition clip handling
		private function revToRunTrans(e:Event = null):void{
			if(!inLog){
				trace("revToRunTrans");
				mRevUpSound.fadeOut(revToRunTransFadeTime);
				mRunSound.fadeIn(revToRunTransFadeTime);
				loopRunSound = true;
			}else{
				return;
			}
		}
		
		private function revToIdleTrans(e:Event = null):void{
			trace("revToIdleTrans");
			mRevDownSound.fadeOut(revToIdleTransFadeTime);
			mIdleSound.fadeIn(revToIdleTransFadeTime);
			loopIdleSound = true;
		}
		
		private function loadToRunTrans(e:Event = null):void{
			
			//skips this function if we've already initiated a loadUpToLoadDownTrans()
			if(doNotRun){
				trace("loadToRunTrans SKIPPED");
				return;
			}
			
			//trace with time information, in ms since 1970
			var date:Date = new Date()
			trace("loadToRunTrans" + String(date.time));
			
			mLoadUpSound.fadeOut(loadToRunTransFadeTime);
			mRunSound.fadeIn(loadToRunTransFadeTime);
			loopRunSound = true;
		}
		
		private function runToLoadTrans(e:Event = null):void{
			trace("runToLoadTrans");
			if(inLog){
				mLoadDownSound.fadeOut(runToLoadTransFadeTime);
				mLoadSound.fadeIn(runToLoadTransFadeTime);
				loopLoadSound = true;
			}else{
				return;
			}
		}
		
		private function revUpToLoadDownTrans():void{
			trace("revUpToLoadDownTrans");
			if(inLog){
				mRevUpSound.fadeOut(revUpToLoadDownTransFadeTime);
				mLoadDownSound.fadeIn(revUpToLoadDownTransFadeTime);
			}else{
				return;
			}
		}
		
		private function revUpToRevDownTrans():void{
			trace("revUpToRevDownTrans");
			loopRunSound = false; 
			mRunSound.fadeOut(revUpToRevDownTransFadeTime);
			mIdleSound.fadeOut(revUpToRevDownTransFadeTime);
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(revUpToRevDownTransFadeTime);
			}
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(revUpToRevDownTransFadeTime);
			}
			mRevUpSound.fadeOut(revUpToRevDownTransFadeTime);
			mRevDownSound.setStartPosition(mapPosition(mRevUpSound.getChannel().position, mRevUpSound.getLength(), mRevDownSound.getLength()));
			mRevDownSound.doOnPercentPlayed(.92, revToIdleTrans);
			mRevDownSound.fadeIn(revUpToRevDownTransFadeTime, 0, mRevDownSound.getStartPosition());
		}
		
		private function revDownToRevUpTrans():void{
			trace("revDownToRevUpTrans");
			loopRunSound = false; 
			mRunSound.fadeOut(revDownToRevUpTransFadeTime);
			mIdleSound.fadeOut(revDownToRevUpTransFadeTime);
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(revDownToRevUpTransFadeTime);
			}
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(revDownToRevUpTransFadeTime);
			}
			mRevDownSound.fadeOut(revDownToRevUpTransFadeTime);
			mRevUpSound.setStartPosition(mapPosition(mRevDownSound.getChannel().position, mRevDownSound.getLength(), mRevUpSound.getLength()));
			mRevUpSound.doOnPercentPlayed(.92, revToRunTrans);
			mRevUpSound.fadeIn(revDownToRevUpTransFadeTime, 0, mRevUpSound.getStartPosition());
		}
		
		private function loadDownToLoadUpTrans():void{
			
			//trace with time information, in ms since 1970
			var date:Date = new Date()
			trace("loadDownToLoadUpTrans" + String(date.time-1375884900000));
			
			doNotRun = false; 
			
			loopRunSound = false; 
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mRunSound && mRunSound.isPlaying()){
				mRunSound.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			if(mIdleSound && mIdleSound.isPlaying()){
				mIdleSound.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(loadDownToLoadUpTransFadeTime);
			}
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(loadDownToLoadUpTransFadeTime);
			}
			mLoadDownSound.fadeOut(loadDownToLoadUpTransFadeTime);
			mLoadUpSound.fadeIn(loadDownToLoadUpTransFadeTime);
		}
		
		private function loadUpToLoadDownTrans():void{
			
			//trace with time information, in ms since 1970
			var date:Date = new Date()
			trace("loadUpToLoadDownTrans" + String(date.time-1375884900000));
			
			doNotRun = true; //keeps loadToRunTrans from being called if we have already called this function. 
			
			loopRunSound = false; 
			
			//removes the OnPercentPlayed to keep it from triggering loadUpToRunTrans after we've 
			//already called this transition instead
			//mLoadUpSound.removeDoOnPercentPlayed(); 
			
			//to fade out all things that shouldn't be playing in case they are. checks to see 
			//if they exist first. 
			if(mRunSound && mRunSound.isPlaying()){
				mRunSound.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			if(mIdleSound && mIdleSound.isPlaying()){
				mIdleSound.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(loadUpToLoadDownTransFadeTime);
			}
			mLoadUpSound.fadeOut(loadUpToLoadDownTransFadeTime);
			mLoadDownSound.fadeIn(loadUpToLoadDownTransFadeTime);
		}
		
		//loop handling
		/* makes new instance of idle sound in mIdleSound2. when mIdleSound2 reaches full vol, 
		trigger switchIdleReferences. when mIdleSound2 reaches 90 percent played, trigger 
		idleLoop again to crossfade into a new instance of the sound. 
		this applies to all of the loop functions below. */
		private function idleLoop(e:Event = null):void{
			trace("idleLoop");
			if(loopIdleSound){
				mIdleSound2 = new AdvancedSound(new idleSoundMP3() as Sound); //making a new idle instance to fade to
				mIdleSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchIdleReferences); //when the second idle instance has reached full vol, switch references
				mIdleSound2.doOnPercentPlayed(.92, idleLoop); //when second instance of idle is 90% done, call this function again to loop
				mIdleSound.fadeOut(idleLoopFadeTime); //do the actual fade transition
				mIdleSound2.fadeIn(idleLoopFadeTime); 
			}else{
				return;
			}
		}
		
		private function runLoop(e:Event = null):void{
			trace("runLoop");
			if(loopRunSound){
				mRunSound2 = new AdvancedSound(new runSoundMP3() as Sound); //making a new Run instance to fade to
				mRunSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchRunReferences); //when the second Run instance has reached full vol, switch references
				mRunSound2.doOnPercentPlayed(.92, runLoop); //when second instance of Run is 99% done, call this function again to loop
				mRunSound.fadeOut(runLoopFadeTime); //do the actual fade transition
				mRunSound2.fadeIn(runLoopFadeTime); 
			}else{
				return;
			}
		}
		
		private function loadLoop(e:Event = null):void{
			trace("loadLoop");
			if(loopLoadSound){
				loopRunSound = false; 
				if(mRunSound && mRunSound.isPlaying()){
					mRunSound.fadeOut(loadLoopFadeTime);
				}else if(mRunSound2 && mRunSound2.isPlaying()){
					mRunSound2.fadeOut(loadLoopFadeTime);
				}
				mLoadSound2 = new AdvancedSound(new loadSoundMP3() as Sound); //making a new Load instance to fade to
				mLoadSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchLoadReferences); //when the second Load instance has reached full vol, switch references
				mLoadSound2.doOnPercentPlayed(.92, loadLoop); //when second instance of Load is 99% done, call this function again to loop
				mLoadSound.fadeOut(loadLoopFadeTime); //do the actual fade transition
				mLoadSound2.fadeIn(loadLoopFadeTime); 
			}else{
				return;
			}
		}
		
		/* deletes mIdleSound, and makes mIdleSound reference point to mIdleSound2 when
		mIdleSound2 has reached full volume.
		this applies to all switchReferences functions below. */ 
		private function switchIdleReferences(e:AdvancedSoundEvent):void{
			trace("switchIdleReferences");
			mIdleSound = mIdleSound2;
		}
		
		private function switchRunReferences(e:AdvancedSoundEvent):void{
			trace("switchRunReferences");
			mRunSound = mRunSound2;
		}
		
		private function switchLoadReferences(e:AdvancedSoundEvent):void{
			trace("switchLoadReferences");
			mLoadSound = mLoadSound2;
		}
		
		//rev handling
		private function mapPosition(MappedFromPosition:Number, MappedFromClipLength:Number,  MappedToClipLength:Number):Number{
			return MappedToClipLength - (MappedFromPosition/MappedFromClipLength) * MappedToClipLength;
		}
	}
}
