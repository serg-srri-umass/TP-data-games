package  {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.text.TextFieldType;

	
	// this class replicates the functionality of a Flex Stepper, but allows for added flexibility of art & code.
	
	public class StepperMVC extends MovieClip{
		
		private const ENTER_KEY:uint = 13; //keycode of the enter key.
		
		private var _value:Number;
		private var _minValue:int = 0;
		private var _maxValue:int = 999;
		private var _precision:int = 0; // how much decimal precision the stepper # has.
		
		private var holdTimer:Timer = new Timer(300, 1);	//when you click an arrow, this timer counts down before the button counts as being "held"
		private var goingUp:Boolean; // whether a held stepper is going upwards or downwards.
		
		private function emptyFunction(e:Event):void{}
		private var _changeFunction:Function = emptyFunction; // this function is called whenever the stepper changes.
		
		private var _enabled:Boolean = true;
		private var _locked:Boolean = false; // when the stepper is locked, it cannot be ajusted. (But it is not grayed out)
		
		public function StepperMVC(){
			//add event listeners to the stepper:
			valueWrapper.valueField.addEventListener(Event.CHANGE, handleChange);
			valueWrapper.valueField.addEventListener(KeyboardEvent.KEY_DOWN, checkForEnter);
			valueWrapper.valueField.addEventListener(FocusEvent.FOCUS_OUT, handleLoseFocus);
			
			up.addEventListener(MouseEvent.MOUSE_DOWN, tickUp);
			up.addEventListener(MouseEvent.MOUSE_UP, releaseUp);
			up.addEventListener(MouseEvent.MOUSE_OUT, releaseUp);
			
			down.addEventListener(MouseEvent.MOUSE_DOWN, tickDown);
			down.addEventListener(MouseEvent.MOUSE_UP, releaseDown);
			down.addEventListener(MouseEvent.MOUSE_OUT, releaseDown);
		}
		
		
		public function get value():Number{
			return _value;
		}
		public function set value(arg:Number):void{
			_value = arg;
			validate();
		}
		
		public function get maxValue():int{
			return _maxValue;
		}
		public function set maxValue(arg:int):void{
			_maxValue = arg;
		}
		
		public function get minValue():int{
			return _minValue;
		}
		public function set minValue(arg:int):void{
			_minValue = arg;
		}
		
		// how many decimal points the stepper functions up to. Default 0.
		public function get precision():int{
			return _precision;
		}
		public function set precision(arg:int):void{
			_precision = arg;
		}
			
		//Returns whether or not the value in the stepper is permitted. If not, forces it into the proper range.
		public function validate( triggerEvent:Event = null):Boolean{
			var fixBadNumber:Boolean = false;
			_value = setPrecision(_value, _precision);
			if(_value < _minValue){
				_value = _minValue;
				fixBadNumber = true;
			}else if(_value > _maxValue){
				_value = _maxValue;
				fixBadNumber = true;
			}
			if(fixBadNumber){
				gotoAndPlay("blink");
			}
			valueWrapper.valueField.text = String(_value);
			
			if(triggerEvent){
				_changeFunction(triggerEvent);
			} else {
				_changeFunction( new Event(MouseEvent.CLICK));
			}
			return !fixBadNumber;
		}
		
		// turn on or off the stepper.
		override public function set enabled(arg:Boolean):void{
			_enabled = arg;
			if(_enabled && !_locked){
				alpha = 1;
				up.mouseEnabled = true;
				down.mouseEnabled = true;
				
				valueWrapper.valueField.selectable = true;
				valueWrapper.valueField.type = TextFieldType.INPUT;
			}else{
				alpha = 0.3;
				up.mouseEnabled = false;
				down.mouseEnabled = false;
				valueWrapper.valueField.selectable = false;
				valueWrapper.valueField.type = TextFieldType.DYNAMIC;
			}
		}
		
		override public function get enabled():Boolean{
			return _enabled;
		}
		
		// set the function that will be executed whenever the stepper updates.
		public function setOnChangeFunction(arg:Function):void{
			_changeFunction = arg;
		}
		
		
		//PRIVATE FUNCTIONS:
		
		private function handleLoseFocus(e:Event):void{
			handleChange(e);
		}
		
		private function handleChange(e:Event):void{
			_value = Number(valueWrapper.valueField.text);
		}
		
		private function tickUp(e:Event):void{
			goingUp = true;
			increment();
			holdTimer.addEventListener(TimerEvent.TIMER, addUpTickFunc);
			holdTimer.reset();
			holdTimer.start();
		}
		
		private function addUpTickFunc(e:Event):void{
			addEventListener(Event.ENTER_FRAME, increment);
		}
	
		private function releaseUp(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, increment);
			holdTimer.stop();
		}
		
		private function tickDown(e:Event = null):void{
			goingUp = false;
			increment();
			holdTimer.addEventListener(TimerEvent.TIMER, startTickDown);
			holdTimer.reset();
			holdTimer.start();
		}
		
		private function startTickDown(e:Event):void{
			addEventListener(Event.ENTER_FRAME, increment);
		}
		private function releaseDown(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, increment);
			holdTimer.stop();
		}
		
		private function increment(e:Event = null):void{
			_value = ( goingUp ? _value+1 : _value-1);
			validate();
		}
		
		private function checkForEnter(e:KeyboardEvent):void{
			if(e.keyCode == ENTER_KEY){
				validate( e);
			}
		}

		// give this method a # and a precision, and it will cut it down to that precision.				
		private function setPrecision(number:Number, precision_in:int) {
			precision_in = Math.pow(10, precision_in);
			return (Math.round(number * precision_in)/precision_in);
		}
		
		public function set locked(arg:Boolean):void{
			_locked = arg;
		}
		
		public function get locked():Boolean{
			return _locked;
		}
	}
	
}
