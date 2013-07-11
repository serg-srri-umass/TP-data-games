package chainsaw{
	public class SoundHandler{
		
		import common.AdvancedSound;
		
		import flash.events.Event;
		import flash.media.*;
		
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
		
		//fade handling
		private function startToIdle(e:Event):void{
			trace("startToIdle");
			mIdleSound.fadeIn(300, int.MAX_VALUE);
			mStartUpSound.fadeOut(300);
		}
		
		private function idleToRun():void{
			trace("idleToRun");
			mRevDownSound.stop();
			mRevUpSound.doOnPercentPlayed(.9, revToRunTrans);
			mRevUpSound.fadeIn(300);
			mIdleSound.fadeOut(300);
		}
		
		private function runToIdle():void{
			trace("runToIdle");
			mRevUpSound.stop();
			mRevDownSound.doOnPercentPlayed(.9, runToRevTrans);
			mRevDownSound.fadeIn(300);
			mRunSound.fadeOut(300);
		}
		
		//transition handling
		private function revToRunTrans(e:Event = null):void{
			trace("revToRunTrans");
			mIdleSound.stop();
			mRevUpSound.fadeOut(300);
			mRunSound.fadeIn(300, int.MAX_VALUE);
		}
		
		private function runToRevTrans(e:Event = null):void{
			trace("runToRevTrans");
			mRunSound.stop();
			mIdleSound.fadeIn(300, int.MAX_VALUE);
		}
	}
}