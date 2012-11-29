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
		
		private static const ONE_SECOND:uint = 30;
		private static const HUD_LAYER:int = -1;		
		private static const GOAL:uint = 100;
		private static const DEBUG:Boolean = true;
		
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
		
		private var levelTimeText:Text = new Text("");
		private var levelText:Text = new Text("1");
		private var bulletText:Text = new Text("0");
		private var progressChart:HumanOutline;
		
		private var sequenceTicksRemaining:int;
		private var sequenceOverlay:Image;
		private var deathSequence:Boolean = false;		
		private var winSequence:Boolean = false;
		
		private var difficultyTimes:Array = [
			30*ONE_SECOND, 10*ONE_SECOND, 30*ONE_SECOND, 10*ONE_SECOND, 60*ONE_SECOND, 30*ONE_SECOND, 90*ONE_SECOND
		];
		private var ammoSpawnTimes:Array = [
			5*ONE_SECOND, 3*ONE_SECOND, 5*ONE_SECOND, 3*ONE_SECOND, 7*ONE_SECOND, 3*ONE_SECOND, 7*ONE_SECOND
		];
		private var enemySpawnTimes:Array = [
			120, 15, 60, 15, 30, 10, 30
		];
		
		private var difficulty:uint = 0;		
		private var difficultyTicksRemaining:uint = difficultyTimes[0];
		
		private var nextEnemySpawnIndex:uint = 0;
		private var enemySpawnOrder:Array = [];
		
		public var ammoCollected:uint = 0;
		public var shotsFired:uint = 0;
		public var enemyKills:uint = 0;
		public var missedAmmoHosts:uint = 0;
		public var rupturedAmmoHosts:uint = 0;
		public var missedCloneHosts:uint = 0;
		public var rupturedCloneHosts:uint = 0;
		
		public function MyWorld()
		{
			// TODO figure out dat CSS (?)
			FP.screen.color = 0x2b2b2b;
			
			initEnemySpawnOrder();	
			initHUD();
			initPlayer();
		}
		
		private function initEnemySpawnOrder():void
		{
			// shuffle the spawn order		
			var tmp:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
			while (tmp.length > 0) {
				// pick an element
				var i:int = Math.random() * (tmp.length - 1);
				
				// swap the selected value to the front
				var t:int = tmp[i];
				tmp[i] = tmp[0];
				tmp[0] = t;
				
				// move the selected value to the target array
				enemySpawnOrder.push(tmp.shift());
			}
		}
		
		public function startDeathSequence():void
		{
			deathSequence = true;
			
			player.layer = HUD_LAYER;
			player.image.alpha = 0.5;	
			
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
		
		private function endWinSequence():void
		{	
			var directionsText:Text = new Text("press the spacebar to play again");		
			directionsText.font = "Blackout Midnight";
			directionsText.color = 0xdddddd;
			directionsText.size = 24;
			
			var directionsEntity:Entity = new Entity();
			directionsEntity.graphic = directionsText;
			directionsEntity.x = 96;
			directionsEntity.y = FP.screen.height - 96;
			directionsEntity.layer = HUD_LAYER;
			add(directionsEntity);
			
			var mainText:Text = new Text("You win!");		
			mainText.font = "Blackout Midnight";
			mainText.color = 0xffffff;
			mainText.size = 72;
			
			var mainEntity:Entity = new Entity();
			mainEntity.graphic = mainText;
			mainEntity.x = 32;
			mainEntity.y = FP.screen.height - 96 - 24 - 72;
			mainEntity.layer = HUD_LAYER;
			add(mainEntity);			
		}
		
		private function endDeathSequence():void
		{	
			sequenceOverlay.alpha = 1.0;
			
			progressChart.toForeground();
			 
			var directionsText:Text = new Text("press the spacebar to try again");		
			directionsText.font = "Blackout Midnight";
			directionsText.color = 0xdddddd;
			directionsText.size = 24;
			
			var directionsEntity:Entity = new Entity();
			directionsEntity.graphic = directionsText;
			directionsEntity.x = 96;
			directionsEntity.y = FP.screen.height - 96;
			directionsEntity.layer = HUD_LAYER + 2;
			add(directionsEntity);
			
			var mainText:Text = new Text("You lose");		
			mainText.font = "Blackout Midnight";
			mainText.color = 0xffffff;
			mainText.size = 72;
			
			var mainEntity:Entity = new Entity();
			mainEntity.graphic = mainText;
			mainEntity.x = 32;
			mainEntity.y = FP.screen.height - 96 - 24 - 72;
			mainEntity.layer = HUD_LAYER + 2;
			add(mainEntity);			
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
			
			player.layer = HUD_LAYER;	
			
			// TODO switch to the animated sprite loop
			
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
		
		private function handleDebugInputs():void {		
			if (DEBUG) {		
				// note: input mappings don't respect the keyboard layout...
				
				// suicide
				if (Input.pressed(Key.S)) {
					startDeathSequence();					
				}
				
				// insta-win 
				if (Input.pressed(Key.W)) {
					startWinSequence();					
				}
				
				// step down a difficulty level and stay awhile
				if (Input.pressed(Key.J)) {
					difficulty = Math.max(0, difficulty - 1);
					difficultyTicksRemaining = int.MAX_VALUE;
				}
				
				// bump up a difficulty level, and stay awhile
				if (Input.pressed(Key.K)) {					
					difficulty = Math.min(enemySpawnTimes.length - 1, difficulty + 1);
					difficultyTicksRemaining = int.MAX_VALUE;
				}				
			}
		}
		
		override public function update():void 
		{	
			totalTicks++;
			
			handleDebugInputs();
			
			if (difficulty < enemySpawnTimes.length - 1 && difficultyTicksRemaining-- == 0) {
				difficulty++;
				difficultyTicksRemaining = difficultyTimes[difficulty];
			}
			
			if (deathSequence || winSequence) {
				if (sequenceTicksRemaining == 0) {
					if (deathSequence) {
						endDeathSequence();
					}
					else {
						endWinSequence();
					}
					
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
			
			var levelSeconds:uint = Math.floor(difficultyTicksRemaining / ONE_SECOND);
				
			levelText.text = "" + (difficulty + 1);			
			levelTimeText.text = levelSeconds + "s";
			bulletText.text = "" + player.bullets;
			
			if (ticksUntilAmmoHostSpawn <= 0) {
				spawnAmmoHost();
			}
			else {
				ticksUntilAmmoHostSpawn--;
			}
			
			if (ticksUntilCloneHostSpawn <= 0) {
				spawnCloneHost();
			}
			else {
				ticksUntilCloneHostSpawn--;
			}
			
			if (ticksUntilEnemySpawn <= 0) {
				spawnEnemy();
			}
			else {
				ticksUntilEnemySpawn--;
			}
			
			super.update();
		}
		
		private function spawnCloneHost():void
		{
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
		
		private function spawnEnemy():void
		{	
			var i:int = nextEnemySpawnIndex;
			nextEnemySpawnIndex = (nextEnemySpawnIndex + 1) % enemySpawnOrder.length;			
			
			var e:Enemy = new Enemy;
			e.x = enemySpawnOrder[i] * FP.screen.width / 10;
			e.y = -(e.height) - 1;
			
			add(e);			
			ticksUntilEnemySpawn = enemySpawnTimes[difficulty];					
		}
		
		private function spawnAmmoHost():void
		{
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
			bulletEntity.y = FP.screen.height - 42 - 8;
			add(bulletEntity);
			
			// show the current level
			var levelPreamble:Text = new Text("LEVEL:");
			levelPreamble.font = "MainFont";
			levelPreamble.color = 0xffffff;
			levelPreamble.size = 24;
			
			var levelPreambleEntity:Entity = new Entity();
			levelPreambleEntity.layer = 9999;
			levelPreambleEntity.graphic = levelPreamble;
			levelPreambleEntity.x = 16;
			levelPreambleEntity.y = FP.screen.height - 24 - 10;
			add(levelPreambleEntity);
			
			levelText.font = "MainFont";
			levelText.color = 0xffffff;
			levelText.size = 42;			
			
			var levelEntity:Entity = new Entity();
			levelEntity.layer = 9999;
			levelEntity.graphic = levelText;
			levelEntity.x = levelPreambleEntity.x + levelPreamble.width + 8;
			levelEntity.y = FP.screen.height - 42 - 9;
			add(levelEntity);
			
			levelTimeText.font = "MainFont";
			levelTimeText.color = 0x888888;
			levelTimeText.size = 64;			
			
			var levelTimeEntity:Entity = new Entity();
			levelTimeEntity.layer = 9999;
			levelTimeEntity.graphic = levelTimeText;
			levelTimeEntity.x = levelEntity.x + levelText.width + 32;
			levelTimeEntity.y = FP.screen.height - 64 - 8;
			add(levelTimeEntity);
		}
	}
}