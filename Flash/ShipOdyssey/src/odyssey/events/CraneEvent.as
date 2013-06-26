package odyssey.events
{
	import flash.events.Event;
	
	public class CraneEvent extends Event
	{
		public static const DRAGGING:String = "dragging"; //The crane is currently being dragged
		public static const SCALE_CLICKED:String = "scaleClicked"; //A player has clicked on the yellow scale
		public static const STOWED:String = "craneStowed" //The crane has been stowed, and is now facing the nose of the boat
			
		public function CraneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
	}
}