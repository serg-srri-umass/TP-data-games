package{
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class CraneAnimation extends MovieClip{
		
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
		}
		
		public function dropHook(treasureFound:Boolean, secsDrop:Number, secsLift:Number):void{
			Crane_mc.dropHook(treasureFound, secsDrop, secsLift);
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
		
		public var canDrag:Boolean = true; 
		public var isDragging:Boolean = false;
		public var lastPos:int;
		public var downPos:int;
		
		public var grabbyX:Number;
		public var grabbyY:Number;
		public var snappingPoint:int;
		public var zeroed:Boolean; //whether the hook is being dragged to position zero.
		
		public function get frame():int{
			return Crane_mc.currentFrame;
		}
		
		public function highlightArrows(e:Event):void{
			if(canDrag){
				Crane_mc.glowingArrows.visible = true;	
				Crane_mc.glowingArrows.gotoAndStop("hover");	
			}
		}
		
		public function startDragging(e:MouseEvent):void{
			if(canDrag){
				lastPos = Crane_mc.currentFrame;
				grabby.startDrag();
				runTo(lastPos);
				isDragging = true;
				addEventListener(Event.ENTER_FRAME, animateWhileDragging);
				Crane_mc.glowingArrows.visible = true;
				Crane_mc.glowingArrows.gotoAndStop("on");
				downPos = calcMousePosition();
			}
		}
		
		public function stopDragging(e:Event):void{
			if(isDragging){
				grabby.stopDrag();
				removeEventListener(Event.ENTER_FRAME, animateWhileDragging);
				grabby.x = grabbyX;
				grabby.y = grabbyY;
				isDragging = false;
			}
			if(e.type != MouseEvent.MOUSE_UP)
				Crane_mc.glowingArrows.visible = false;	
			else if(canDrag)
				Crane_mc.glowingArrows.gotoAndStop("hover");
		}
		
		public function animateWhileDragging(e:Event):void{
			dispatchEvent(new Event("dragging"));
			var newPos = calcMousePosition() - downPos;
			toFrame(lastPos + newPos);
			zeroed = (lastPos + newPos) < 1;
		}
		
		public function calcMousePosition():int{
			var pxWidth:Number = (SCALE_END - SCALE_START)/100;
			var pos = (	(mouseX - SCALE_START)/pxWidth);
			return pos;
		}
		public function limit(arg:int):int{
			if(arg < 0)
				arg = 0;
			else if(arg > 100)
				arg = 100;
			return arg;
		}
		
		
		public function gotoPoint(e:MouseEvent):void {
			if(canDrag){
				snappingPoint = limit(calcMousePosition());
				runTo(snappingPoint);	
				dispatchEvent(new Event("scaleClicked"));
			}
		}
		
		public function showPopUp(e:MouseEvent):void {
			if(canDrag)
				Crane_mc.position.visible = true;
		}
		
		public function hidePopUp(e:MouseEvent):void {
			Crane_mc.position.visible = false;	
		}
		
		public function movePopUp(e:MouseEvent):void {
			Crane_mc.position.x = mouseX + 5;
			Crane_mc.position.txt.text = limit(calcMousePosition());
		}
		
		public function CraneAnimation(){
			toFrame(100);
			
			grabbyX = grabby.x;
			grabbyY = grabby.y;
			
			Crane_mc.glowingArrows.visible = false;	
			
			grabby.buttonMode = true;
			grabby.addEventListener(MouseEvent.MOUSE_OVER, highlightArrows);
			grabby.addEventListener(MouseEvent.MOUSE_OUT, stopDragging);
			grabby.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			this.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		
			Crane_mc.position.visible = false;
			Crane_mc.scale.addEventListener(MouseEvent.CLICK, gotoPoint);
			Crane_mc.scale.addEventListener(MouseEvent.MOUSE_MOVE, movePopUp);
			Crane_mc.scale.addEventListener(MouseEvent.MOUSE_OVER, showPopUp);
			Crane_mc.scale.addEventListener(MouseEvent.MOUSE_OUT, hidePopUp);
		}
	}
}