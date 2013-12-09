package odyssey
{
	import flash.text.TextField;
	import flash.events.MouseEvent;

	public class CreditsScreenMVC extends CreditsSWC
	{
		public function CreditsScreenMVC( credits:*)
		{
			super();
			visible = false;	// credits start invisible
			setCredits( credits);	// set what the credits say
			okayBtn.addEventListener( MouseEvent.CLICK, hide);
		}
		
		// this method sets what the credits say
		public function setCredits( arg:*):void{
			creditsTxt.text = arg;
		}
		
		// hides the credits screen
		private function hide( e:MouseEvent):void{
			visible = false;
		}
	}
}