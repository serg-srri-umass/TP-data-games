package{
	import flash.display.MovieClip;
	import flash.events.Event;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	public class CraneAnimationInner extends MovieClip{

		public var dir:int = 0;
		public var frameTarget:int;
		public var treasureFound:Boolean = false;
		
		public var hookDropTween:Tween;
		public var ropeDropTween:Tween;
		public var hookLiftTween:Tween;
		public var ropeLiftTween:Tween;
		
		public var hookDropTime:Number;//in seconds -- default is 1
		public var hookRaiseTime:Number;//in seconds -- default is 5
		
		public var craneMoveTween:Tween;
		public var tweenFrame:int;
		
		public function init(){
			mHook.visible = true;
			mRope.visible = true;
			DropHook.hideAll();
			DropHook.visible = false;
			DropRope.visible = false;
		}
		
		public function runTo(numFrame:int):void {
			init();
			frameTarget = Math.max(1, Math.min(100,numFrame));
			if (dir != 0){
				if(dir==1)
					this.removeEventListener(Event.ENTER_FRAME, goForward);
				else if (dir==-1){
					this.removeEventListener(Event.ENTER_FRAME, goBackward);
				}
				dir = 0;
				return;
			}
			if(frameTarget > this.currentFrame){
				this.addEventListener(Event.ENTER_FRAME, goForward);
				dir = 1;
			}else if(frameTarget < this.currentFrame){
				this.addEventListener(Event.ENTER_FRAME, goBackward);
				dir = -1
			}
		}
		
		public function tweenTo(numFrame:int, time:Number=1):void{
			if(numFrame != this.currentFrame){
				init();
				craneMoveTween = new Tween(this, "tweenFrame", Regular.easeOut, this.currentFrame, numFrame, time, true); 
				craneMoveTween.addEventListener(TweenEvent.MOTION_CHANGE, twFrame);
			}
		}
		
		private function twFrame(e:TweenEvent):void{
			this.gotoAndStopMod(tweenFrame);
		}
		
		private function goForward(e:Event):void{
			this.gotoAndStopMod(this.currentFrame+1);
			if(this.currentFrame == 100)
				dispatchEvent(new Event("craneStowed"));
			
			if(this.currentFrame >= frameTarget || this.currentFrame == 100)
				this.removeEventListener(Event.ENTER_FRAME, goForward);
				dir = 0;
		}
		
		private function goBackward(e:Event):void{
			this.gotoAndStopMod(this.currentFrame-1);
			if(this.currentFrame <= frameTarget || this.currentFrame == 1)
				this.removeEventListener(Event.ENTER_FRAME, goBackward);
				dir = 0;
		}
		
		public function dropHook(found:Boolean, secsToDropHook:Number=1,secsToRaiseHook:Number=5):void{
			treasureFound = found;
			hookDropTime = secsToDropHook;
			hookRaiseTime = secsToRaiseHook;
			
			DropHook.hideAll();
			DropHook.x = mHook.x;
			DropRope.x = mRope.x;
			mHook.visible = false;
			mRope.visible = false;
			DropHook.visible = true; 
			DropRope.visible = true;
			hookDropTween = new Tween(DropHook,"y", Strong.easeIn, 111, 400, hookDropTime, true);
			ropeDropTween = new Tween(DropRope,"height", Strong.easeIn, 30, 350, hookDropTime, true);
			hookDropTween.addEventListener(TweenEvent.MOTION_FINISH, pullUpHook);
		}
		
		private function pullUpHook(e:TweenEvent):void{
			//trace("Treasure found = " + treasureFound);
			if(treasureFound){
				DropHook.showTreasure();
			} else {
				DropHook.showRandom();
			}
			hookLiftTween = new Tween(DropHook,"y", Regular.easeInOut, 400, 111, hookRaiseTime, true);
			ropeLiftTween = new Tween(DropRope,"height", Regular.easeInOut, 350, 30, hookRaiseTime, true);
			hookLiftTween.addEventListener(TweenEvent.MOTION_FINISH, clearTweens);
		}
		
		private function clearTweens(e:TweenEvent):void{
			hookDropTween=null;
			ropeDropTween=null;
			ropeLiftTween=null;
			hookLiftTween=null;
		}
		
		public function getFrame():int{
			return this.currentFrame;
		}
		
		public function gotoAndStopMod(frame:Object, scene:String = null):void{
			super.gotoAndStop(frame, scene);
			crane.gotoAndStop(frame);
			ring1.gotoAndStop(frame);
			ring2.gotoAndStop(frame);
			ring3.gotoAndStop(frame);
			activeInterval.gotoAndStop(frame);
		}
		
		public function showMissedInterval():void{
			missedInterval.gotoAndStop( activeInterval.currentFrame);
			missedInterval.visible = true;
		}
	}
}