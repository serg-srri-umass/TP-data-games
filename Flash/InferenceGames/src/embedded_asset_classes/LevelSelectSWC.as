/* STRUCTURE:
- this [labels: "hide", "show"]
	|- levelsMVC 
		|- level[n]Btn (n ranges from 1-6)
			|- numberTxt
			|- intervalTxt
			|- iqrTxt
*/

package embedded_asset_classes{
	
	import flash.events.Event;
	
	public class LevelSelectSWC extends levelSelectSWC implements ShowHideAPI{
		
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static var SINGLETON_LEVELSELECT:LevelSelectSWC;
		
		public static function get instance():LevelSelectSWC{
			return SINGLETON_LEVELSELECT;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public function LevelSelectSWC(){
			super();
			if(!SINGLETON_LEVELSELECT){
				SINGLETON_LEVELSELECT = this;
			}else{
				throw new Error("LevelSelectSWC has already been created");
			}
			
			this.addEventListener(AnimationEvent.COMPLETE_HIDE, onCompleteHide);
			this.addEventListener(AnimationEvent.COMPLETE_SHOW, onCompleteShow);
			visible = false; 
			
			establishRadioButtons();
			
			stop();
		}
		
		public function show(triggerEvent:* = null):void{
			gotoAndPlay("show");
			_isShowing = true;
			visible = true;
			
			BottomBarSWC.instance.levelNameTxt.text = "Choose A Level";
			
			// only enable unlocked levels: 
			for( var i:int = 0; i < 6; i++){
				if(_radioBtnGroup.selectedButton.number != i + 1)
					levelsMVC["level" + (i+1) + "Btn"].enabled = InferenceGames.instance.unlockedLevels > i;
			}
		}
		
		public function hide(triggerEvent:* = null):void{
			gotoAndPlay("hide");
			_isShowing = false;
		}
		
		public function get isShowing():Boolean{
			return _isShowing;
		}
		
		public function getSelectedLevelNumber():int{
			return _radioBtnGroup.selectedButton.number;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var _isShowing:Boolean = false;
		private var _radioBtnGroup:RadioBtnGroup;
		
		private function onCompleteHide(e:AnimationEvent):void{
			visible = false; 
			InferenceGames.instance.newGame();
		}
		
		private function onCompleteShow(e:AnimationEvent):void{
		}
		
		private function establishRadioButtons():void{
			_radioBtnGroup = new RadioBtnGroup( levelsMVC.level1Btn, levelsMVC.level2Btn, levelsMVC.level3Btn, levelsMVC.level4Btn, levelsMVC.level5Btn, levelsMVC.level6Btn );     
			for( var i:int = 0; i < 6; i++){
				levelsMVC["level" + (i+1) + "Btn"].numberTxt.text = i + 1;
				levelsMVC["level" + (i+1) + "Btn"].intervalTxt.text = "±" + Round.kLevelSettings[i].interval;
				levelsMVC["level" + (i+1) + "Btn"].iqrTxt.text = Round.kLevelSettings[i].iqr;
			}
		}
	}
}


