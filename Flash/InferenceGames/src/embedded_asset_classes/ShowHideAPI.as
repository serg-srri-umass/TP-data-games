// MovieClips that use this API must have a show and a hide function.
package embedded_asset_classes
{
	import flash.events.Event;
	
	public interface ShowHideAPI
	{
		function show( triggerEvent:Event = null):void;
		function hide( triggerEvent:Event = null):void;
		function get isShowing():Boolean;
	}
}