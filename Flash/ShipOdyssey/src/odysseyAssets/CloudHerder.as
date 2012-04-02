//****Code by SRRI and Tristan Warneke, 2012; Released under Open Source (MIT) License****

package odysseyAssets {
	
	import flash.display.*;
	import flash.events.*;
	
	public class CloudHerder {
		var cm:CloudMaker = new CloudMaker();
		
		var mvArr:Array = new Array();
		var velArr:Array = new Array();
		var numClouds:int = 10;
		var velocityScale:Number = 1;
		var windVelocity:Number = Math.random();
		var pDisplay:DisplayObject;
		var sWidth:int;
		
		public function CloudHerder() {
			// constructor code
			cm.setBaseColor(0x999999);
		}
		
		public function init(p:DisplayObject, numberOfClouds:int, stgWidth:int):void{
			numClouds = numberOfClouds;
			pDisplay = p;
			sWidth = stgWidth;
			for(var i:int=0; i<numClouds; i++){
				var mv:MovieClip = cm.createCloud();
				mv.x = Math.random() * sWidth*2 - sWidth;
				mv.y = i*15+10;
				mv.scaleX = mv.scaleY = (1-((mv.y-30)/215));
				mvArr.push(mv);
				velArr.push(windVelocity * mv.scaleX);
				pDisplay.addChildAt(mv,1);
			}
		}
		
		public function startClouds(){
			this.addEventListener(Event.ENTER_FRAME, moveCloud);
		}
		private function moveCloud(e:Event):void{
			//mv.x += .25;
			for(var i:int=0; i<numClouds; i++){
				mvArr[i].x += velArr[i];
				//if (mvArr[i].x - mvArr[i].width > stage.stageWidth){
				if (mvArr[i].getBounds > sWidth){
					var prevY:Number = mvArr[i].y;
					var scale:Number = mvArr[i].scaleX;
					//cloud is offscreen
					//trace("Object " + i + " is offscreen: " + mvArr[i].x + " and W: " + mvArr[i].width);
					pDisplay.removeChild(mvArr[i]);
					var mc:MovieClip = cm.createCloud();
					mc.y = prevY;
					mc.scaleX = mvArr[i].scaleY = scale;
					mc.x = -mvArr[i].width - 20;
					velArr[i] = windVelocity * scale;
					mvArr[i] = mc;
					pDisplay.addChild(mvArr[i]);
					pDisplay.setChildIndex(mc, i);
				}
			}
		}
	}
}




