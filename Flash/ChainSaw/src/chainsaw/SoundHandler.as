package chainsaw{
	public class SoundHandler{
		
		//our imports
		import common.AdvancedSound;
		import common.AdvancedSoundEvent;
		
		import flash.events.Event;
		import flash.media.*;
		
		//constructor
		public function SoundHandler(){
		}
		
		//sound embeds
		[Embed("../src/embedded_assets/runSound.mp3")]
		private var runSoundMP3:Class;
		private var mRunSound:AdvancedSound = new AdvancedSound(new runSoundMP3() as Sound);
		
		[Embed("../src/embedded_assets/loadSound.mp3")]
		private var loadSoundMP3:Class;
		private var mLoadSound:AdvancedSound = new AdvancedSound(new loadSoundMP3() as Sound);

		[Embed("../src/embedded_assets/idleSound.mp3")]
		private var idleSoundMP3:Class;
		private var mIdleSound:AdvancedSound = new AdvancedSound(new idleSoundMP3() as Sound);
		
		//transition sounds
		[Embed("../src/embedded_assets/startUpSound.mp3")]
		private var StartUpSoundMP3:Class;
		private var mStartUpSound:AdvancedSound = new AdvancedSound(new StartUpSoundMP3() as Sound);
		
		[Embed("../src/embedded_assets/shutDownSound.mp3")]
		private var shutDownSoundMP3:Class;
		private var mShutDownSound:AdvancedSound = new AdvancedSound(new shutDownSoundMP3() as Sound);
		
		[Embed("../src/embedded_assets/revUpSound.mp3")]
		private var revUpSoundMP3:Class;
		private var mRevUpSound:AdvancedSound = new AdvancedSound(new revUpSoundMP3() as Sound);
		
		[Embed("../src/embedded_assets/revDownSound.mp3")]
		private var revDownSoundMP3:Class;
		private var mRevDownSound:AdvancedSound = new AdvancedSound(new revDownSoundMP3() as Sound);
		
		private var mIdleSound2:AdvancedSound; //references the new instance of idle sound that we fade into when looping idle sound
		private var mRunSound2:AdvancedSound;
		private var isIdling:Boolean = false; //used to break out of idleLoop when we no longer need to idle. 
		private var isRunning:Boolean = false;
		
		//event handling; public functions
		public function onStart():void{
			mStartUpSound.doOnPercentPlayed(0.9, startToIdle);
			mStartUpSound.play();
		}
		
		public function onMouseDown(e:Event):void{
			idleToRun();
		}
		
		public function onMouseUp(e:Event):void{
			runToIdle();
		}
		
		//fade handling
		private function startToIdle(e:Event):void{
			trace("startToIdle");
			mStartUpSound.fadeOut(300);
			mIdleSound.doOnPercentPlayed(.9, idleLoop);
			mIdleSound.fadeIn(300);
		}
		
		private function idleToRun():void{
			trace("idleToRun");
			mRevDownSound.stop();
			mRevUpSound.doOnPercentPlayed(.9, revToRunTrans);
			mIdleSound.fadeOut(300);
			mRevUpSound.fadeIn(300);
		}
			
		private function runToIdle():void{
			trace("runToIdle");
			//mRevUpSound.stop();
			mRevDownSound.doOnPercentPlayed(.9, runToRevTrans);
			mRunSound.fadeOut(300);
			mRevDownSound.fadeIn(300);
		}
		
		//transition clip handling
		private function revToRunTrans(e:Event = null):void{
			trace("revToRunTrans");
			//mIdleSound.stop();
			mRevUpSound.fadeOut(300);
			mRunSound.doOnPercentPlayed(.9, runLoop);
			mRunSound.fadeIn(300);
		}
		
		private function runToRevTrans(e:Event = null):void{
			trace("runToRevTrans");
			mRunSound.stop();
			mIdleSound.doOnPercentPlayed(.9, idleLoop);
			mRevDownSound.fadeOut(300);
			mIdleSound.fadeIn(300);
		}
		
		//loop handling
		/* makes new instance of idle sound in mIdleSound2. when mIdleSound2 reaches full vol, 
		trigger switchIdleReferences. when mIdleSound2 reaches 90 percent played, trigger 
		idleLoop again to crossfade into a new instance of the sound. */
		private function idleLoop(e:Event = null):void{
			trace("idleLoop");
				mIdleSound2 = new AdvancedSound(new idleSoundMP3() as Sound); //making a new idle instance to fade to
				mIdleSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchIdleReferences); //when the second idle instance has reached full vol, switch references
				mIdleSound2.doOnPercentPlayed(.9, idleLoop); //when second instance of idle is 90% done, call this function again to loop
				mIdleSound.fadeOut(300); //do the actual fade transition
				mIdleSound2.fadeIn(300); 
		}
		
		private function runLoop(e:Event = null):void{
			trace("runLoop");
				mRunSound2 = new AdvancedSound(new runSoundMP3() as Sound); //making a new Run instance to fade to
				mRunSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchRunReferences); //when the second Run instance has reached full vol, switch references
				mRunSound2.doOnPercentPlayed(.9, runLoop); //when second instance of Run is 90% done, call this function again to loop
				mRunSound.fadeOut(300); //do the actual fade transition
				mRunSound2.fadeIn(300); 
		}
		
		/* deletes mIdleSound, and makes mIdleSound reference point to mIdleSound2 when
		mIdleSound2 has reached full volume.*/ 
		private function switchIdleReferences(e:AdvancedSoundEvent):void{
			trace("switchIdleReferences");
			mIdleSound = mIdleSound2;
		}
		
		private function switchRunReferences(e:AdvancedSoundEvent):void{
			trace("switchRunReferences");
			mRunSound = mRunSound2;
		}
		
	}
}