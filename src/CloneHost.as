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
		private static const SPEED:uint = 70; // pixels per second
		
		[Embed(source='assets/clone_host_128x126.png')] private const HOST:Class;
		[Embed(source='assets/hero_clone_16x18.png')] private const CLONE:Class;
		
		private var hostImage:Image;
		private var explosionEmitter:Emitter;
		private var collisionTime:Number = -1;
		private var babbyViruses:uint = 0;
		private var ticks:uint = 1;
		private var collisionTween:ColorTween = new ColorTween();
		
		public function CloneHost()
		{	
			hostImage = new Image(HOST);	
			hostImage.color = 0xffffff;
			hostImage.alpha = 0.9;
			mask = new Pixelmask(hostImage.buffer);
			
			var cloneImage:Image = new Image(CLONE);
			explosionEmitter = new Emitter(cloneImage.buffer, 16, 18);
			explosionEmitter.newType("explosion", [0]); 
			explosionEmitter.relative = false;
			
			explosionEmitter.setAlpha("explosion", 1, 0);
			explosionEmitter.setMotion("explosion", 0, 320, 3, 360, -100, -0.5, Ease.quadOut);
			
			graphic = new Graphiclist(hostImage, explosionEmitter);
			
			layer = LAYER;
			type = "clone_host";
		}
		
		/**
		 * Prep for display as a new instance (used after
		 * getting a potentially recycled instance).
		 */
		public function reset():void
		{
			collisionTween.tween(RUPTURE_TIME, 0xffffff, 0x666666);
			collisionTime = -1;
			collidable = true;
			hostImage.visible = true;
			hostImage.color = 0xffffff;
		}
		
		override public function update():void
		{			
			if (collidable) {
				moveBy(0, SPEED * FP.elapsed);
				if (collide("player", x, y)) {
					if (collisionTime < 0) {
						collisionTime = 0;	
						addTween(collisionTween);
					}
					
					collisionTime += FP.elapsed;
					hostImage.color = collisionTween.color;
					
					if (collisionTime > RUPTURE_TIME) {
						collisionTween.cancel();
						spillClones();
						(world as MyWorld).rupturedCloneHosts++;
						destroy();
					}
				}
				else {
					if (collisionTime >= 0) {
						collisionTween.cancel();
						collisionTween.tween(RUPTURE_TIME, 0xffffff, 0x666666);
						hostImage.color = 0xffffff;
					}
					
					collisionTime = -1;					
				}
			} 
			else {
				if (explosionEmitter.particleCount == 0 && world != null) {
					world.recycle(this);//remove(this);
				}
			}
			
			if (y > FP.screen.height) {
				world.recycle(this);//remove(this);
				(world as MyWorld).missedCloneHosts++;
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
		}
	}
}