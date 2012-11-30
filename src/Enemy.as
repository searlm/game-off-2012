package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.tweens.misc.ColorTween;
	import net.flashpunk.utils.Ease;

	public class Enemy extends Entity
	{
		private static const LAYER:int = 100;
		private static const MIN_Y_COORD:int = 8;
		
		[Embed(source='assets/bad_dude_64x64.png')] private const BAD_DUDE:Class;
		
		private var enemyImage:Image;
		private var explosionEmitter:Emitter;
		
		public function Enemy()
		{
			enemyImage = new Image(BAD_DUDE);			
			
			mask = new Pixelmask(enemyImage.buffer);
			
			explosionEmitter = new Emitter(new BitmapData(4, 4), 4, 4);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 95, 1.25, 360, -90, -0.25, Ease.quadOut);
			
			graphic = new Graphiclist(enemyImage, explosionEmitter);
			
			layer = LAYER;
			type = "enemy";
		}
		
		/**
		 * Prep for display as a new instance (used after
		 * getting a potentially recycled instance).
		 */
		public function reset():void
		{
			collidable = true;
			enemyImage.visible = true;
		}
		
		override public function update():void
		{
			if (collidable) {
				var bullet:Bullet = collide("bullet", x, y) as Bullet;				
				if (bullet) {
					// noes! die with style
					bullet.destroy();
					(FP.world as MyWorld).enemyKills++;
					destroy();
					return;
				}
				else {
					if (collide("player", x, y)) {	
						// mwahaha... exit to the death sequence
						var myWorld:MyWorld = FP.world as MyWorld;
						myWorld.startDeathSequence();
						return;
					}
				}
			} 
			else {
				if (explosionEmitter.particleCount == 0 && world != null) {
					world.recycle(this);//remove(this);
				}
			}
			
			// if we're above the min height, just drop straight down to 
			// clear space for more enemies to spawn at the top
			if (y < MIN_Y_COORD) {
				if (!collide("enemy", x, y+1)) {
					y++;	
				}
				else {
					if (y < -63) {
						trace("[PILEUP] REMOVAL(" + x + ", " + y + ")");
						destroy(false);					
					}
					else {
						trace("[PILEUP] COLLIDE(" + x + ", " + y + ")");	
					}
				}
			}
			else {
				var world:MyWorld = FP.world as MyWorld;
				if (Math.abs(centerX - world.player.centerX) > 3) {				
					if (centerX < world.player.centerX) {
						if (!collide("enemy", x+1, y)) {
							x++;	
						}
					}
					else if (centerX > world.player.centerX) {
						if (!collide("enemy", x-1, y)) {
							x--;	
						}
					}
				}
				
				if (Math.abs(centerY - world.player.centerY) > 3) {				
					if (centerY < world.player.centerY) {
						if (!collide("enemy", x, y+1)) {
							y++;	
						}
					}
					else if (y > MIN_Y_COORD && centerY > world.player.centerY) {
						if (!collide("enemy", x, y-1)) {
							y--;	
						}
					}
				}
			}
		}
		
		public function destroy(withExplosion:Boolean=true):void 
		{
			if (withExplosion) {				
				collidable = false;
				for (var i:uint = 0; i < 100; i++) {
					explosionEmitter.emit("explosion", centerX, centerY);
				}
				
				enemyImage.visible = false;
			}
			else if (world != null) {
				world.recycle(this);//remove(this);
			}
		}
	}
}