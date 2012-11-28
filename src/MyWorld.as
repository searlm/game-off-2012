package
{
	import flash.display.Bitmap;
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
		public var player:Player;
		
		private static const HUD_LAYER:int = -1;		
		private static const GOAL:uint = 100;
		
		[Embed(source='assets/human_outline.png')] 
		private const HUMAN_OUTLINE:Class;		
		
		[Embed(source = 'assets/LeagueGothic-Regular.otf', embedAsCFF="false", fontFamily = 'MainFont')] 
		private const MAIN_FONT:Class;
		
		private var clones:uint = 0;
		private var ticksUntilCloneHostSpawn:uint = 60;
		private var nextCloneHostSpawnSector:int = -1;
		private var ticksUntilAmmoHostSpawn:uint = 0;
		private var nextAmmoHostSpawnSector:int = -1;
		private var ticksUntilEnemySpawn:uint = 150;
		private var nextEnemySpawnSector:int = -1;
		
		// if you play the game long enough to overflow a uint, you deserve whatever
		// awesomeness happens as a result
		private var totalTicks:uint = 0;
		
		private var bulletText:Text = new Text("0");
		private var progressChart:HumanOutline;
		
		private var sequenceTicksRemaining:int;
		private var sequenceOverlay:Image;
		private var deathSequence:Boolean = false;		
		private var winSequence:Boolean = false;
		
		private var ammoSpawnTimes:Array = [120, 120, 150, 150];
		private var enemySpawnTimes:Array = [45, 40, 35, 30];
		
		private var difficulty:uint = 0;		
		private var difficultyTicksRemaining:uint = 30 * 60;
		
		public function MyWorld()
		{
			// TODO figure out dat CSS (?)
			FP.screen.color = 0x2b2b2b;
			
			initHUD();
			initPlayer();
		}
		
		public function startDeathSequence():void
		{
			deathSequence = true;
			
			player.layer = HUD_LAYER;	
			
			var overlayBitmap:BitmapData = new BitmapData(FP.screen.width, FP.screen.height, false, 0x2b2b2b); 
			sequenceOverlay = new Image(overlayBitmap);
			sequenceOverlay.alpha = 0;
			var overlayEntity:Entity = new Entity;
			overlayEntity.graphic = sequenceOverlay;
			overlayEntity.layer = 1;		
			overlayEntity.x = 0;
			overlayEntity.y = 0;
			add(overlayEntity);
			
			sequenceTicksRemaining = 90;
		}
		
		private function endDeathSequence():void
		{	
			var directionsText:Text = new Text("press the spacebar to try again");		
			directionsText.font = "Blackout Midnight";
			directionsText.color = 0xdddddd;
			directionsText.size = 24;
			
			var directionsEntity:Entity = new Entity();
			directionsEntity.graphic = directionsText;
			directionsEntity.x = 96;
			directionsEntity.y = FP.screen.height - 96;
			directionsEntity.layer = HUD_LAYER;
			add(directionsEntity);
			
			var mainText:Text = new Text("You lose");		
			mainText.font = "Blackout Midnight";
			mainText.color = 0xffffff;
			mainText.size = 72;
			
			var mainEntity:Entity = new Entity();
			mainEntity.graphic = mainText;
			mainEntity.x = 96;
			mainEntity.y = FP.screen.height - 96 - 24 - 72;
			mainEntity.layer = HUD_LAYER;
			add(mainEntity);			
		}
		
		public function addClone():void
		{
			clones += 4;
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
			directionsText.size = 48;
			
			var textEntity:Entity = new Entity();
			textEntity.graphic = directionsText;
			textEntity.x = FP.screen.width / 2 - directionsText.width / 2;
			textEntity.y = FP.screen.height - 72;
			textEntity.layer = HUD_LAYER;
			add(textEntity);
		}
		
		override public function update():void 
		{	
			totalTicks++;
			
			if (difficulty < enemySpawnTimes.length - 1 && difficultyTicksRemaining-- <= 0) {
				difficulty++;
				difficultyTicksRemaining = 30 * 30;
			}
			
			if (winSequence) {				
				if (Input.pressed(Key.SPACE)) {
					FP.world = new MyWorld;
					return;
				}
				
				//super.update();
				return;
			}
			
			if (deathSequence) {
				if (sequenceTicksRemaining == 0) {
					endDeathSequence();
					sequenceTicksRemaining = -1;
				}
				else if (sequenceTicksRemaining == -1) {				
					if (Input.pressed(Key.SPACE)) {
						FP.world = new MyWorld;
						return;
					}
				}
				else {
					sequenceOverlay.alpha = (90 - sequenceTicksRemaining) / 90;
					sequenceTicksRemaining--;					
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
				
				ticksUntilAmmoHostSpawn = ammoSpawnTimes[difficulty];
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
				
				ticksUntilCloneHostSpawn = 240;
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
				
				ticksUntilEnemySpawn = enemySpawnTimes[difficulty];
			}
			else {
				ticksUntilEnemySpawn--;
			}
			
			super.update();
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
			progressChart = new HumanOutline(this, FP.screen.width - 65 - 8, FP.screen.height - 120 - 8);  
			
			// show the ammo count at the bottom of the screen
			var bulletPreamble:Text = new Text("AMMO:");
			bulletPreamble.font = "MainFont";
			bulletPreamble.color = 0xffffff;
			bulletPreamble.size = 24;
			
			// TODO is Entity the right way to do this?
			var bulletPreambleEntity:Entity = new Entity();
			bulletPreambleEntity.layer = 9999;
			bulletPreambleEntity.graphic = bulletPreamble;
			bulletPreambleEntity.x = FP.screen.width - 200;
			bulletPreambleEntity.y = FP.screen.height - 24 - 10;
			add(bulletPreambleEntity);
			
			bulletText.font = "MainFont";
			bulletText.color = 0xffffff;
			bulletText.size = 42;			
			
			var bulletEntity:Entity = new Entity();
			bulletEntity.layer = 9999;
			bulletEntity.graphic = bulletText;
			bulletEntity.x = bulletPreambleEntity.x + bulletPreamble.width + 8;
			bulletEntity.y = FP.screen.height - 42 - 9;
			add(bulletEntity);
		}
	}
}