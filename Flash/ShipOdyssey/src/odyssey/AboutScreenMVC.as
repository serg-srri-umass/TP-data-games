package odyssey
{
	// This class is the SWC file that contains the About Screen and 'okay' button
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class AboutScreenMVC extends aboutScreenSWC
	{
		public function AboutScreenMVC( credits:String)
		{
			super();
			visible = false;	// credits start invisible
			setCredits( credits);	// set what the credits say
			okayBtn.addEventListener( MouseEvent.CLICK, hide);
		}
		
		// this method sets what the credits say
		public function setCredits( arg:String):void{

			// create a new text field
			var tf:TextField = createCustomTextField(70, 121, 370, 194);
			tf.wordWrap = true;
			tf.multiline = true;
			tf.htmlText = arg;
			tf.selectable = true; // links only work if the text is selectable. 

			// format the text to use Arial font of size 12:
			var standardTxt:TextFormat = new TextFormat("Arial", 12);
			tf.setTextFormat( standardTxt);
		}
		
		// hides the credits screen
		private function hide( e:MouseEvent):void{
			visible = false;
		}
		
		// creates a textfield with the following parameters
		// taken from the AS3 documentaiton of TextField
		private function createCustomTextField(x:Number, y:Number, width:Number, height:Number):TextField {
			var result:TextField = new TextField();
			result.x = x;
			result.y = y;
			result.width = width;
			result.height = height;
			addChild(result);
			return result;
		}
	}
}