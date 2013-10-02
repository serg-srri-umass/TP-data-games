package odyssey
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.*;
	
	public class TopBarMVC extends topBar_mvc
	{
		private static const LOW:int = 0;
		private static const MEDIUM:int = 1;
		private static const HIGH:int = 2;
		
		private var _stage:Stage; // a reference to the application's stage, so its quality can be adjusted.
		
		private var _quality:int = HIGH; // the current quality.
		private var _muted:Boolean = false; // whether the game is muted.
		
		//private var _helpFunction:Function = function():void{};
		
		public function TopBarMVC():void{
			quality.addEventListener(MouseEvent.CLICK, toggleQuality);			
			soundIcon.addEventListener(MouseEvent.CLICK, toggleMuted);
			
			// establish the initial sound volume:
			var st:SoundTransform = SoundMixer.soundTransform;
			st.volume = 1;			
			SoundMixer.soundTransform = st;
			
			//helpBtn.addEventListener(MouseEvent.CLICK, doHelpFunction);
		}
		
		// set the title at the top of the screen
		public function setTitle(arg:String):void{
			title.text = arg;
		}
		public function setVersion(arg:String):void{
			version.text = arg;
		}
		
		// set a reference to the stage.
		public function setStage(arg:Stage):void{
			_stage = arg;
		}
		
		private function toggleQuality(e:MouseEvent = null):void{
			switch(_quality){
				case LOW:
					_quality = MEDIUM;
					_stage.quality = StageQuality.MEDIUM;
					break;
				case MEDIUM:
					_quality = HIGH;
					_stage.quality = StageQuality.HIGH;
					break;
				case HIGH:
					_quality = LOW;
					_stage.quality = StageQuality.LOW;
					break;
				default:
					break;
			}
		}
		
		private function toggleMuted(e:MouseEvent = null):void{
			_muted = !_muted;
			var st:SoundTransform = SoundMixer.soundTransform;
			if(_muted)
				st.volume = 0; // [0-1] (volume level)
			else
				st.volume = 1;			
			SoundMixer.soundTransform = st;
		}
		
		/*public function get helpFunction():Function{
			return _helpFunction;
		}
		
		public function set helpFunction(arg:Function):void{
			_helpFunction = arg;
		}
		
		private function doHelpFunction(e:Event):void{
			//_helpFunction();
		}
		
		
		public function disableHelpButton():void{
			//helpBtn.mouseEnabled = false;
			//helpBtn.alpha = 0.5;
		}
		
		public function enableHelpButton():void{
			//helpBtn.mouseEnabled = true;
			//helpBtn.alpha = 1;
		}*/
	}
}