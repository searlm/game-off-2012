package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Image;

	public class Bullet extends Entity
	{
		private static const LAYER:int = 100;
		
		//[Embed(source='assets/pwrup.png')] private const POWERUP:Class;
		private var bulletImage:Image;
		
		public function Bullet()
		{
			bulletImage = new Image(new BitmapData(9, 9));
			bulletImage.color = 0xd97925;
			graphic = bulletImage;
			
			setHitbox(9, 9);
			layer = LAYER;
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