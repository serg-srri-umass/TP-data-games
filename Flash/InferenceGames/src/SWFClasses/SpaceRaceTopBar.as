package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	
	// NOTE: The SPEAKER Mute button was NOT removed. It was pushed offstage.
	// To bring it back, open up the .fla file, and pull it back onstage.
	//
	public class SpaceRaceTopBar extends MovieClip {
		
		public static var INSTANCE:SpaceRaceTopBar;
		
		private const WINNING_SCORE:int = 6;
		
		private var humanScore:int = 1; 
		private var expertScore:int = 1;
		
		private var _stage:Stage; // a reference to the MXML's stage
		private var _muted:Boolean = false;
		private var bouncingPrompt:Boolean = true; // whether or not the first bouncing prompt is still visible.
		
		private var _aboutFunc:Function = new Function();
		private var _videoFunc:Function = new Function();
		private var _backFunc:Function = new Function();

		
		public function SpaceRaceTopBar() {
			INSTANCE = this;
			
			scoreMVC.humanScoreMVC.bulbMVC1.gotoAndPlay("turnOn");
			scoreMVC.expertScoreMVC.bulbMVC1.gotoAndPlay("turnOn");			
			
			soundBtn.setClickFunctions( mute, unmute);
			
			
			// establish the initial sound volume:
			var st:SoundTransform = SoundMixer.soundTransform;
			st.volume = 1;			
			SoundMixer.soundTransform = st;
			
			mouseOverHelp.inner.gotoAndPlay("bob"); // make the intro movie button bob up and down.
			videoBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			videoBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			soundBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			soundBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			aboutBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			aboutBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			//backBtn.addEventListener(MouseEvent.MOUSE_OVER, showHidePrompt);
			//backBtn.addEventListener(MouseEvent.MOUSE_OUT, showHidePrompt);
			
			videoBtn.addEventListener(MouseEvent.CLICK, toggleVideo);
			aboutBtn.addEventListener(MouseEvent.CLICK, toggleAbout);
			//backBtn.addEventListener(MouseEvent.CLICK, clickBack);
			
			bulbTimer.addEventListener( TimerEvent.TIMER, animateBulbs);
		}
		
		// set a reference to the stage.
		public function setStage(arg:Stage):void{
			_stage = arg;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, closeBouncer); // the first mouse click will close the video prompt.
		}
		
		
		// earns a point. If humanPlayer is true, p1 earns the point. Otherwise, p2 ear
		public function earnPoint( humanPlayer:Boolean = true):void{
			if( humanPlayer)
				earnHumanPoint();
			else
				earnExpertPoint();
		}
		
		public function resetScore( triggerEvent:Event = null):void{
			for( var i:int = 1; i <= WINNING_SCORE; i++){
				if( humanScore >= i)
					scoreMVC.humanScoreMVC["bulbMVC" + i].gotoAndPlay("turnOff"); // turn off the active bulbs
				if ( expertScore >= i)
					scoreMVC.expertScoreMVC["bulbMVC" + i].gotoAndPlay("turnOff"); // turn off the active bulbs
			}
			
			// reset the starting positions
			expertScore = humanScore = 1;
			stopAnimatingBulbs();
			scoreMVC.humanScoreMVC.bulbMVC1.gotoAndPlay("turnOn");
			scoreMVC.expertScoreMVC.bulbMVC1.gotoAndPlay("turnOn");
			
			// make the bulb white and fade it out
			scoreMVC.centerBulbMVC.gotoAndStop("white");
			scoreMVC.centerBulbMVC.bulbMVC.gotoAndPlay("turnOff");	// turn off centre bulb
		}
		
		public function setTitleMessage( arg:String):void{
			levelTxt.text = arg;
		}
		
		// this method sets the color of the trim. 
		public function setTrim( arg:String):void{
			if( arg != "white" && arg != "red" && arg != "green")
				throw new Error("invalid string. Valid strings are 'white', 'red' and 'green'");
				
			var Mc:MovieClip = trimMVC["trimMVC" + arg];	// the trim that's going to go on top
			if(trimMVC.getChildIndex(Mc) < Mc.parent.numChildren-1){ // check if that trim isn't already on top
				trimMVC.setChildIndex(Mc, Mc.parent.numChildren-1);
				Mc.gotoAndPlay("off");	// if it wasn't on top, animate it on.
			}
		}
		
		// closes the bouncing prompt
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
		
		public function set videoFunction( arg:Function):void{
			_videoFunc = arg;
		}
		
		public function set aboutFunction( arg:Function):void{
			_aboutFunc = arg;
		}
		
		/*public function set backFunction( arg:Function):void{
			_backFunc = arg;
		}*/
		
		
		// --------- PRIVATE METHODS ---------
		
		// animate the bulbs that show human and expert score (e.g. at end of game to show win)
		private var bulbTimer:Timer = new Timer( 1000, 0); // 1 second (1000ms) between toggle on/off, 0 means it repeats indefinitely
		private var bulbsForHuman:Boolean;
		private var bulbsAreLit:Boolean;
		
		private function delayedStartAnimatingBulbs( isHumanWin:Boolean ):void{
			bulbsForHuman = isHumanWin;
			
			var delayBulbStartTimer:Timer = new Timer( 700, 1); // delay time 0.7 seconds
			delayBulbStartTimer.addEventListener(TimerEvent.TIMER, startAnimatingBulbs);
			delayBulbStartTimer.start();
		}
		private function startAnimatingBulbs( triggerEvent:Event = null ):void{
			bulbsAreLit = true;
			bulbTimer.start();
		}
		private function stopAnimatingBulbs():void{
			bulbTimer.stop();
			bulbTimer.reset();
		}

		// change the bulb animation by one frame.  Triggered by startAnimatingBulbs()
		private function animateBulbs( triggerEvent:Event = null):void{
			var onOrOff:String = ( bulbsAreLit ? "turnOff" : "turnOn");
			var whichBulbs:String = ( bulbsForHuman ? "humanScoreMVC" : "expertScoreMVC" );
			
			scoreMVC[whichBulbs].bulbMVC1.gotoAndPlay(onOrOff);
			scoreMVC[whichBulbs].bulbMVC2.gotoAndPlay(onOrOff);
			scoreMVC[whichBulbs].bulbMVC3.gotoAndPlay(onOrOff);
			scoreMVC[whichBulbs].bulbMVC4.gotoAndPlay(onOrOff);
			scoreMVC[whichBulbs].bulbMVC5.gotoAndPlay(onOrOff);
			scoreMVC[whichBulbs].bulbMVC6.gotoAndPlay(onOrOff);
			scoreMVC.centerBulbMVC.bulbMVC.gotoAndPlay(onOrOff);
			bulbsAreLit = !bulbsAreLit;	
		}
		
		
		private function earnHumanPoint( triggerEvent:Event = null):void{
			if( humanScore == WINNING_SCORE){	// when the score equals the # of bulbs a player has
				scoreMVC.centerBulbMVC.gotoAndStop("green");
				scoreMVC.centerBulbMVC.bulbMVC.gotoAndPlay("turnOn");	// light up the center one
				setTrim("green"); 					// swipe from white to green to highlight human win
				delayedStartAnimatingBulbs( true );	// flash bulbs
			}else{
				humanScore++;
				scoreMVC.humanScoreMVC["bulbMVC" + humanScore].gotoAndPlay("turnOn"); // otherwise, turn on the next bulb in sequence
			}
		}
		
		private function earnExpertPoint( triggerEvent:Event = null):void{
			if( expertScore == WINNING_SCORE){	// when the score equals the # of bulbs a player has
				scoreMVC.centerBulbMVC.gotoAndStop("red");
				scoreMVC.centerBulbMVC.bulbMVC.gotoAndPlay("turnOn");	// light up the center one
				setTrim("red");  // swipe from white to red to highlight expert win
				delayedStartAnimatingBulbs( false );	// flash bulbs
			}else{
				expertScore++;
				scoreMVC.expertScoreMVC["bulbMVC" + expertScore].gotoAndPlay("turnOn"); // otherwise, turn on the next bulb in sequence
			}
		}
		
		
		private function toggleAbout(e:MouseEvent = null):void{
			mouseOverHelp.visible = false;
			_aboutFunc();
		}
		
		private function toggleVideo(e:MouseEvent = null):void{
			mouseOverHelp.visible = false;
			_videoFunc();
		}
		
		/*private function clickBack(e:MouseEvent = null):void{
			mouseOverHelp.visible = false;
			_backFunc();
		}*/
		
		// this method handles the pop-up help prompt. ("About", "Intro Video", etc)
		private function showHidePrompt(e:MouseEvent = null):void{
			if(e.type == MouseEvent.MOUSE_OUT){
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
				}else if(e.target == soundBtn){
					mouseOverHelp.gotoAndStop(3);
					mouseOverHelp.promptTxt.text = ( !_muted ? "Volume: On" : "Volume: Off");
				} else if(e.target == aboutBtn){
					mouseOverHelp.gotoAndStop("about");
					mouseOverHelp.promptTxt.text = "About";
				}/* else if(e.target == backBtn){
					mouseOverHelp.gotoAndStop("back");
					mouseOverHelp.promptTxt.text = "End Game";
				}*/
			}
		}
		
		
		private function mute( triggerEvent:MouseEvent):void{
			soundBtn.look = 1;
			_muted = true;
			var st:SoundTransform = SoundMixer.soundTransform;
			st.volume = 0; // [0-1] (volume level)	
			SoundMixer.soundTransform = st;
			mouseOverHelp.promptTxt.text = ( !_muted ? "Volume: On" : "Volume: Off");

		}
		
		private function unmute( triggerEvent:MouseEvent):void{
			soundBtn.look = 0;
			_muted = false;
			var st:SoundTransform = SoundMixer.soundTransform;
			st.volume = 1;			
			SoundMixer.soundTransform = st;
			mouseOverHelp.promptTxt.text = ( !_muted ? "Volume: On" : "Volume: Off");
		}
	}
}
