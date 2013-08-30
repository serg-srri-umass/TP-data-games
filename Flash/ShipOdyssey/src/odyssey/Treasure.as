package odyssey
{
	public class Treasure
	{
		private var _name:String;
		private var _location:Number;
		private var _found:Boolean = false;
		
		public function Treasure(name:String, location:Number){
			_name = name;
			_location = location;
		}
		
		public function set name(arg:String):void{
			_name = arg;
		}
		
		public function get name():String{
			return _name;
		}
		
		public function set location(arg:Number):void{
			_location = arg;
		}
		
		public function get location():Number{
			return _location;
		}
		
		public function get found():Boolean{
			return _found;
		}
		
		public function set found(arg:Boolean):void{
			_found = arg;
		}
		
		// this method gives you the location of the treasure. 
		public function toString():String{
			if(found){
				return ("You found " + name + " at " + location.toFixed(1));
			}else{
				return ("You missed " + name + " at " + location.toFixed(1));
			}
		}
		
	}
}