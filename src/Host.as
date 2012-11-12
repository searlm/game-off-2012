package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Ease;

	public class Host extends Entity
	{
		public var hostImage:Image;
		public var explosionEmitter:Emitter;
		public var collisionTime:Number = -1;
		public var babbyViruses:uint = 0;
		public var ticks:uint = 1;
		
		public function Host()
		{
			hostImage = new Image(new BitmapData(64, 128));
			hostImage.color = 0x0002635;
			hostImage.alpha = 0.7;
			
			explosionEmitter = new Emitter(new BitmapData(12, 16), 4, 7);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 100, 2.25, 360, -70, -0.5, Ease.quadOut);
			
			graphic = new Graphiclist(hostImage, explosionEmitter);
			
			setHitbox(64, 128);
			type = "host";
		}
		
		override public function update():void
		{
			y += 2;
			
			if (collidable) {
				var bullet:Bullet = collide("bullet", x, y) as Bullet;
				if (bullet) {
					bullet.destroy();
					destroy();
				}
				else if (collide("player", x, y)) {
					if (collisionTime < 0) {
						collisionTime = 0;	
					}
					
					collisionTime += FP.elapsed;
					
					if (collisionTime > 2) {
						destroy();
					}
				}
				else {
					collisionTime = -1;
					
					hostImage.color = 0x013440;
				}
			} 
			else {
				if (explosionEmitter.particleCount == 0 && world != null) {
					world.remove(this);
				}
			}
			
			if (y > FP.screen.height) {
				world.remove(this);
			}
		}
		
		public function destroy():void 
		{
			collidable = false;
			for (var i:uint = 0; i < 75; i++) {
				explosionEmitter.emit("explosion", centerX, centerY);
			}
			
			hostImage.visible = false;
			//FP.world.remove(this);	
		}
	}
}