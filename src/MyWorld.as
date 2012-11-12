package
{
	import net.flashpunk.World;
	import net.flashpunk.FP;

	public class MyWorld extends World
	{
		private var ticksUntilHostSpawn:uint = 0;
		private var nextHostSpawnSector:int = -1;
		
		public function MyWorld()
		{
			FP.screen.color = 0xefe7be;
			
			var player:Player = new Player;
			player.x = FP.screen.width / 2 - player.width / 2;
			player.y = FP.screen.height / 2 - player.height / 2;
			add(player);
			
			var i:int;
			/*for (i = 0; i < 10; i++) {
				var p:Powerup = new Powerup;
				p.x = 32 + Math.random() * (FP.screen.width - 64);
				p.y = 32 + Math.random() * (FP.screen.height - 64);		
				add(p);
			}*/
		}
		
		override public function update():void {
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
	}
}