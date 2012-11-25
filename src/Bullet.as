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
		
		[Embed(source='assets/bullet_17x17.png')] private const BULLET:Class;
		
		private var bulletImage:Image;
		
		public function Bullet()
		{
			bulletImage = new Image(BULLET);
			graphic = bulletImage;
			
			setHitbox(17, 17);
			layer = LAYER;
			type = "bullet";
		}
		
		override public function update():void 
		{
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