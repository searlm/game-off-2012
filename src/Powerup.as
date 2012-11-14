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
		
		//[Embed(source='assets/pwrup.png')] private const POWERUP:Class;
		private var powerupImage:Image;
		
		public function Powerup()
		{
			powerupImage = new Image(new BitmapData(8, 8));
			powerupImage.color = 0xd97925;
			graphic = powerupImage;
			
			setHitbox(8, 8);
			layer = LAYER;
			type = "powerup";
		}
		
		override public function update():void
		{
			y += 1;
			
			if (y > FP.screen.height || x > FP.screen.width || x < 0 || y < 0) {
				destroy();
			}
		}
		
		public function destroy():void 
		{
			FP.world.remove(this);	
		}
	}
}