package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import flash.display.BitmapData;

	public class Powerup extends Entity
	{
		private static const LAYER:int = 100;
		
		[Embed(source='assets/bullet_17x17.png')] private const BULLET:Class;
		private var powerupImage:Image;
		
		public function Powerup()
		{
			powerupImage = new Image(BULLET);			
			graphic = powerupImage;
			
			setHitbox(17, 17);
			layer = LAYER;
			type = "powerup";
		}
		
		override public function update():void
		{
			y += 1;
			
			if (y > FP.screen.height || x > FP.screen.width || x < 0 || y < 0) {				
				destroy();
				(world as MyWorld).missedPickups++;
			}
		}
		
		public function destroy():void 
		{
			FP.world.remove(this);	
		}
	}
}