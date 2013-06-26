package odyssey {
	public class TreasureNamePicker{
		
		//arrays split into pools of names for selection on each level 
		private var pool1Arr:Array = new Array( 
			"the Dud",
			"the Tsar's Ring", "the Ardabil Carpet",
			"the Diamond Tiara", "the Sword with Ebony Handle",
			"the Jewel Crown", "the Shah's Silver Set",
			"the Platinum Breastplate", "the Silver Goblet");
		
		private var pool2Arr:Array = new Array( 
			"the Black Pearl", "the Ivory Candelabra",
			"the Golden Ganesha", "the Gilded Scepter",
			"a Case of Gold Bars", "the Rosewood Jaguar",
			"the Garnet Bracelet", "the Emerald amulet");
		
		private var pool3Arr:Array = new Array( 
			"the Cloisonné Teapot", "the Porcelain Mask",
			"the Crystal Chandelier", "the Crimson Grail",
			"the Glass Slippers", "a Chest of Spanish Coins",
			"King Arthur’s Sword (Reproduction)", "a Trip for Two to Puerto Vallarta");
		
		private var pool4Arr:Array = new Array( 
			"the Jade Elephant", "the Viscount's Helmet",
			"the Opal Locket", "the Gilded Mirror",
			"the Silken Tapestry", "Assorted Meats", 
			"the Pearl necklace", "a chest of Doubloons");
		
		private var pool5Arr:Array = new Array(
			"the Sacred Scrolls", "Shakespeare’s Quill",
			"the Kinnara Statue", "Captain Kidd's Pistol",
			"Blackbeard's Cape", "a Dinner with Johnny Depp",
			"the Brass Chalice", "the Star of India");
		
		private var reserveArr:Array = new Array( 
			"the Opal Locket", "the Egret Vase",
			"some Discount Coupons", "the Ruby Choker",
			"the Sleeping Buddha", "the Trunk O' Cash",
			"some Matsutake Mushrooms");
		
		//each of these functions returns the next string available in its pool, 
		//or a name from the reserve pool if the chosen pool is empty. 
		//To reset pools, make a new TreasureNamePicker obj. 										
		public function pool1():String{
			if(pool1Arr.length > 0){
				return pool1Arr.shift();
			}else{
				return reserveArr.shift();
			}
		}
		
		public function pool2():String{
			if(pool2Arr.length > 0){
				return pool2Arr.shift();
			}else{
				return reserveArr.shift();
			}
		}
		
		public function pool3():String{
			if(pool3Arr.length > 0){
				return pool3Arr.shift();
			}else{
				return reserveArr.shift();
			}
		}
		
		public function pool4():String{
			if(pool4Arr.length > 0){
				return pool4Arr.shift();
			}else{
				return reserveArr.shift();
			}
		}
		
		public function pool5():String{
			if(pool5Arr.length > 0){
				return pool5Arr.shift();
			}else{
				return reserveArr.shift();
			}
		}
	}
}