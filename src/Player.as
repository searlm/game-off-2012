package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.masks.Hitbox;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	/**
	 * The controllable player entity.
	 */
	public class Player extends Entity
	{
		private static const LAYER:int = 100;
		private static const SPEED:uint = 220; // pixels per second
		
		[Embed(source='assets/hero_left_48x53.png')] private const PLAYER_LEFT:Class;
		[Embed(source='assets/hero_up_48x53.png')] private const PLAYER_UP:Class;
		[Embed(source='assets/hero_down_48x53.png')] private const PLAYER_DOWN:Class;
		[Embed(source='assets/hero_right_48x53.png')] private const PLAYER_RIGHT:Class;
		
		[Embed(source='assets/hero_glasses_spritemap.png')] private const PLAYER_WIN:Class;
		private var winSprite:Spritemap = new Spritemap(PLAYER_WIN, 128, 126);
		private var winAnimation:Boolean = false; 
		
		private const IMAGE_LEFT:Image = new Image(PLAYER_LEFT);
		private const IMAGE_UP:Image = new Image(PLAYER_UP);
		private const IMAGE_DOWN:Image = new Image(PLAYER_DOWN);
		private const IMAGE_RIGHT:Image = new Image(PLAYER_RIGHT);
		
		private const MASK_LEFT:Pixelmask = new Pixelmask(IMAGE_LEFT.buffer);
		private const MASK_UP:Pixelmask = new Pixelmask(IMAGE_UP.buffer);
		private const MASK_DOWN:Pixelmask = new Pixelmask(IMAGE_DOWN.buffer);
		private const MASK_RIGHT:Pixelmask = new Pixelmask(IMAGE_RIGHT.buffer);
		
		//[Embed(source='assets/pickup.mp3')] private const PICKUP:Class;
		//private var pickupSound:Sfx = new Sfx(PICKUP);
		
		public var bullets:uint;
		public var image:Image;
		
		
		private var bulletWait:Number = 0;
		
		private var playerImage:Image;
		
		public function Player()
		{
			winSprite.add("win", [0, 1, 0, 2], 8, true);
			
			image = IMAGE_DOWN;
			graphic = image;
			mask = MASK_DOWN;
			layer = LAYER;
			type = "player";
		}
		
		/**
		 * Start the winning "shades" animation.
		 */ 
		public function shadesOn():void
		{
			collidable = false;
			graphic = winSprite;
			winAnimation = true;
			mask = new Pixelmask(new BitmapData(128, 126, false, 0xffffff));
			winSprite.play("win", true);
		}
		
		override public function update():void
		{
			if (winAnimation) {
				return;
			}
			
			handlePickups();	
			handleMovement();
			handleWeapons();
		}
		
		/**
		 * Process powerup collisions.
		 */
		private function handlePickups():void
		{
			// TODO multiple powerup collisions in a frame?
			var p:Powerup = collide("powerup", x, y) as Powerup;
			if (p) {
				//pickupSound.play();
				bullets++;
				(FP.world as MyWorld).ammoCollected++;
				p.destroy();
			}
		}
		
		/**
		 * Process weapons input.
		 */
		private function handleWeapons():void
		{
			if (bulletWait > 0) {				
				bulletWait -= FP.elapsed;
			}
			
			if (bulletWait <= 0 && bullets > 0 && Input.pressed(Key.SPACE)) {
				var bullet:Bullet = FP.world.create(Bullet, false) as Bullet;//new Bullet();
				bullet.reset();
				bullet.x = x + width / 2 - bullet.width / 2;
				bullet.y = y - 16;
				FP.world.add(bullet);
				
				bullets--;
				(FP.world as MyWorld).shotsFired++;
				bulletWait = 0.1;
			}
		}		
		
		/**
		 * Process movement controls, and update the graphics accordingly.
		 */
		private function handleMovement():void
		{
			image = IMAGE_DOWN;
			mask = MASK_DOWN;
			
			var offset:Number = SPEED * FP.elapsed;
			var xOffset:Number = 0;
			var yOffset:Number = 0;
			if (Input.check(Key.UP)) { yOffset = -offset; image = IMAGE_UP; mask = MASK_UP;}
			if (Input.check(Key.DOWN)) { yOffset = offset; image = IMAGE_DOWN; mask = MASK_DOWN;}	
			if (Input.check(Key.LEFT)) { xOffset = -offset; image = IMAGE_LEFT; mask = MASK_LEFT;}
			if (Input.check(Key.RIGHT)) { xOffset = offset; image = IMAGE_RIGHT; mask = MASK_RIGHT;}			
			moveBy(xOffset, yOffset);
			
			graphic = image;
			
			x = Math.max(x, 0);
			x = Math.min(x, FP.screen.width - width);
			
			var myWorld:MyWorld = FP.world as MyWorld;
			y = Math.max(y, 0);
			y = Math.min(y, FP.screen.height - height);
		}
	}
}