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