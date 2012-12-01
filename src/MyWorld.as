package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.sensors.Accelerometer;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Tween;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.motion.LinearMotion;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	public class MyWorld extends World
	{
		public var player:Player;
		
		private static const HUD_LAYER:int = -1;		
		private static const GOAL:uint = 100;
		private static const DEBUG:Boolean = false;
		private static const BG_PARTICLE_SPAWN_TIME:Number = 1/10; // seconds
		
		[Embed(source='assets/human_outline.png')] 
		private const HUMAN_OUTLINE:Class;		
		
		[Embed(source = 'assets/LeagueGothic-Regular.otf', embedAsCFF="false", fontFamily = 'MainFont')] 
		private const MAIN_FONT:Class;
		
		private var clones:uint = 0;
		private var timeUntilCloneHostSpawn:Number = 2;
		private var nextCloneHostSpawnSector:int = -1;
		private var timeUntilAmmoHostSpawn:Number = 0;
		private var nextAmmoHostSpawnSector:int = -1;
		private var timeUntilEnemySpawn:Number = 5;
		private var nextEnemySpawnSector:int = -1;
		private var timeUntilBgParticleSpawn:Number = 0;
		private var nextEnemySpawnIndex:uint = 0;
		private var enemySpawnOrder:Array = [];
		
		private var backgroundEmitter:Emitter;
		
		private var levelTimeText:Text = new Text("");
		private var levelText:Text = new Text("1");
		private var bulletText:Text = new Text("0");
		private var progressChart:HumanOutline;
		
		private var playerResetTween:LinearMotion;
		private var sequenceTimeRemaining:Number;
		private var sequenceOverlay:Image;
		private var deathSequence:Boolean = false;		
		private var winSequence:Boolean = false;
		
		private var difficultyTimes:Array = [
			30, 15, 30, 15, 45, 15, 30, 20, 40, 90
		];
		private var ammoSpawnTimes:Array = [
			5, 4, 4, 5, 4, 4, 4, 7, 4, 7
		];
		private var enemySpawnTimes:Array = [
			4, 0.5, 3, 0.5, 2, 0.5, 1, 0.75, 1, 1
		];
		
		private var difficulty:uint = 0;		
		private var difficultyTimeRemaining:Number = difficultyTimes[0];
		 
		// world stats
		public var ammoCollected:uint = 0;
		public var shotsFired:uint = 0;
		public var missedPickups:uint = 0;
		public var enemyKills:uint = 0;
		public var missedAmmoHosts:uint = 0;
		public var rupturedAmmoHosts:uint = 0;
		public var missedCloneHosts:uint = 0;
		public var rupturedCloneHosts:uint = 0;
		
		public function MyWorld()
		{
			FP.screen.color = 0x2b2b2b;
			
			initEnemySpawnOrder();	
			initHUD();
			initPlayer();
			
			var e:Entity = new Entity;
			backgroundEmitter = new Emitter(new BitmapData(4, 6, false, 0x3a3a3a), 4, 6);
			backgroundEmitter.newType("ambiance", [0]); 
			backgroundEmitter.relative = false;
			
			backgroundEmitter.setMotion("ambiance", 270, FP.screen.height + 10, 7, 0, 0, 0);
			e.layer = 99999;
			e.graphic = backgroundEmitter;
			e.x = FP.screen.width / 2;
			e.y = FP.screen.height / 2;
			add(e);
		}
		
		/**
		 * Generate a random list of enemy spawn indices.
		 */
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
		
		/**
		 * Move the player back to the center, out of the way of the HUD.
		 */
		private function startPlayerResetTween():void
		{
			playerResetTween = new LinearMotion;
			playerResetTween.setMotion(player.x, player.y, FP.screen.width / 2 - player.width / 2, FP.screen.height / 2 - player.height / 2, 3.0);
			addTween(playerResetTween);
			playerResetTween.start();	
		}
		
		/**
		 * Set up the overlay and initial transition params for the death sequence.
		 */
		public function startDeathSequence():void
		{
			deathSequence = true;
			
			player.layer = HUD_LAYER;	
			startPlayerResetTween();
			
			var overlayBitmap:BitmapData = new BitmapData(FP.screen.width, FP.screen.height, false, 0x2b2b2b); 
			sequenceOverlay = new Image(overlayBitmap);
			sequenceOverlay.alpha = 0;
			var overlayEntity:Entity = new Entity;
			overlayEntity.graphic = sequenceOverlay;
			overlayEntity.layer = 1;		
			overlayEntity.x = 0;
			overlayEntity.y = 0;
			add(overlayEntity);
			
			sequenceTimeRemaining = 3;
		}
		
		/**
		 * Set up the overlay and initial transition params for the win sequence.
		 */
		private function startWinSequence():void
		{
			winSequence = true;
			
			player.layer = HUD_LAYER;	
			player.shadesOn();			
			startPlayerResetTween();
			
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
			
			sequenceTimeRemaining = 3;
		}
		
		/**
		 * The generic ending sequence handler -- sets up stats displays, 
		 * etc.
		 */
		private function commonEndSequence(label:String, directions:String):void
		{
			removeTween(playerResetTween);
			playerResetTween = null;
			
			sequenceOverlay.alpha = 1.0;
			
			progressChart.toForeground();
			
			var directionsText:Text = new Text(directions);
			directionsText.font = "TitleFont";
			directionsText.color = 0xdddddd;
			directionsText.size = 24;
			
			var directionsEntity:Entity = new Entity();
			directionsEntity.graphic = directionsText;
			directionsEntity.x = 32;
			directionsEntity.y = 48 + 72 + 24;
			directionsEntity.layer = HUD_LAYER + 2;
			add(directionsEntity);
			
			var mainText:Text = new Text(label);		
			mainText.font = "TitleFont";
			mainText.color = 0xffffff;
			mainText.size = 72;
			
			var mainEntity:Entity = new Entity();
			mainEntity.graphic = mainText;
			mainEntity.x = 32;
			mainEntity.y = 48;
			mainEntity.layer = HUD_LAYER + 2;
			add(mainEntity);		
			
			var yBaseline:uint = FP.screen.height - 160;//136;
			
			addStatText("Kills", enemyKills, 116, yBaseline);			
			addStatText("Shots fired", shotsFired, 116, yBaseline + 50);			
			addStatText("Accuracy", shotsFired == 0 ? "N/A" : (Math.round(enemyKills / shotsFired * 100 * 10) / 10) + "%", 116, yBaseline + 100);			
			addStatText("Ammo collected", ammoCollected + " / " + (ammoCollected + missedPickups), FP.screen.width - 240, yBaseline);			
			addStatText("Ammo hosts ruptured", rupturedAmmoHosts + " / " + (missedAmmoHosts + rupturedAmmoHosts), FP.screen.width - 240, yBaseline + 50);
			addStatText("Clone hosts ruptured", rupturedCloneHosts + " / " + (missedCloneHosts + rupturedCloneHosts), FP.screen.width - 240, yBaseline + 100);						
		}
		
		/**
		 * Win sequence finished... display the stats screen.
		 */
		private function endWinSequence():void
		{			
			commonEndSequence("You win!", "Press the spacebar to play again");
		}
		
		/**
		 * Death sequence finished... display the stats screen.
		 */
		private function endDeathSequence():void
		{
			commonEndSequence("Game over", "Press the spacebar to try again");
		}
		
		/**
		 * Display a "Label: value" pair, positioned relative to the ":" char for
		 * easy horizontal alignment. 
		 */
		private function addStatText(label:String, value:Object, labelEndX:uint, labelEndY:int):void
		{
			// Label:
			var labelText:Text = new Text(label + ":");
			labelText.font = "MainFont";
			labelText.color = 0xdddddd;
			labelText.size = 24;
			
			var labelEntity:Entity = new Entity();
			labelEntity.layer = HUD_LAYER + 2;
			labelEntity.graphic = labelText;
			labelEntity.x = labelEndX - labelText.textWidth;
			labelEntity.y = labelEndY;
			add(labelEntity);
			
			// Value
			var valueText:Text = new Text("" + value);
			valueText.font = "MainFont";
			valueText.color = 0xffffff;
			valueText.size = 42;			
			
			var levelEntity:Entity = new Entity();
			levelEntity.layer = HUD_LAYER + 2;
			levelEntity.graphic = valueText;
			levelEntity.x = labelEndX + 8;
			levelEntity.y = labelEndY - 16;
			add(levelEntity);
		}
		
		/**
		 * Clone host ruptured... add progress toward goal.
		 */
		public function addClone():void
		{
			clones += 4;
			progressChart.progress = (clones / GOAL) * 100;
			
			if (clones >= GOAL) {
				startWinSequence();
			}
		}
		
		/**
		 * Support debugging keypresses.
		 */
		private function handleDebugInputs():void {		
			if (DEBUG) {		
				// note: input mappings don't respect one's keyboard layout...
				
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
					difficultyTimeRemaining = int.MAX_VALUE;
				}
				
				// bump up a difficulty level, and stay awhile
				if (Input.pressed(Key.K)) {					
					difficulty = Math.min(enemySpawnTimes.length - 1, difficulty + 1);
					difficultyTimeRemaining = int.MAX_VALUE;
				}				
			}
		}
		
		override public function update():void 
		{	
			drawBackgroundParticles();
			
			handleDebugInputs();
			
			updateDifficulty();
			
			if (updateEndingSequence()) {
				return;
			}
			
			updateHUD();
			
			updateSpawns();
			
			super.update();
		}
		
		/**
		 * Update HUD stats (progress, etc).
		 */
		private function updateHUD():void
		{
			var levelSeconds:uint = Math.floor(difficultyTimeRemaining);				
			levelText.text = "" + (difficulty + 1);			
			levelTimeText.text = levelSeconds + "s";
			bulletText.text = "" + player.bullets;
		}
		
		/**
		 * Introduce new entities to the world.
		 */
		private function updateSpawns():void
		{
			if (timeUntilAmmoHostSpawn <= 0) {
				spawnAmmoHost();
			}
			else {
				timeUntilAmmoHostSpawn -= FP.elapsed;
			}
			
			if (timeUntilCloneHostSpawn <= 0) {
				spawnCloneHost();
			}
			else {
				timeUntilCloneHostSpawn -= FP.elapsed;
			}
			
			if (timeUntilEnemySpawn <= 0) {
				spawnEnemy();
			}
			else {
				timeUntilEnemySpawn -= FP.elapsed;
			}
		}
		
		/**
		 * Update ending sequence entities, if applicable.  If this function
		 * returns true, the update function should abort, as all required
		 * processing is done.
		 * 
		 * @return true if the ending sequence should control the update loop	
		 */ 
		private function updateEndingSequence():Boolean
		{
			if (deathSequence || winSequence) {
				if (sequenceTimeRemaining == 0) {
					if (deathSequence) {
						endDeathSequence();
					}
					else {
						endWinSequence();
					}
					
					sequenceTimeRemaining = -1;
				}
				else if (sequenceTimeRemaining == -1) {				
					if (Input.pressed(Key.SPACE)) {
						FP.world = new MyWorld;
						return true;
					}
				}
				else {
					sequenceOverlay.alpha = (3.0 - sequenceTimeRemaining) / 3.0;
					sequenceTimeRemaining -= FP.elapsed;
					if (sequenceTimeRemaining <= 0) {
						sequenceTimeRemaining = 0;
					}
					player.x = playerResetTween.x;			
					player.y = playerResetTween.y;
				}
				
				if (winSequence) {					
					super.update();
				}				
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Called during update loop to march the difficulty ever upwards.
		 */ 
		private function updateDifficulty():void
		{
			difficultyTimeRemaining -= FP.elapsed;
			if (difficulty < enemySpawnTimes.length - 1 && difficultyTimeRemaining <= 0) {
				difficulty++;
				difficultyTimeRemaining = difficultyTimes[difficulty] + difficultyTimeRemaining;
			}
		}
		
		/**
		 * Emit particles at the specified interval to create the quick-n-dirty
		 * background.
		 */
		private function drawBackgroundParticles():void
		{
			timeUntilBgParticleSpawn -= FP.elapsed;
			if (timeUntilBgParticleSpawn <= 0) {				
				backgroundEmitter.emit("ambiance", FP.screen.width * Math.random(), -7);
				timeUntilBgParticleSpawn = BG_PARTICLE_SPAWN_TIME + timeUntilBgParticleSpawn;
			}
		}
		
		/**
		 * Introduce a new clone host at the top of the world.
		 */
		private function spawnCloneHost():void
		{
			var cloneHost:CloneHost = create(CloneHost, false) as CloneHost;//new CloneHost;
			cloneHost.reset();
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
			
			timeUntilCloneHostSpawn = 8;
		}
		
		/**
		 * Introduce a new enemy at the top of the world.
		 */
		private function spawnEnemy():void
		{	
			var i:int = nextEnemySpawnIndex;
			nextEnemySpawnIndex = (nextEnemySpawnIndex + 1) % enemySpawnOrder.length;			
			
			var e:Enemy = create(Enemy, false) as Enemy;//new Enemy;
			e.reset();
			e.x = enemySpawnOrder[i] * FP.screen.width / 10;
			e.y = -(e.height) - 1;
			
			add(e);			
			timeUntilEnemySpawn = enemySpawnTimes[difficulty];					
		}
		
		/**
		 * Introduce a new ammo host at the top of the world.
		 */
		private function spawnAmmoHost():void
		{
			var ammoHost:AmmoHost = create(AmmoHost, false) as AmmoHost;//new AmmoHost;
			ammoHost.reset();
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
			
			timeUntilAmmoHostSpawn = ammoSpawnTimes[difficulty];
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
			
			if (DEBUG) {	
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
}