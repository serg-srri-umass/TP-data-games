// see also: RadioBtnGroup.as

package commonSWFClasses
{
	import flash.events.MouseEvent;
	
	public class RadioButton extends MovieClipButton
	{
		protected const SELECTED:uint = 4;
		
		private var _isSelected:Boolean = false;
		private var _number:int = -1; // this buttons # within its group. Index 1.
		public var group:RadioBtnGroup; // the radiobutton group that this button belongs to. Every radio button must be part of a group.
		
		public function RadioButton()
		{
			super();
			addEventListener( MouseEvent.CLICK, select);
		}
		
		public function get isSelected():Boolean{
			return _isSelected;
		}
		
		// selecting a radio button automatically deselects all other buttons in its group. 
		public function select( triggerEvent:MouseEvent = null):void{
			if(enabled){
				gotoAndStop( SELECTED);
				if(!group){
					throw new Error("Radio buttons must be assigned to RadioBtnGroups");
				}else{
					group.update(this); // deselects all other buttons in the group.
				}
				_isSelected = true;
				super.enabled = false;
			}
		}
		
		public function deselect( triggerEvent:MouseEvent = null):void{
			gotoAndStop( UP);
			if( _isSelected) 			// if this button was previously selected, re-enable it for clicking.
				super.enabled = true;
			
			_isSelected = false;
		}
		
		// when a radio button is disabled, it's opacity is reduced to 20%. 
		override public function set enabled(arg:Boolean):void{
			super.enabled = arg;
			alpha = arg ? 1 : .2;
		}
		
		// sets this button's # relative to its group. The topmost button is number 1. 
		public function set number(arg:int):void{
			if( _number == -1)
				_number = arg;
			else
				throw new Error("This radio button already has a number assigned to it.");
		}
		
		public function get number():int{
			return _number;
		}
		
	}
}