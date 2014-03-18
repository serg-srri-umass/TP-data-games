/* STRUCTURE:
- this
	|- instructionsTxt
	|- inputTxt
	|- errorTxt
*/

package embedded_asset_classes
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class DebugConsoleSWC extends debugConsoleSWC
	{
		
		// ----------------
		// --- COMMANDS ---
		// ----------------
		
		internal var c1:Command  = new Command( "U", "Unlock all levels", false, unlockAllLevels);
		internal var c2:Command = new Command( "P", "Show Population Mean", false, showPopMedian);
		internal var c3:Command = new Command("1", "Earn Point (User)", false, earnPointPlayer);
		internal var c4:Command = new Command("2", "Earn Point (Bot)", false, earnPointBot);
		internal var c5:Command = new Command("A", "Reveal guess accuracy", false, revealGuessAccuracy);
		internal var c6:Command = new Command("S", "Soviet Science Mode", true, enterRussianMode); 
		internal var c7:Command = new Command("C", "Sample Size=100", false, updateSampleSize100); 
		internal var c8:Command = new Command("M", "Sample Size=1000", false, updateSampleSize1000); 
		
		internal var LAST_COMMAND:Command  = new Command("Q", "Quit Console", false, hide);
		
		// -------------------------
		// --- COMMAND FUNCTIONS ---
		// -------------------------
		
		private function earnPointPlayer():void{
			InferenceGames.instance.sSpaceRace.earnPointHuman();
		}
		
		private function earnPointBot():void{
			InferenceGames.instance.sSpaceRace.earnPointExpert();
		}
		
		private function revealGuessAccuracy():void{
			if(Round.currentRound)
				println("LAST GUESS ACCURACY: "+ Round.currentRound.accuracy);
			else
				println("MUST BE IN ROUND.");
		}
		
		private function unlockAllLevels():void{
			InferenceGames.instance.unlockedLevels = 6; // all levels are now unlocked.	
			InferenceGames.instance.sSpaceRace.showMainMenu( 6, 0 );
			println("All levels unlocked.");
		}
		
		private function showPopMedian():void{
			println("Population Mean: " + Round.currentRound.populationMean);
		}
		
		private function enterRussianMode( on:Boolean):void{
			SpaceRaceControls.INSTANCE.controlsExpertMVC.checkov.visible = on;
			SpaceRaceControls.INSTANCE.controlsExpertMVC.checkov2.visible = on;
		}
		
		private function updateSampleSize100():void{
			// NOTE: Round.currentRound.sampleSize is not changed, does not seem to be used anywhere except to set sSpaceRace.sampleSize
			InferenceGames.instance.sSpaceRace.sampleSize = 100;
			println("Sample size is now 100 for round.");
		}
		
		private function updateSampleSize1000():void{
			// NOTE: Round.currentRound.sampleSize is not changed, does not seem to be used anywhere except to set sSpaceRace.sampleSize
			InferenceGames.instance.sSpaceRace.sampleSize = 1000;
			println("Sample size is now 1000 for round.");
		}
		
		
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static var SINGLETON_DEBUG:DebugConsoleSWC;
		
		public static function get instance():DebugConsoleSWC{
			return SINGLETON_DEBUG;
		}
		
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public function DebugConsoleSWC()
		{
			super();
			if(!SINGLETON_DEBUG)
				SINGLETON_DEBUG = this;
			else
				throw new Error("DebugConsole has already been created.");
			
			InferenceGames.stage.addEventListener(KeyboardEvent.KEY_UP, listenForDebugKeystroke);
			visible = false;
		}
		
		public function show( triggerEvent:* = null):void{
			visible = true;
			writeDebugCommands();
			
			// asssign focus to the prompt area. Taken from http://reality-sucks.blogspot.com/2007/11/actionscript-3-adventures-setting-focus.html
			InferenceGames.stage.focus = inputTxt; 
			inputTxt.text=" "; 
			inputTxt.setSelection( inputTxt.length, inputTxt.length);
			inputTxt.text = "";
			inputTxt.addEventListener(KeyboardEvent.KEY_UP, evaluateEnter);
			
			println(""); // put a new line in the output window.
		}
		
		public function hide( triggerEvent:* = null):void{
			inputTxt.removeEventListener(KeyboardEvent.KEY_DOWN, evaluateEnter);
			visible = false;
		}
		
		public function get isShowing():Boolean{
			return visible;
		}
		
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
				
		private const TRIGGER_CHAR_ARRAY:Array = [68, 69, 66, 85, 71]; // type debug to enter debug commands.
		private var currentChar:int = 0;
		
		// when the console is closed, typing 'debug' will open it.
		private function listenForDebugKeystroke( triggerEvent:KeyboardEvent):void{
			if( triggerEvent.keyCode == TRIGGER_CHAR_ARRAY[currentChar] ){
				currentChar++;
				if(currentChar == TRIGGER_CHAR_ARRAY.length)
					show();
			} else if( currentChar > 0){
				currentChar = 0;
			}
			
			if( triggerEvent.keyCode == 27){ // escape. Close the debug window if it's open
				if( this.isShowing)
					hide();
			}
		}
		
		// writes all the commands to the screen
		private function writeDebugCommands():void{
			instructionsTxt.htmlText = ">>Debug Console Commands: <br />";
			for( var i:int = 0; i < Command.commands.length; i++){
				instructionsTxt.htmlText += Command.commands[i].toString() + "<br />";
			}
		}
		
		// checks if the input has something proper in it. Then clears the text input. Called on hitting enter.
		private function evaluateEnter( triggerEvent:KeyboardEvent):void{
			if( triggerEvent.keyCode == 13){ // 13 = enter key
				println("");

				var rex:RegExp = /[\s\r\n]*/gim; // taken from http://stackoverflow.com/questions/2692365/remove-whitespace-in-as3
				var evalString:String = inputTxt.text.replace(rex,''); // strip out whitespace and returns
				evalString = evalString.toLowerCase();
				
				var success:Boolean = false; // whether or not the command was approved.
				for ( var i:int = 0; i < Command.commands.length; i++){
					var myCommand:Command = Command.commands[i];
					if( myCommand.keystroke.toLowerCase() == evalString){
						myCommand.enabled = !myCommand.enabled; // to-do: make one-shot commands
						
						if(myCommand.toggle)
							myCommand.myFunction( myCommand.enabled);
						else
							myCommand.myFunction();
						
						success = true;
						break;
					}
				}
				
				if( success)
					writeDebugCommands();
				else
					println("> Invalid Command.");
				
				inputTxt.text = "";
			}
		}
		
		// prints a string to the debug console.
		private function println( string:String):void{
			errorTxt.text = string;
		}
	}
}

class Command{
	
	public static var commands:Vector.<Command> = new Vector.<Command>();

	public var keystroke:String;
	public var label:String;
	public var toggle:Boolean; // whether or not this command toggles on/off
	public var enabled:Boolean = false; // (for toggle commands). By default, they are off.
	public var myFunction:Function; // function that's called when command is used. 
									// If it's a toggle function, it's passed the enabled value.
	
	public function Command( keystroke:String, label:String, toggle:Boolean, func:Function){
		this.keystroke = keystroke;
		this.label = label;
		this.toggle = toggle;
		this.myFunction = func;
		commands.push(this);
	}
	
	public function toString():String{
		//if(keystroke == "Q"){ // quit doesn't have an on/off toggle.
			//return "> <br />> [" + keystroke + "] " + label;
		if( !toggle) {
			return "> [" + keystroke + "] " + label;
		} else { 	
			var onOffString:String = enabled ? "on" : "off"
			var printString:String = "> [" + keystroke + "] " + label + " [" + onOffString + "]";
			return printString;
		}
	}
}