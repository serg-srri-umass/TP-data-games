package{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class CheckBox extends MovieClip
	{
		private var _checked:Boolean = true;
		public function CheckBox()
		{
			super();
			addEventListener(MouseEvent.MOUSE_OVER, select);
			addEventListener(MouseEvent.MOUSE_OUT, deselect);
			addEventListener(MouseEvent.MOUSE_DOWN, click);
			addEventListener(MouseEvent.MOUSE_UP, select);
			
			buttonMode = true; // use a hand curson when mouse over
		}
		
		public function get checked():Boolean{
			return _checked;
		}
		
		public function select(e:MouseEvent):void{
			if(_checked)
				gotoAndStop(2);
			else
				gotoAndStop(5);
		}
		
		public function deselect(e:MouseEvent):void{
			if(_checked)
				gotoAndStop(1);
			else
				gotoAndStop(4);
		}
		
		public function click(e:MouseEvent):void{
			if(_checked)
				gotoAndStop(3);
			else
				gotoAndStop(6);
			_checked = !_checked;
		}
	}
}