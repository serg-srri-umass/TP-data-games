package{
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class CraneAnimation extends MovieClip{
		
		public function establish(){
			visible = true;
			Crane_mc.missedInterval.visible = false;
		}
		
		//PASS-THROUGH CODE:
		public function runTo(frame:int):void{
			//act as a passthrough
			frame = limit(frame);
			Crane_mc.runTo(frame);
		}
		
		public function toFrame(frame:int):void{
			frame = limit(frame);
			Crane_mc.gotoAndStopMod(frame);
			Crane_mc.frameTarget = frame;
			
			// this hides the dropHook & shows the mHook.
			if(!Crane_mc.mHook.visible)
				Crane_mc.init();
		}
		
		public function dropHook(treasureFound:Boolean, secsDrop:Number, secsLift:Number):void{
			Crane_mc.dropHook(treasureFound, secsDrop, secsLift);
			if(Crane_mc.missedInterval.visible == false && !treasureFound)
				Crane_mc.showMissedInterval();
		}
		
		public function tweenTo(frame:int, time:Number):void{
			Crane_mc.tweenTo(frame, time);
		}
		
		public function getFrame():int{
			return Crane_mc.getFrame();
		}
		
		public function hideTreasure():void{
			Crane_mc.DropHook.hideAll();
		}
		
		//DRAGGING CODE:
		public const SCALE_START:Number = 65;
		public const SCALE_END:Number = 334;
		
		public var _canDrag:Boolean; 
		public var isDragging:Boolean = false;
		public var lastPos:int;
		public var downPos:int;
		
		public var grabbyX:Number;
		public var grabbyY:Number;
		public var snappingPoint:Number;
		public var zeroed:Boolean; //whether the hook is being dragged to position zero.
		
		public function get frame():int{
			return Crane_mc.currentFrame;
		}
		
		public function get canDrag():Boolean{
			return _canDrag;
		}
		
		public function set canDrag(arg:Boolean):void{
			_canDrag = arg;
			grabby.buttonMode = _canDrag;
			grabby2.buttonMode = _canDrag;	// grabby2 is over the yellow scale.
			grabby2.mouseEnabled = _canDrag;
		}
		
		public function highlightArrows(e:Event):void{
			if(_canDrag){
				Crane_mc.glowingArrows.visible = true;	
				Crane_mc.glowingArrows.gotoAndStop("hover");	
			}
		}
		
		public function startDragging(e:MouseEvent):void{
			if(_canDrag){
				showPopUp();
				lastPos = Crane_mc.currentFrame;
				grabby.startDrag();
				runTo(lastPos);
				value = lastPos;
				isDragging = true;
				addEventListener(Event.ENTER_FRAME, animateWhileDragging);
				Crane_mc.glowingArrows.visible = true;
				Crane_mc.glowingArrows.gotoAndStop("on");
				downPos = calcMousePosition(slowness);
			}
		}
		
		public function stopDragging(e:Event):void{
			if(isDragging){
				hidePopUp();
				grabby.stopDrag();
				removeEventListener(Event.ENTER_FRAME, animateWhileDragging);
				grabby.x = grabbyX;
				grabby.y = grabbyY;
				isDragging = false;
			}
			if(e.type != MouseEvent.MOUSE_UP)
				Crane_mc.glowingArrows.visible = false;	
			else if(_canDrag)
				Crane_mc.glowingArrows.gotoAndStop("hover");
		}
		
		public function animateWhileDragging(e:Event):void{
			dispatchEvent(new Event("dragging"));
			var newPos:Number = calcMousePosition(slowness) - downPos;
			toFrame(lastPos + int(newPos));
			value = lastPos + newPos;
			zeroed = (lastPos + newPos) < 1;			
			animateDraggingText( lastPos + newPos);
		}
		
		public function calcMousePosition( slowness:int = 1):Number{
			var pxWidth:Number = (SCALE_END - SCALE_START)/100;
			var pos:Number = (	(mouseX - SCALE_START)/pxWidth) / slowness;
			return pos;
		}
		
		// clips arg so its between 0 and 100.
		public function limit( arg:Number):Number{
			if(arg < 0)
				arg = 0;
			else if(arg > 100)
				arg = 100;
			return arg;
		}
		
		
		public function gotoPoint(e:MouseEvent):void {
			if(_canDrag){
				snappingPoint = limit(calcMousePosition());
				toFrame( int(snappingPoint));
				value = snappingPoint;
				dispatchEvent(new Event("scaleClicked"));
			}
		}
		
		public function showPopUp(e:MouseEvent = null):void {
			if(_canDrag)
				Crane_mc.position.visible = true;
		}
		
		public function hidePopUp(e:MouseEvent = null):void {
			Crane_mc.position.visible = false;	
		}
		
		public function movePopUp(e:MouseEvent):void {
			Crane_mc.position.x = mouseX + 5;
			Crane_mc.position.txt.text = limit(calcMousePosition()).toFixed(1);
			if(isDraggingScale){
				gotoPoint(e);
			}
		}
		
		public function animateDraggingText(txtInt:Number):void {
			Crane_mc.position.x = Crane_mc.mHook.x + 8; // the 8 centers the text.
			Crane_mc.position.txt.text = limit( txtInt).toFixed(1);
		}
		
		public function CraneAnimation(){
			toFrame(100);
			canDrag = true;
			grabbyX = grabby.x;
			grabbyY = grabby.y;
			
			Crane_mc.glowingArrows.visible = false;	
			Crane_mc.missedInterval.visible = false;
			
			grabby.addEventListener(MouseEvent.MOUSE_OVER, highlightArrows);
			grabby.addEventListener(MouseEvent.MOUSE_OUT, stopDragging);
			grabby.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			this.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		
			Crane_mc.position.visible = false;
			
			grabby2.addEventListener(MouseEvent.MOUSE_DOWN, startScaleDrag);
			grabby2.addEventListener(MouseEvent.MOUSE_UP, stopScaleDrag);
			
			grabby2.addEventListener(MouseEvent.MOUSE_MOVE, movePopUp);
			
			grabby2.addEventListener(MouseEvent.MOUSE_OVER, showPopUp);
			grabby2.addEventListener(MouseEvent.MOUSE_OUT, stopScaleDragHidePopUp);
		}
		
		private function stopScaleDragHidePopUp(e:MouseEvent):void{
			hidePopUp(e);
			stopScaleDrag(e);
		}
		
		private function stopScaleDrag(e:MouseEvent):void{
			isDraggingScale = false;
		}
		
		private function startScaleDrag(e:MouseEvent):void{
			if(_canDrag){
				gotoPoint(e);
				isDraggingScale = true;
			}
		}
		
		private var isDraggingScale:Boolean = false;
		
		public function setHookSize(arg:int):void{
			Crane_mc.mHook.gotoAndStop(arg);
			Crane_mc.DropHook.gotoAndStop(arg);
			Crane_mc.missedInterval.craneInterval.gotoAndStop(arg);
			Crane_mc.activeInterval.craneInterval.gotoAndStop(arg);
		}
		
		public function addTreasure():void{
			Crane_mc.hoard.nextFrame();
		}
		
		public function resetTreasure():void{
			Crane_mc.hoard.gotoAndStop(1);
		}
		
		// for the crane to be able to drag to a decimal #, it needs a value independent of it's current frame (which is an int).
		private var _value:Number = 100;
		private var slowness:int = 1; // the bigger this #, the slower the crane will drag. Use it to control the precision.
		
		public function set value( arg:Number):void{
			_value = limit(arg);
		}
		
		public function get value():Number{
			return _value;
		}
	}
}