package odyssey
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	public class ShipControlsMVC extends shipControls
	{		
		public function ShipControlsMVC(){
			ratStepper.minValue = 0;
			hookStepper.minValue = 1;
			hookStepper.maxValue = 100;
			hookStepper.precision = 1;
		}
		
		public function get useLargeRatButton():Boolean{
			return sendRatsBtnLarge.visible;
		}
		
		// when true, the large 'Send 100 Rats' button is visible. Otherwise, the stepper is.
		public function set useLargeRatButton( useLargeButton:Boolean):void{
			ratStepper.locked = useLargeButton;
			if(useLargeButton){
				sendRatsBtnLarge.visible = true;
				ratStepper.visible = false;
				sendRatsBtn.visible = false;
				buttonBacker.gotoAndStop(2);
			} else {
				sendRatsBtnLarge.visible = false;
				ratStepper.visible = true;
				sendRatsBtn.visible = true;
				buttonBacker.gotoAndStop(1);
			}
		}
		
		public function disableRatsButton():void{
			sendRatsBtn.mouseEnabled = false;
			sendRatsBtn.alpha = 0.3;
			sendRatsBtnLarge.mouseEnabled = false;
			sendRatsBtnLarge.alpha = 0.3;
		}
		public function enableRatsButton():void{
			sendRatsBtn.mouseEnabled = true;
			sendRatsBtn.alpha = 1;
			sendRatsBtnLarge.mouseEnabled = true;
			sendRatsBtnLarge.alpha = 1;
		}
		
		public function disableHookButton():void{
			dropHookBtn.mouseEnabled = false;
			dropHookBtn.alpha = 0.3;
		}
		public function enableHookButton():void{
			dropHookBtn.mouseEnabled = true;
			dropHookBtn.alpha = 1;
		}
		
		public function setRatButtonFunction(arg:Function):void{
			sendRatsBtn.addEventListener(MouseEvent.CLICK, arg);
			sendRatsBtnLarge.addEventListener(MouseEvent.CLICK, arg);
		}
		public function setHookButtonFunction(arg:Function):void{
			dropHookBtn.addEventListener(MouseEvent.CLICK, arg);
		}
	}
}