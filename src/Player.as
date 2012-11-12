package
{
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import net.flashpunk.FP;
	import flash.display.BitmapData;

	public class Player extends Entity
	{
		//[Embed(source='assets/invader.png')] private const PLAYER:Class;
		[Embed(source='assets/pickup.mp3')] private const PICKUP:Class;
		
		public var speed:Number = 8;
		public var pickupSound:Sfx = new Sfx(PICKUP);
		public var playerImage:Image;
		
		private var bulletWait:uint = 0;
		
		public function Player()
		{
			playerImage = new Image(new BitmapData(32, 32));
			playerImage.color = 0xd97925;
			graphic = playerImage;
			setHitbox(32, 32);		
			type = "player";
		}
		
		override public function update():void
		{
			if (bulletWait > 0) {
				bulletWait--;
			}
			
			var p:Powerup = collide("powerup", x, y) as Powerup;
			if (p) {
				pickupSound.play();
				p.destroy();
			}
			
			var offset:Number = speed;
			if (Input.check(Key.LEFT)) { x -= offset; }
			if (Input.check(Key.RIGHT)) { x += offset; }
			if (Input.check(Key.UP)) { y -= offset; }
			if (Input.check(Key.DOWN)) { y += offset; }	
			
			if (bulletWait == 0 && Input.pressed(Key.SPACE)) {
				var bullet:Bullet = new Bullet();
				bullet.x = x + width / 2 - bullet.width / 2;
				bullet.y = y - 16;
				FP.world.add(bullet);
				
				bulletWait = 8;
			}
		}
	}
}