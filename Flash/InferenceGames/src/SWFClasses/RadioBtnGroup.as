// a group of radio buttons. See also: RadioButton.as

package 
{
	public class RadioBtnGroup
	{
		private var buttonVector:Vector.<RadioButton> = new Vector.<RadioButton>();  // holds all buttons within this group.
		private var _selectedButton:RadioButton; // the currently selected button.
		
		// pass the radio button group a series of RadioButtons on construction.
		public function RadioBtnGroup( ...buttons){
			if( buttons.length < 2)
				throw new Error("radio button groups must contain at least 2 radio buttons");
			
			for( var i:int = 0; i < buttons.length; i++){
				buttonVector[i] = buttons[i];
				buttonVector[i].group = this;
				buttonVector[i].number = i + 1;
			}
			
			buttonVector[0].select();
			
		}
		
		// this method is called when a radio button is selected. It deselects all the other radio buttons.
		public function update( selectedBtn:RadioButton):void{
			_selectedButton = selectedBtn;
			for( var i:int = 0; i < buttonVector.length; i++){
				if(buttonVector[i] != _selectedButton)
					buttonVector[i].deselect();
			}
		}
		
		// returns the button that's currently selected.
		public function get selectedButton():RadioButton{
			return _selectedButton;
		}
	}
}