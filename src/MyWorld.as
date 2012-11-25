package
{
	import flash.display.BitmapData;
	import flash.sensors.Accelerometer;
	
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
		private static const GOAL:uint = 100;
		
		[Embed(source='assets/human_outline.png')] private const HUMAN_OUTLINE:Class;
		
		private var clones:uint = 0;
		private var ticksUntilCloneHostSpawn:uint = 90;
		private var nextCloneHostSpawnSector:int = -1;
		private var ticksUntilAmmoHostSpawn:uint = 0;
		private var nextAmmoHostSpawnSector:int = -1;
		private var ticksUntilEnemySpawn:uint = 150;
		private var nextEnemySpawnSector:int = -1;
		
		private var bulletText:Text = new Text("0");
		private var progressChart:HumanOutline;
		
		private var deathSequence:Boolean = false;
		private var winSequence:Boolean = false;
		
		public function MyWorld()
		{
			// TODO figure out dat CSS (?)
			//FP.screen.color = 0xefe7be;
			FP.screen.color = 0x2b2b2b;
			
			initGround();
			initHUD();
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
		
		public function addClone():void
		{
			clones += 2;
			progressChart.progress = (clones / GOAL) * 100;
			
			if (clones >= GOAL) {
				startWinSequence();
			}
		}
		
		private function startWinSequence():void
		{
			winSequence = true;
			
			var directionsText:Text = new Text("YOU WIN");			
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
			if (winSequence) {				
				if (Input.pressed(Key.SPACE)) {
					FP.world = new MyWorld;
					return;
				}
				
				//super.update();
				return;
			}
			
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
				var i1:int = (nextAmmoHostSpawnSector < 0) ? Math.random() * 6 : nextAmmoHostSpawnSector;
				
				// choose the next slot, just don't allow it to be the same as the last one
				var j1:int = i1;
				while (j1 == i1) {
					j1 = Math.random() * 6;
				}
				nextAmmoHostSpawnSector = j1;
				
				ammoHost.x = 16 + nextAmmoHostSpawnSector * ((FP.screen.width - 32) / 6);
				ammoHost.y = -(ammoHost.height);
				add(ammoHost);				
				
				ticksUntilAmmoHostSpawn = 180;
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
				
				ticksUntilCloneHostSpawn = 360;
			}
			else {
				ticksUntilCloneHostSpawn--;
			}
			
			if (ticksUntilEnemySpawn <= 0) {
				var e:Enemy = new Enemy;
				var i3:int = (nextEnemySpawnSector < 0) ? Math.random() * 5 : nextEnemySpawnSector;
				
				// choose the next slot, just don't allow it to be the same as the last one
				var j3:int = i3;
				while (j3 == i3) {
					j3 = Math.random() * 5;
				}
				nextEnemySpawnSector = j3;
				
				e.x = 16 + j3 * ((FP.screen.width - 32) / 5);
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
		 * Create a simple HUD.
		 */
		private function initHUD():void 
		{
			// show the completion chart (human outline) on the right
			progressChart = new HumanOutline(this, FP.screen.width - 65 - 8, FP.screen.height - 120 - BOTTOM_HUD_HEIGHT - 8);  
			
			// show the ammo count at the bottom of the screen
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