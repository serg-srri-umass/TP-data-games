package chainsaw{
	public class SoundHandler{
		
		import common.AdvancedSound;
		import flash.events.Event;
		import flash.media.*;
		
		//constructor
		public function SoundHandler(){
		}
		
		//sound embeds
		//looped sounds
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
		
		//looping vars
		private var mIdleSound2:AdvancedSound = new AdvancedSound(new idleSoundMP3() as Sound);
		private var mRunSound2:AdvancedSound;
		private var isIdling:Boolean = false;
		
		//event handling 
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
		
		public function fadeInAndLoopIdle(duration:Number = 1000):void{
			trace("fadeInAndLoopIdle");
			mIdleSound.doOnPercentPlayed(.9, idleSelfTransition);
			mIdleSound.fadeIn(100);
			//mIdleSound = mIdleSound2;
		}
		
		//fade handling
		private function startToIdle(e:Event):void{
			trace("startToIdle");
			//mIdleSound.fadeIn(100);
			fadeInAndLoopIdle(100);
			isIdling = true; 
			mStartUpSound.fadeOut(100);
		}
		
		private function idleToRun():void{
			trace("idleToRun");
			mRevDownSound.stop();
			mRevUpSound.doOnPercentPlayed(.9, revToRunTrans);
			mRevUpSound.fadeIn(100);
			mIdleSound.fadeOut(100);
			isIdling = false;
		}
		
		private function runToIdle():void{
			trace("runToIdle");
			mRevUpSound.stop();
			mRevDownSound.doOnPercentPlayed(.9, runToRevTrans);
			mRevDownSound.fadeIn(100);
			mRunSound.fadeOut(100);
			isIdling = true;
		}
		
		//transition handling
		private function revToRunTrans(e:Event = null):void{
			trace("revToRunTrans");
			mIdleSound.stop();
			mRevUpSound.fadeOut(100);
			mRunSound.fadeIn(100, int.MAX_VALUE);
		}
		
		private function runToRevTrans(e:Event = null):void{
			trace("runToRevTrans");
			mRunSound.stop();
			mIdleSound.fadeIn(100, int.MAX_VALUE);
		}
		
		//loop handling
		private function idleSelfTransition(e:Event):void{
			trace("idleSelfTransition");
			if(isIdling){
				mIdleSound = mIdleSound2;
				mIdleSound2 = new AdvancedSound(new idleSoundMP3() as Sound);
				mIdleSound2.doOnPercentPlayed(.9, idleSelfTransition);
				mIdleSound2.fadeIn(100);
				mIdleSound.fadeOut(100);
			}
			else{
				mIdleSound.fadeOut(100);
				mIdleSound2.fadeOut(100);
				return
			}
		}
	}
}