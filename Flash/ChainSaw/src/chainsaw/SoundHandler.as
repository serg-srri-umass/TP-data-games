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
		
		//[Embed("../src/embedded_assets/shutDownSound.mp3")]
		//private var shutDownSoundMP3:Class;
		//private var mShutDownSound:AdvancedSound = new AdvancedSound(new shutDownSoundMP3() as Sound);
		
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
		private var isRevvingUp:Boolean = false; 
		private var isRevvingDown:Boolean = false; 
		
		private var loopIdleSound:Boolean = false;
		private var loopRunSound:Boolean = false;

		//event handling; public functions
		public function onStart():void{
			mStartUpSound.doOnPercentPlayed(0.9, startToIdle);
			mStartUpSound.play();
		}
		
		public function onMouseDown(e:Event):void{
			if(mRevDownSound.isPlaying() && !mRevUpSound.isPlaying()){
				revDownToRevUpTrans();
			}else{
				idleToRun();
			}
		}
		
		public function onMouseUp(e:Event):void{
			if(mRevUpSound.isPlaying() && !mRevDownSound.isPlaying()){
				revUpToRevDownTrans();
			}
			else{
				runToIdle();
			}
		}
		
		//initialization 
		private function initSounds():void{
			mIdleSound.doOnPercentPlayed(.92, idleLoop);
			mRevUpSound.doOnPercentPlayed(.92, revToRunTrans);
			mRevDownSound.doOnPercentPlayed(.92, revToIdleTrans);
			mRunSound.doOnPercentPlayed(.92, runLoop);			
		}
		
		//fade handling
		private function startToIdle(e:Event):void{
			trace("startToIdle");
			mStartUpSound.fadeOut(100);
			mIdleSound.fadeIn(100);
			loopIdleSound = true;
		}
		
		private function idleToRun():void{
			trace("idleToRun");
			loopIdleSound = false; 
			mIdleSound.fadeOut(100);
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(100);
			}
			mRevUpSound.fadeIn(100);
		}
			
		private function runToIdle():void{
			trace("runToIdle");
			//mRevUpSound.stop();
			loopRunSound = false; 
			mRunSound.fadeOut(100);
			if( mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(100);
			}
			mRevDownSound.fadeIn(100);
		}
		
		//transition clip handling
		private function revToRunTrans(e:Event = null):void{
			trace("revToRunTrans");
			//mIdleSound.stop();
			mRevUpSound.fadeOut(100);
			mRunSound.fadeIn(100);
			loopRunSound = true;
		}
		
		private function revToIdleTrans(e:Event = null):void{
			trace("revToIdleTrans");
			mRevDownSound.fadeOut(100);
			mIdleSound.fadeIn(100);
			loopIdleSound = true;
		}
		
		private function revUpToRevDownTrans():void{
			trace("revUpToRevDownTrans");
			loopRunSound = false; 
			mRunSound.fadeOut(100);
			mIdleSound.fadeOut(100);
			
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(100);
			}
			
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(100);
			}
			
			mRevUpSound.fadeOut(100);
			//mRevDownSound.doOnPercentPlayed(.95, revToIdleTrans);
			mRevDownSound.setStartPosition(mapPosition(mRevUpSound.getChannel().position, mRevUpSound.getLength(), mRevDownSound.getLength()));
			mRevDownSound.doOnPercentPlayed(.92, revToIdleTrans);
			mRevDownSound.fadeIn(100, 0, mRevDownSound.getStartPosition());
		}
		
		private function revDownToRevUpTrans():void{
			trace("revDownToRevUpTrans");
			loopRunSound = false; 
			mRunSound.fadeOut(100);
			mIdleSound.fadeOut(100);
			
			if(mRunSound2 && mRunSound2.isPlaying()){
				mRunSound2.fadeOut(100);
			}
			
			if(mIdleSound2 && mIdleSound2.isPlaying()){
				mIdleSound2.fadeOut(100);
			}
	
			mRevDownSound.fadeOut(100);
			mRevUpSound.setStartPosition(mapPosition(mRevDownSound.getChannel().position, mRevDownSound.getLength(), mRevUpSound.getLength()));
			mRevUpSound.doOnPercentPlayed(.92, revToRunTrans);
			mRevUpSound.fadeIn(100, 0, mRevUpSound.getStartPosition());
		}
		
		//loop handling
		/* makes new instance of idle sound in mIdleSound2. when mIdleSound2 reaches full vol, 
		trigger switchIdleReferences. when mIdleSound2 reaches 90 percent played, trigger 
		idleLoop again to crossfade into a new instance of the sound. */
		private function idleLoop(e:Event = null):void{
			trace("idleLoop");
			if(loopIdleSound){
				mIdleSound2 = new AdvancedSound(new idleSoundMP3() as Sound); //making a new idle instance to fade to
				mIdleSound2.addEventListener(AdvancedSoundEvent.FULL_VOL, switchIdleReferences); //when the second idle instance has reached full vol, switch references
				mIdleSound2.doOnPercentPlayed(.92, idleLoop); //when second instance of idle is 90% done, call this function again to loop
				mIdleSound.fadeOut(100); //do the actual fade transition
				mIdleSound2.fadeIn(100); 
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
				mRunSound.fadeOut(100); //do the actual fade transition
				mRunSound2.fadeIn(100); 
			}else{
				return;
			}
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
		
		//rev handling
		private function mapPosition(MappedFromPosition:Number, MappedFromClipLength:Number,  MappedToClipLength:Number):Number{
			return MappedToClipLength - (MappedFromPosition/MappedFromClipLength) * MappedToClipLength;
		}
	}
}