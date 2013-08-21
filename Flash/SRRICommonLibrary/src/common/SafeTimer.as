package common{
	import flash.utils.Timer;
	
	public class SafeTimer extends Timer{
		
		private var listenersAndFunctions:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
		public static var eventType:int = 0;
		public static var functionName:int = 1;
		
		public function SafeTimer(delay:Number, repeatCount:int=0){
			super(delay, repeatCount);
			listenersAndFunctions[eventType] = new Vector.<String>(); //for holding event type strings
			listenersAndFunctions[functionName] = new Vector.<String>(); //for holding function name strings
		}
		
		//removes all eventListeners registered with this SafeTimer 
		public function clean():void{
			while(listenersAndFunctions[eventType].length < 0){
				this.removeEventListener(listenersAndFunctions[eventType].pop(), listenersAndFunctions[functionName].pop());
			}
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
												  priority:int = 0, useWeakReference:Boolean = false):void{
		
			//adding the event type and listener function name to vector for later removing event listeners
			listenersAndFunctions[eventType].push(type);
			listenersAndFunctions[functionName].push(listener);
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	}
}