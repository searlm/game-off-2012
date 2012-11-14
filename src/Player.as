package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	public class Player extends Entity
	{
		private const LAYER:int = 100;
		
		//[Embed(source='assets/invader.png')] private const PLAYER:Class;
		[Embed(source='assets/pickup.mp3')] private const PICKUP:Class;
		
		public var bullets:uint;
		
		private var speed:Number = 6;
		private var pickupSound:Sfx = new Sfx(PICKUP);
		private var playerImage:Image;
		
		private var bulletWait:uint = 0;
		
		public function Player()
		{
			playerImage = new Image(new BitmapData(32, 32));
			playerImage.color = 0xd97925;
			graphic = playerImage;
			setHitbox(32, 32);
			layer = LAYER;
			type = "player";
		}
		
		override public function update():void
		{
			// TODO bounds check (or draw collidable objects around the bounds)
			
			if (bulletWait > 0) {
				bulletWait--;
			}
			
			var p:Powerup = collide("powerup", x, y) as Powerup;
			if (p) {
				pickupSound.play();
				bullets++;
				p.destroy();
			}
			
			var offset:Number = speed;
			if (Input.check(Key.LEFT)) { x -= offset; }
			if (Input.check(Key.RIGHT)) { x += offset; }
			if (Input.check(Key.UP)) { y -= offset; }
			if (Input.check(Key.DOWN)) { y += offset; }	
			
			if (bulletWait == 0 && bullets > 0 && Input.pressed(Key.SPACE)) {
				var bullet:Bullet = new Bullet();
				bullet.x = x + width / 2 - bullet.width / 2;
				bullet.y = y - 16;
				FP.world.add(bullet);
				
				bullets--;
				bulletWait = 8;
			}
		}
	}
}