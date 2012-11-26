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
		
		override public function update():void
		{
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
				else if (centerY > world.player.centerY) {
					if (!collide("enemy", x, y-1)) {
						y--;	
					}
				}
			}
			
			if (collidable) {
				var bullet:Bullet = collide("bullet", x, y) as Bullet;				
				if (bullet) {
					bullet.destroy();
					destroy();
				}
				else {
					if (collide("player", x, y)) {						
						var myWorld:MyWorld = FP.world as MyWorld;
						myWorld.startDeathSequence();
						return;
					}
				}
			} 
			else {
				if (explosionEmitter.particleCount == 0 && world != null) {
					world.remove(this);
				}
			}
		}
		
		public function destroy():void 
		{
			collidable = false;
			for (var i:uint = 0; i < 100; i++) {
				explosionEmitter.emit("explosion", centerX, centerY);
			}
			
			enemyImage.visible = false;
		}
	}
}