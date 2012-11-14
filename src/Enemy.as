package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.tweens.misc.ColorTween;
	import net.flashpunk.utils.Ease;

	public class Enemy extends Entity
	{
		private const LAYER:int = 100;
		
		private var enemyImage:Image;
		private var explosionEmitter:Emitter;
		private var pinnedToBottom:Boolean = false;
		
		public function Enemy()
		{
			enemyImage = new Image(new BitmapData(64, 48));
			enemyImage.color = 0xab1a25;			
			
			explosionEmitter = new Emitter(new BitmapData(4, 4), 4, 4);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 95, 1.25, 360, -90, -0.25, Ease.quadOut);
			
			graphic = new Graphiclist(enemyImage, explosionEmitter);
			
			setHitbox(64, 48);
			layer = LAYER;
			type = "enemy";
		}
		
		override public function update():void
		{
			if (!pinnedToBottom) {
				y = Math.min(y + 2, FP.screen.height - height - 32);	
			}
			
			if (collidable) {
				var bullet:Bullet = collide("bullet", x, y) as Bullet;				
				if (bullet) {
					bullet.destroy();
					destroy();
				}
				else {
					if (collide("player", x, y)) {
						// TODO ... this kills the player
						trace("AAAAAAAAH!");
					}
					
					var otherEnemy:Enemy = collide("enemy", x, y + 1) as Enemy;
					if (otherEnemy) {
						// collided with another enemy -- this means we've reached the
						// bottom of the screen, and need to pile on top of the other
						// enemies stuck there			
						pinnedToBottom = true;
					}
				}
			} 
			else {
				if (!pinnedToBottom && explosionEmitter.particleCount == 0 && world != null) {
					world.remove(this);
				}
			}
			
			if (y == FP.screen.height - height - 32) {
				pinnedToBottom = true;
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