package common{
	import flash.utils.Timer;
	
	public class SafeTimer{
		
		private var listenersAndFunctions:Array = new Array(2);
		private var realTimer:Timer;
		public static var eventType:int = 0;
		public static var functionName:int = 1;
		
		public function SafeTimer(delay:Number, repeatCount:int=0){
			realTimer = new Timer(delay, repeatCount); //instantiating Timer that we are wrapping
			listenersAndFunctions[eventType] = new Vector.<String>(); //for holding event type strings
			listenersAndFunctions[functionName] = new Vector.<Function>(); //for holding function name strings
		}
		
		//removes all eventListeners registered with this SafeTimer 
		public function clean():void{
			while(listenersAndFunctions[eventType].length > 0){
				realTimer.removeEventListener(listenersAndFunctions[eventType].pop(), listenersAndFunctions[functionName].pop());
			}
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
												  priority:int = 0, useWeakReference:Boolean = false):void{
		
			//turning listener function into a string
			//adding the event type and listener function name to vector for later removing event listeners
			listenersAndFunctions[eventType].push(type);
			listenersAndFunctions[functionName].push(listener);
			
			realTimer.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		//wrapping other necessary Timer methods, just passing them through this class. 
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			realTimer.removeEventListener(type, listener, useCapture);
		}
		
		public function start():void{
			realTimer.start();
		}
		public function stop():void{
			realTimer.stop();
		}
		
		public function reset():void{
			realTimer.reset();
		}
	}
}