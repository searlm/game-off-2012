package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	public class MyWorld extends World
	{
		public const BOTTOM_HUD_HEIGHT:int = 32;
		
		public var player:Player;
		
		private static const HUD_LAYER:int = -1;
		
		private var ticksUntilCloneHostSpawn:uint = 140;
		private var nextCloneHostSpawnSector:int = -1;
		private var ticksUntilAmmoHostSpawn:uint = 0;
		private var nextAmmoHostSpawnSector:int = -1;
		private var ticksUntilEnemySpawn:uint = 150;
		private var nextEnemySpawnSector:int = -1;
		
		private var bulletText:Text = new Text("0");
		
		private var deathSequence:Boolean = false;
		
		public function MyWorld()
		{
			// TODO figure out dat CSS (?)
			//FP.screen.color = 0xefe7be;
			FP.screen.color = 0x2b2b2b;
			
			initGround();
			initBulletHUD();
			initPlayer();
		}
		
		public function startDeathSequence():void
		{
			deathSequence = true;
			
 			var directionsText:Text = new Text("press the spacebar to try again");			
			directionsText.color = 0xfafafa;
			directionsText.size = 24;
			
			var textEntity:Entity = new Entity();
			textEntity.graphic = directionsText;
			textEntity.x = FP.screen.width / 2 - directionsText.width / 2;
			textEntity.y = FP.screen.height - 64;
			textEntity.layer = HUD_LAYER;
			add(textEntity);
		}
		
		override public function update():void 
		{	
			if (deathSequence) {				
				if (Input.pressed(Key.SPACE)) {
					FP.world = new MyWorld;
					return;
				}
				
				//super.update();
				return;
			}
			
			bulletText.text = "" + player.bullets;
			
			if (ticksUntilAmmoHostSpawn <= 0) {
				var ammoHost:AmmoHost = new AmmoHost;
				var i1:int = (nextAmmoHostSpawnSector < 0) ? Math.random() * 8 : nextAmmoHostSpawnSector;
				
				// choose the next slot, just don't allow it to be the same as the last one
				var j1:int = i1;
				while (j1 == i1) {
					j1 = Math.random() * 8;
				}
				nextAmmoHostSpawnSector = j1;
				
				ammoHost.x = 16 + nextAmmoHostSpawnSector * ((FP.screen.width - 32) / 8);
				ammoHost.y = -(ammoHost.height);
				add(ammoHost);				
				
				ticksUntilAmmoHostSpawn = 160;
			}
			else {
				ticksUntilAmmoHostSpawn--;
			}
			
			if (ticksUntilCloneHostSpawn <= 0) {
				var cloneHost:CloneHost = new CloneHost;
				var i2:int = (nextCloneHostSpawnSector < 0) ? Math.random() * 5 : nextCloneHostSpawnSector;
				
				// choose the next slot, just don't allow it to be the same as the last one
				var j2:int = i2;
				while (j2 == i2) {
					j2 = Math.random() * 5;
				}
				nextCloneHostSpawnSector = j2;
				
				cloneHost.x = 16 + nextCloneHostSpawnSector * ((FP.screen.width - 32) / 5);
				cloneHost.y = -(cloneHost.height);
				add(cloneHost);				
				
				ticksUntilCloneHostSpawn = 120;
			}
			else {
				ticksUntilCloneHostSpawn--;
			}
			
			if (ticksUntilEnemySpawn <= 0) {
				var e:Enemy = new Enemy;
				var i2:int = (nextEnemySpawnSector < 0) ? Math.random() * 5 : nextEnemySpawnSector;
				
				// choose the next slot, just don't allow it to be the same as the last one
				var j2:int = i2;
				while (j2 == i2) {
					j2 = Math.random() * 5;
				}
				nextEnemySpawnSector = j2;
				
				e.x = 16 + j2 * ((FP.screen.width - 32) / 5);
				e.y = -(e.height);
				
				add(e);				
				
				ticksUntilEnemySpawn = 48;
			}
			else {
				ticksUntilEnemySpawn--;
			}
			
			super.update();
		}
		
		/**
		 * Add a simple rect to the bottom of the screen.
		 */ 
		private function initGround():void
		{
			var ground:Entity = new Entity;
			ground.layer = HUD_LAYER;
			var groundImage:Image = new Image(new BitmapData(FP.screen.width, BOTTOM_HUD_HEIGHT));
			ground.x = 0;
			ground.y = FP.screen.height - BOTTOM_HUD_HEIGHT;
			groundImage.color = 0xbfb997;
			ground.graphic = groundImage;
			add(ground);
		}
		
		/**
		 * Start in the middle of the world.
		 */
		private function initPlayer():void
		{
			player = new Player;
			player.x = FP.screen.width / 2 - player.width / 2;
			player.y = FP.screen.height / 2 - player.height / 2;
			add(player);
		}
		
		/**
		 * Show the ammo count in a static on-screen entity.
		 */
		private function initBulletHUD():void 
		{
			var bulletPreamble:Text = new Text("AMMO:");
			bulletPreamble.color = 0x222222;
			bulletPreamble.size = 18;
			
			// TODO is Entity the right way to do this?
			var bulletPreambleEntity:Entity = new Entity();
			bulletPreambleEntity.layer = HUD_LAYER;
			bulletPreambleEntity.graphic = bulletPreamble;
			bulletPreambleEntity.x = 16;
			bulletPreambleEntity.y = FP.screen.height - 22;
			add(bulletPreambleEntity);
			
			bulletText.color = 0xab1a25;
			bulletText.size = 32;			
			
			var bulletEntity:Entity = new Entity();
			bulletEntity.layer = HUD_LAYER;
			bulletEntity.graphic = bulletText;
			bulletEntity.x = 80;
			bulletEntity.y = FP.screen.height - 32;
			add(bulletEntity);
		}
	}
}