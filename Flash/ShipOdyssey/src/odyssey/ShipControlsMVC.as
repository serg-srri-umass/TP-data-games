package odyssey
{
	import flash.events.MouseEvent;
	
	public class ShipControlsMVC extends shipControls
	{
		public function ShipControlsMVC(){
			ratStepper.minValue = 0;
			hookStepper.minValue = 0;
			hookStepper.maxValue = 100;
		}
		
		public function disableRatsButton():void{
			sendRatsBtn.mouseEnabled = false;
			sendRatsBtn.alpha = 0.3;
		}
		public function enableRatsButton():void{
			sendRatsBtn.mouseEnabled = true;
			sendRatsBtn.alpha = 1;
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
		}
		public function setHookButtonFunction(arg:Function):void{
			dropHookBtn.addEventListener(MouseEvent.CLICK, arg);
		}
	}
}