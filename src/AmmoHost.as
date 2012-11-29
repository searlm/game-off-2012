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

	public class AmmoHost extends Entity
	{
		private static const LAYER:int = 50;
		private static const RUPTURE_TIME:Number = 1.5; // seconds to rupture
		
		[Embed(source='assets/ammo_host_96x128.png')] private const HOST:Class;
		[Embed(source='assets/bullet_17x17.png')] private const BULLET:Class;
		
		private var hostImage:Image;
		private var explosionEmitter:Emitter;
		private var collisionTime:Number = -1;
		private var babbyViruses:uint = 0;
		private var ticks:uint = 1;
		private var collisionTween:ColorTween = new ColorTween();
		
		public function AmmoHost()
		{
			collisionTween.tween(RUPTURE_TIME, 0xffffff, 0x888888);
			
			hostImage = new Image(HOST);	
			hostImage.color = 0xffffff;
			hostImage.alpha = 0.9;
			mask = new Pixelmask(hostImage.buffer);
			
			var bulletImage:Image = new Image(BULLET);
			explosionEmitter = new Emitter(bulletImage.buffer, 17, 17);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 40, 0.4, 360, -30, -0.05, Ease.quadOut);
			
			graphic = new Graphiclist(hostImage, explosionEmitter);
			
			layer = LAYER;
			type = "host";
		}
		
		override public function update():void
		{
			y += 2;
			
			if (collidable) {
				if (collide("player", x, y)) {
					if (collisionTime < 0) {
						collisionTime = 0;	
						addTween(collisionTween);
					}
					
					collisionTime += FP.elapsed;
					hostImage.color = collisionTween.color;
					
					if (collisionTime > RUPTURE_TIME) {
						removeTween(collisionTween);
						spillClones();
						(world as MyWorld).rupturedAmmoHosts++;
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
				(world as MyWorld).missedAmmoHosts++;
			}
		}
		
		private function spillClones():void
		{
			var p:Powerup = new Powerup();
			p.x = x + 20;
			p.y = y;
			FP.world.add(p);
			
			p = new Powerup();
			p.x = x - 5;
			p.y = y + height / 2;
			FP.world.add(p);
			
			p = new Powerup();
			p.x = x + 20;
			p.y = y + height;
			FP.world.add(p);
			
			p = new Powerup();
			p.x = x + width - 20;
			p.y = y + height;
			FP.world.add(p);
			
			p = new Powerup();
			p.x = x + width + 5;
			p.y = y + height / 2;
			FP.world.add(p);
			
			p = new Powerup();
			p.x = x + width - 20;
			p.y = y;
			FP.world.add(p);
		}
		
		public function destroy():void 
		{
			collidable = false;
			for (var i:uint = 0; i < 10; i++) {
				explosionEmitter.emit("explosion", centerX, centerY);
			}
			
			hostImage.visible = false;
			//FP.world.remove(this);	
		}
	}
}