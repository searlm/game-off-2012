package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import flash.display.BitmapData;

	public class Powerup extends Entity
	{
		//[Embed(source='assets/pwrup.png')] private const POWERUP:Class;
		private var powerupImage:Image;
		
		public function Powerup()
		{
			powerupImage = new Image(new BitmapData(16, 16));
			powerupImage.color = 0xab1a25;
			graphic = powerupImage;
			
			setHitbox(16, 16);
			type = "powerup";
		}
		
		public function destroy():void 
		{
			FP.world.remove(this);	
		}
	}
}