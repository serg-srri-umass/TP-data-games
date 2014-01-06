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
	
	public class DebugConsoleSWC extends debugConsoleSWC implements ShowHideAPI
	{
		
		// ----------------
		// --- COMMANDS ---
		// ----------------
		
		internal var c4:Command  = new Command( "U", "Unlock all levels", false, unlockAllLevels);
		internal var c5:Command = new Command( "M", "Show Population Median", false, showPopMedian);
		internal var c6:Command = new Command("1", "Earn Point (User)", false, earnPointPlayer);
		internal var c7:Command = new Command("2", "Earn Point (Bot)", false, earnPointBot);
		
		internal var LAST_COMMAND:Command  = new Command("Q", "Quit Console", false, hide);
		
		// -------------------------
		// --- COMMAND FUNCTIONS ---
		// -------------------------
		
		private function earnPointPlayer():void{
			InferenceGames.instance.sSpaceRace.earnPointRed();
		}
		
		private function earnPointBot():void{
			InferenceGames.instance.sSpaceRace.earnPointGreen();
		}
		
		private function unlockAllLevels():void{
			InferenceGames.instance.unlockedLevels = 6; // all levels are now unlocked.	
			println("All levels unlocked.");
		}
		
		private function showPopMedian():void{
			println("Population Median: " + Round.currentRound.populationMedian);
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