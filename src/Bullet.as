package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import flash.display.BitmapData;

	public class Bullet extends Entity
	{
		//[Embed(source='assets/pwrup.png')] private const POWERUP:Class;
		private var bulletImage:Image;
		
		public function Bullet()
		{
			bulletImage = new Image(new BitmapData(16, 16));
			bulletImage.color = 0xab1a25;
			graphic = bulletImage;
			
			setHitbox(9, 9);
			type = "bullet";
		}
		
		override public function update():void {
			if (y < height) {
				FP.world.remove(this);
			}
			
			y -= 10;
		}
		
		public function destroy():void 
		{
			FP.world.remove(this);	
		}
	}
}