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

	public class CloneHost extends Entity
	{
		private static const LAYER:int = 50;
		private static const RUPTURE_TIME:Number = 1.5; // seconds to rupture
		
		[Embed(source='assets/clone_host_128x126.png')] private const HOST:Class;
		
		private var hostImage:Image;
		private var explosionEmitter:Emitter;
		private var collisionTime:Number = -1;
		private var babbyViruses:uint = 0;
		private var ticks:uint = 1;
		private var collisionTween:ColorTween = new ColorTween();
		
		public function CloneHost()
		{
			collisionTween.tween(RUPTURE_TIME, 0xffffff, 0x44ff44);
			
			hostImage = new Image(HOST);	
			hostImage.color = 0xffffff;
			hostImage.alpha = 0.9;
			mask = new Pixelmask(hostImage.buffer);
			
			explosionEmitter = new Emitter(new BitmapData(12, 16), 4, 7);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 100, 2.25, 360, -70, -0.5, Ease.quadOut);
			
			graphic = new Graphiclist(hostImage, explosionEmitter);
			
			layer = LAYER;
			type = "clone_host";
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
						addTween(collisionTween);
					}
					
					collisionTime += FP.elapsed;
					hostImage.color = collisionTween.color;
					
					if (collisionTime > RUPTURE_TIME) {
						removeTween(collisionTween);
						spillClones();
						destroy();
					}
				}
				else {
					if (collisionTime >= 0) {
						removeTween(collisionTween);
					}
					else {
						hostImage.color = 0xffffff;
					}
					
					collisionTime = -1;					
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
		
		private function spillClones():void
		{		
			(FP.world as MyWorld).addClone();
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