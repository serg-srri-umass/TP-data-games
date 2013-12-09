package odyssey
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.*;
	import flash.text.TextFormat;
	
	public class TopBarMVC extends topBar_mvc
	{
		public static const DEFAULT_TITLE:String = "Choose a Mission";
		
		private static const LOW:int = 0;
		private static const MEDIUM:int = 1;
		private static const HIGH:int = 2;
		
		private static var yellowText:TextFormat = new TextFormat(); // the title color on mouse over.
		private static var blackText:TextFormat = new TextFormat(); // the default title color
		
		private var _stage:Stage; // a reference to the application's stage, so its quality can be adjusted.
		
		private var _videoFunc:Function, _descriptionFunc:Function, _aboutFunc:Function; 
		
		private var _quality:int = HIGH; // the current quality.
		private var _muted:Boolean = false; // whether the game is muted.		
		private var bouncingPrompt:Boolean = true; // whether or not the first bouncing prompt is still visible.
		
		public function TopBarMVC( videoFunction:Function, descriptionFunction:Function, aboutFunction:Function):void{
			yellowText.color = 0xFFFF00;
			blackText.color = 0xE5D8D0;
			
			qualityBtn.addEventListener(MouseEvent.CLICK, toggleQuality);			
			soundBtn.addEventListener(MouseEvent.CLICK, toggleMuted);
			videoBtn.addEventListener(MouseEvent.CLICK, toggleVideo);
			aboutBtn.addEventListener(MouseEvent.CLICK, toggleAbout);
			
			videoBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			videoBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			qualityBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			qualityBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			soundBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			soundBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			titleHit.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			titleHit.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			aboutBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			aboutBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			
			// establish the initial sound volume:
			var st:SoundTransform = SoundMixer.soundTransform;
			st.volume = 1;			
			SoundMixer.soundTransform = st;
						
			_videoFunc = videoFunction;
			_descriptionFunc = descriptionFunction;
			_aboutFunc = aboutFunction;
			
			mouseOverHelp.inner.gotoAndPlay("bob"); // make the intro movie button bob up and down.
			
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
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, closeBouncer); // the first mouse click will close the video prompt.
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
			showHidePrompt(e);
		}
		
		private function toggleMuted(e:MouseEvent = null):void{
			_muted = !_muted;
			var st:SoundTransform = SoundMixer.soundTransform;
			if(_muted)
				st.volume = 0; // [0-1] (volume level)
			else
				st.volume = 1;			
			SoundMixer.soundTransform = st;
			showHidePrompt(e);
		}
		
		private function toggleAbout(e:MouseEvent = null):void{
			_aboutFunc();
			mouseOverHelp.visible = false;
		}
		
		private function toggleVideo(e:MouseEvent = null):void{
			mouseOverHelp.gotoAndStop(1);
			mouseOverHelp.inner.gotoAndPlay("close");
			_videoFunc();
		}
		
		private function showHidePrompt(e:MouseEvent = null):void{
			if(e.type == MouseEvent.MOUSE_OUT){
				title.setTextFormat(blackText);
				if(bouncingPrompt){
					bouncingPrompt = false;
				}
				mouseOverHelp.visible = false;
				if(e.target == videoBtn){
					mouseOverHelp.gotoAndStop(1);
					mouseOverHelp.inner.gotoAndStop("still");
				}
			} else {
				mouseOverHelp.visible = true;
				
				if(e.target == videoBtn){
					mouseOverHelp.gotoAndStop(1);
				}else if(e.target == qualityBtn){
					mouseOverHelp.gotoAndStop(2);
					if(_quality == LOW){
						mouseOverHelp.promptTxt.text = "Quality: Low";
					} else if(_quality == MEDIUM){
						mouseOverHelp.promptTxt.text = "Quality: Med";
					} else if(_quality == HIGH){
						mouseOverHelp.promptTxt.text = "Quality: High";
					}
				}else if(e.target == soundBtn){
					mouseOverHelp.gotoAndStop(3);
					mouseOverHelp.promptTxt.text = ( !_muted ? "Volume: On" : "Volume: Off");
				} else if(e.target == titleHit){
					title.setTextFormat( yellowText);
					if(title.text != DEFAULT_TITLE){
						mouseOverHelp.gotoAndStop(4);
						mouseOverHelp.promptTxt.text = _descriptionFunc();
					} else {
						mouseOverHelp.gotoAndStop(5);
						mouseOverHelp.promptTxt.text = "Ahoy Matey! Choose a mission, then hit play to get started.";
					}
				} else if(e.target == aboutBtn){
					mouseOverHelp.gotoAndStop("about");
					mouseOverHelp.promptTxt.text = "About";
				}
			}
		}
		
		public function closeBouncer( e:Event = null, instant:Boolean = false):void{
			if(bouncingPrompt){
				mouseOverHelp.gotoAndStop(1);
				mouseOverHelp.inner.gotoAndPlay("close");
				bouncingPrompt = false;
			}
			_stage.removeEventListener( MouseEvent.MOUSE_DOWN, closeBouncer);
			if(instant){
				mouseOverHelp.visible = false;
			}
		}
	}
}