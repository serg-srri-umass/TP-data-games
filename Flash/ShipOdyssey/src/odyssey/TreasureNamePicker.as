package odyssey {
	public class TreasureNamePicker{
		
		//arrays split into pools of names for selection on each level 
		private static var pool1Arr:Array = new Array( 
			"the Tsar's Ring", "the Ardabil Carpet",
			"the Diamond Tiara", "the Sword with Ebony Handle",
			"the Jewel Crown", "the Shah's Silver Set",
			"the Platinum Breastplate", "the Silver Goblet");
		
		private static var pool2Arr:Array = new Array( 
			"the Black Pearl", "the Ivory Candelabra",
			"the Golden Ganesha", "the Gilded Scepter",
			"a Case of Gold Bars", "the Rosewood Jaguar",
			"the Garnet Bracelet", "the Emerald Amulet");
		
		private static var pool3Arr:Array = new Array( 
			"the Cloisonné Teapot", "the Porcelain Mask",
			"the Crystal Chandelier", "the Crimson Grail",
			"the Glass Slippers", "a Chest of Spanish Coins",
			"King Arthur’s Sword (Reproduction)");
		
		private static var pool4Arr:Array = new Array( 
			"the Jade Elephant", "the Viscount's Helmet",
			"the Opal Locket", "the Gilded Mirror",
			"the Silken Tapestry", "Assorted Meats", 
			"the Pearl Necklace", "a Chest of Doubloons");
		
		private static var pool5Arr:Array = new Array(
			"the Sacred Scrolls", "Shakespeare’s Quill",
			"the Kinnara Statue", "Captain Kidd's Pistol",
			"Blackbeard's Cape", "a Dinner with Johnny Depp",
			"the Brass Chalice", "the Star of India");
		
		private static var reserveArr:Array = new Array( 
			"the Opal Locket", "the Egret Vase",
			"some Discount Coupons", "the Ruby Choker",
			"the Sleeping Buddha", "the Trunk O' Cash",
			"some Matsutake Mushrooms");
		
		//each of these functions returns the next string available in its pool, 
		 //or a name from the reserve pool if the chosen pool is empty. 
		//To reset pools, make a new TreasureNamePicker obj.										
		
		
		//returns next String available in pool specified by @param poolNum. 
		//Puts the returned String back at the end of the pool. 
		public static function poolShift(poolNum:int):String{
			var outString:String = "";
			switch(poolNum){
				case 1:
					outString = pool1Arr.shift();
					pool1Arr.push(outString);
					break;
				case 2:
					outString = pool2Arr.shift();
					pool2Arr.push(outString);
					break;
				case 3:
					outString = pool3Arr.shift();
					pool3Arr.push(outString);
					break;
				case 4:
					outString = pool4Arr.shift();
					pool4Arr.push(outString);
					break;
				case 5:
					outString = pool5Arr.shift();
					pool5Arr.push(outString);
					break;
				case 6: // using pool5 for mission 6 for now 
					outString = pool5Arr.shift();
					pool5Arr.push(outString);
					break;
				default:
					trace("mission # is out of range for treasure pool chooser");
			}
			return outString;
		}
	}
}