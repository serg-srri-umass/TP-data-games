package embedded_asset_classes{

    import flash.events.Event;

    public class LevelSelectSWC extends levelSelectSWC implements ShowHideAPI{
	
	private static var SINGLETON_LEVELSELECT:LevelSelectSWC;
	private var _isShowing:Boolean = false;

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
		stop();
	    }
		
		public static function get LEVELSELECT():LevelSelectSWC{
		    return SINGLETON_LEVELSELECT;
		}

		public function show(triggerEvent:Event = null):void{
		    gotoAndPlay("show");
		    _isShowing = true;
		    visible = true;
		}

		public function hide(triggerEvent:Event = null):void{
		    gotoAndPlay("hide");
		    _isShowing = false;
		}
		    
		public function get isShowing():Boolean{
		    return _isShowing;
		}

		private function onCompleteHide(e:AnimationEvent):void{
		    visible = false; 
		    InferenceGames.instance.newGame();
		}

		private function onCompleteShow(e:AnimationEvent):void{
		}
	    }
	}
		    

