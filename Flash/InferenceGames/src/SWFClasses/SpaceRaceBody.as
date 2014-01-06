package {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.utils.Timer;
	import fl.transitions.Tween;
	import fl.transitions.easing.Elastic;
	import embedded_asset_classes.InferenceEvent;

	import common.ParkMiller;
	
	public class SpaceRaceBody extends MovieClip{
		
		//
		// The SpaceRaceBody is all the parts of SpaceRace that aren't the top bar.
		// It contains a singular instance of SpaceRaceControls.
		//
		
		public static var INSTANCE:SpaceRaceBody;
		
		private const IQR_HELP:String = "The bigger the IQR, the more spread out your data will be.";
		private const INTERVAL_HELP:String = "The Interval is the size of your guessing range.";
		
		private var main:*; // the parent of SpaceRaceBody.
		public var myStage:Stage;
		
		// movie clip variables:
		public var numberlineY:Number;			// the Y position of the number line
		public var numberlineLength:Number;		// the length of the number line in px
		public var startPoint:Number;			// the X position of 0 on the number line
		public var endPoint:Number;				// the X pos of 100 on the number line
		public var distributionScaleY:Number;	// the scaleY of the distribution
		
		// datapoint variables:
		public var dataPopSpeed:Number = 3;	// determines how much time occurs between the arrival of data pops.
		public var ticker:int = 0;				// used to handle the animation of data pops 
		private var pm:ParkMiller = new ParkMiller();	// park miller generates a random normal.
		private var dataBladder:Vector.<Number> = new Vector.<Number>(); // holds data points that havent been drawn to screen yet.
		
		//timers
		private var reactivateTimer:Timer = new Timer(900, 1); // half second delay between when the data finishes streaming and the buttons turn back on
		
		
		// ---------- CONSTRUCTOR ---------------
		public function SpaceRaceBody(){
			INSTANCE = this;
			
			// establish the position of the 0 and 100 on the numberline.
			numberlineY = start.y;
			startPoint = start.x;
			endPoint = end.x;
			numberlineLength = endPoint - startPoint;
			distributionScaleY = distributionMVC.scaleY;
			
			// add listeners:
			reactivateTimer.addEventListener(TimerEvent.TIMER, startTurnRed);	// when data finishes sampling, the next turn is red.
			distributionMVC.addEventListener("animate", revealAnswer);	// when the distribution finishes "wiping" onscreen, it reveals the answer.;
			
			controlsMVC.establish(); // Establish the SpaceRaceControls.
		}
		
		// the SpaceRaceBody needs a reference to the MXML stage to work.
		// this should be called by the parent.
		public function setStage( arg:Stage):void{
			myStage = arg;
		}
		
		// this method takes in the parent.
		public function setSpaceRace( arg:*):void{
			main = arg;
		}
		
		
		// ---------- MOVIE CLIP MATH ---------------

		// give this method a position on the numberline, and it will return a stage coordinate.
		public function numlineToStage( arg:Number):Number
		{
			var percentageGain:Number = (arg / 100) * numberlineLength;
			return startPoint + percentageGain;
		}

		// give this method a stage coordinate (X) and it will return a position on the numberline.
		public function stageToNumline( arg:Number):Number
		{
			return (arg - startPoint) / numberlineLength * 100;
		}		
		
		// give this method a length, and it will return how many px it is long on the numberline
		private function widthOfNumber( arg:Number):Number
		{
			return numlineToStage( arg) - startPoint;
		}
		
		
		// ---------- TURN FUNCTIONS -----------------
		public function startTurnGreen( triggerEvent:Event = null):void{
			controlsMVC.activePlayerIsRed = false;
			controlsMVC.showGreen();
			controlsMVC.hideRed();
			SpaceRaceTopBar.INSTANCE.setTrim("green");
			controlsMVC.openGuessPassGreen();
			promptTxt.text = "It's " + main.playerNameGreen + "'s turn.";
			controlsMVC.dispatchEvent( new InferenceEvent( InferenceEvent.EXPERT_START_TURN));
		}
		
		public function startTurnRed( triggerEvent:Event = null):void{
			controlsMVC.activePlayerIsRed = true;
			controlsMVC.showRed();
			controlsMVC.hideGreen();
			SpaceRaceTopBar.INSTANCE.setTrim("red");
			controlsMVC.openGuessPassRed();
			promptTxt.text = "It's " + main.playerNameRed + "'s turn.";
		}
		
		// this mode gets entered when more data has to be sampled
		public function startDataSampling( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_SAMPLE, true));
			// this event will tell InferenceGames to start generating data.
			
			if(controlsMVC.activePlayerIsRed){
				controlsMVC.controlsRedMVC.stop();
				controlsMVC.hideGreen();
			} else {
				controlsMVC.controlsGreenMVC.stop();
				controlsMVC.hideRed();
			}			
			promptTxt.text = "Sampling data...";
		}
		
		// ------------ SAMPLING FUNCTIONS ------------------
		
		public function moveDistributionTo( arg:Number):void{
			distributionMVC.x = numlineToStage( main.median);
		}
		
		// sets the text that says how much sampling is going on
		public function setSampleSizeText( arg:int):void{
			sampleTxt.text = "Sampling " + arg + " at a time.";
		}
				
		// This method performs the actual sampling.
		// both adding it visually to the screen, and returning all the values.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			var outputVector:Vector.<Number> = new Vector.<Number>();
			for( var i:int = 0; i < main.sampleSize; i++){
				var numToPush:Number =  pm.normalWithMeanIQR( main.median, main.iqr);
				dataBladder.push( numToPush);
				outputVector.push( numToPush);
			}
			return outputVector;
		}
		
		// Checks if any data pops need to be added to the screen. 
		public function handleEnterFrame( triggerEvent:Event):void{
			if (dataBladder.length) // do any pops need to be added?
			{
				if ( ticker % dataPopSpeed == 0)
				{
					var d:DataPop = new DataPop();
					addChild(d);
					d.x = numlineToStage( dataBladder.pop());
					d.y = numberlineY;
					if ( dataBladder.length == 0)
					{
						reactivateTimer.reset();
						reactivateTimer.start();
					}
				}
				ticker++;
			}
		}
		
		// ----------- IQR / INTERVAL SECTION ------------
		public function setPossibleIQRs( iqr1:int, iqr2:int = 0, iqr3:int = 0, iqr4:int = 0):void{
			setBarLengthIQR( iqrMVC.barMVC1, iqr1);
			setBarLengthIQR( iqrMVC.barMVC2, iqr2);
			setBarLengthIQR( iqrMVC.barMVC3, iqr3);
			setBarLengthIQR( iqrMVC.barMVC4, iqr4);
			setActiveIQR(iqr1);
		}
		
		// set what possible intervals are allowed this game.
		public function setPossibleIntervals( interval1:int, interval2:int = 0, interval3:int = 0, interval4:int = 0):void{
			setBarLengthInterval( intervalMVC.barMVC1, interval1);
			setBarLengthInterval( intervalMVC.barMVC2, interval2);
			setBarLengthInterval( intervalMVC.barMVC3, interval3);
			setBarLengthInterval( intervalMVC.barMVC4, interval4);
			setActiveInterval(interval1);
		}
		
		// of the predefined possible IQRs, selects the one who matches the given value
		public function setActiveIQR( value:Number):Boolean{
			distributionMVC.width = (numlineToStage(value) - startPoint) * 3.472;  // the distribution is 3.472 times widers than its IQR
			return setActiveBar( iqrMVC, value);
		}
		
		// of the possible predefined intervals, selects the one with the given value
		public function setActiveInterval( value:Number):Boolean{
			controlsMVC.barMVC.width = ( widthOfNumber( value * 2));	// the width is 2x the interval.
			return setActiveBar( intervalMVC, value);
		}		
		
		// sets the length of a bar mvc (either interval or IQR) to the given length. If length = 0, hide the bar.
		private function setBarLengthIQR( bar:MovieClip, length:Number):void{
			bar.lengthVar = length; // this lets the bar remember its length.
			if( length <= 0){
				bar.visible = false;
			} else {
				bar.visible = true;
				bar.barMVC.width = widthOfNumber( length);
				bar.numberTxt.x = bar.barMVC.width + 10;
				bar.numberTxt.text = String(length);
			}
		}
		
		// sets the length of a bar mvc (interval) to the given length. If length = 0, hide the bar.
		private function setBarLengthInterval( bar:MovieClip, length:Number):void{
			bar.lengthVar = length; // this lets the bar remember its length.
			if( length <= 0){
				bar.visible = false;
			} else {
				bar.visible = true;
				bar.barMVC.width = widthOfNumber( length * 2);
				bar.numberTxt.x = bar.barMVC.width + 35;
				bar.numberTxt.text = "±" + String(length);
			}
		}
		
		// highlights the correct bar, and deselects the rest
		// container is the movieclip that contaisn the bars.
		// 'value' is the bar that will be selected. Note: if 2 bars are the same length, they will both select. If no bar matches the value, non will select.
		private function setActiveBar( container:MovieClip, value:Number):Boolean{
			var success:Boolean = false; // whether or not the value exists. 
			for( var i:int = 1; i <= 4; i++){
				if( container["barMVC" + i].lengthVar == value){
					container["barMVC" + i].barMVC.gotoAndStop("on");
					container["barMVC" + i].numberTxt.alpha = 1;
					success = true;
				} else {
					container["barMVC" + i].barMVC.gotoAndStop("off");
					container["barMVC" + i].numberTxt.alpha = 0.2;
				}
			}
			return success;
		}
		
		
		// ---------- GUESSING FUNCTIONS --------------
		public function set guess( arg:Number):void{
			main.guess = arg;
		}
		
		// places a guess based on the set guess value. The distribution "wipes" on screen, then shows if it was correct or not.
		public function makeGuess( triggerEvent:Event = null):void
		{			
			distributionMVC.alpha = 1;
			distributionMVC.gotoAndStop("neutral");
			distributionMVC.curveMVC.gotoAndPlay("enterLeft");

			//distributionMVC.curveMVC.gotoAndStop("on");
			//var bounceTween:Tween = new Tween( distributionMVC, "scaleY", Elastic.easeOut, 0, distributionScaleY, 20);
			//revealAnswer();
		}

		// turns the distribution yellow (win) or white (lose), based on the guess.
		private function revealAnswer( triggerEvent:Event = null):void
		{
			if ( Math.abs( main.guess - main.median) <= main.interval){
				distributionMVC.gotoAndPlay("win");
			} else {
				distributionMVC.gotoAndPlay("lose");
			}
		}
		
		// this method is a pass-thru. It takes the feedback info, and passes it to the controls where its displayed.
		public function showFeedback( header:String, buttonText:String, body:String = ""):void{
			controlsMVC.showFeedback( header,  buttonText, body);
		}
	}
}