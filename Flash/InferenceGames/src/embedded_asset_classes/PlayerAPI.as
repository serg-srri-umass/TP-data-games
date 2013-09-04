/* STRUCTURE:
- this [labels: "hide", "isHidden", "show", "isShowing"]
	|- avatarMVC [labels: "neutral" "neutral_to_happy", "happy", "happy_to_neutral", "neutral_to_sad", "sad", "sad_to_neutral"]
	|- scoreMVC
		|- point1MVC [labels: "isHidden", "show", "isShowing"]
		|- point2MVC [labels: "isHidden", "show", "isShowing"]
		|- point3MVC [labels: "isHidden", "show", "isShowing"]
		|- point4MVC [labels: "isHidden", "show", "isShowing"]
		|- point5MVC [labels: "isHidden", "show", "isShowing"]
		|- point6MVC [labels: "isHidden", "show", "isShowing"]
		|- capMVC [frames 1-7, representing the player's current score + 1]
*/


package embedded_asset_classes
{
	public interface PlayerAPI extends ShowHideAPI
	{
		function earnPoint():void;
		function get score():int;
		function get otherPlayer():PlayerAPI; // returns the opponent's player API.
		function reset():void; // resets the player to their starting state.
		
		function set emotion(emotion:String):void;
	}
}