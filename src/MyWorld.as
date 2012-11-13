package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Text;

	public class MyWorld extends World
	{
		private var ticksUntilHostSpawn:uint = 0;
		private var nextHostSpawnSector:int = -1;
		
		private var player:Player;
		private var bulletText:Text = new Text("0");
		
		public function MyWorld()
		{
			// TODO figure out dat CSS (?)
			FP.screen.color = 0xefe7be;
			
			initBulletHUD();
			initPlayer();
		}
		
		override public function update():void {
			bulletText.text = "" + player.bullets;
			
			if (ticksUntilHostSpawn <= 0) {
				var h:Host = new Host;
				var i:int = (nextHostSpawnSector < 0) ? Math.random() * 8 : nextHostSpawnSector;

				// choose the next slot, just don't allow it to be the same as the last one
				var j:int = i;
				while (j == i) {
					j = Math.random() * 8;
				}
				nextHostSpawnSector = j;
				
				h.x = 16 + nextHostSpawnSector * (FP.screen.width - 64 - 32) / 8;
				h.y = -(h.height);
				add(h);				
				
				ticksUntilHostSpawn = 140;
			}
			else {
				ticksUntilHostSpawn--;
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
		 * Show the ammo count in a static on-screen entity.
		 */
		private function initBulletHUD():void 
		{
			var bulletPreamble:Text = new Text("AMMO:");
			bulletPreamble.color = 0x666666;
			bulletPreamble.size = 18;
			
			// TODO is Entity the right way to do this?
			var bulletPreambleEntity:Entity = new Entity();
			bulletPreambleEntity.graphic = bulletPreamble;
			bulletPreambleEntity.x = 16;
			bulletPreambleEntity.y = FP.screen.height - 22;
			add(bulletPreambleEntity);
			
			bulletText.color = 0xab1a25;
			bulletText.size = 32;			
			
			var bulletEntity:Entity = new Entity();
			bulletEntity.graphic = bulletText;
			bulletEntity.x = 80;
			bulletEntity.y = FP.screen.height - 32;
			add(bulletEntity);
		}
	}
}