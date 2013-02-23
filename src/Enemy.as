package {
    import flash.display.BitmapData;

    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.graphics.Emitter;
    import net.flashpunk.graphics.Graphiclist;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.masks.Pixelmask;
    import net.flashpunk.utils.Ease;

    /**
     * The basic enemy entity -- chases the player, kills
     * on contact.
     */
    public class Enemy extends Entity {
        private static const LAYER:int = 100;
        private static const MIN_Y_COORD:int = 0;
        private static const SPEED:uint = 40;

        [Embed(source='assets/bad_dude_64x64.png')]
        private const BAD_DUDE:Class;

        private var enemyImage:Image;
        private var explosionEmitter:Emitter;

        public function Enemy() {
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
        public function reset():void {
            collidable = true;
            enemyImage.visible = true;
        }

        override public function update():void {
            if (collidable) {
                var bullet:Bullet = collide("bullet", x, y) as Bullet;
                if (bullet) {
                    // oh noes! die with style
                    bullet.destroy();
                    (FP.world as MyWorld).enemyKills++;
                    destroy();
                    return;
                } else if (collide("player", x, y)) {
                    // mwahaha... exit to the death sequence
                    var myWorld:MyWorld = FP.world as MyWorld;
                    myWorld.startDeathSequence();
                    return;
                }
            } else if (explosionEmitter.particleCount == 0) {
                FP.world.recycle(this);
            }

            // if we're above the min height, just drop straight down to
            // clear space for more enemies to spawn at the top
            if (y < MIN_Y_COORD) {
                moveBy(0, SPEED * FP.elapsed, "enemy", true);
            } else {
                var offset:Number = SPEED * FP.elapsed;
                var xOffset:Number = 0;
                var yOffset:Number = 0;

                var world:MyWorld = FP.world as MyWorld;
                if (Math.abs(centerX - world.player.centerX) > offset) {
                    if (centerX < world.player.centerX) {
                        xOffset = offset;
                    } else if (centerX > world.player.centerX) {
                        xOffset = -offset;
                    }
                }

                if (Math.abs(centerY - world.player.centerY) > offset) {
                    if (centerY < world.player.centerY) {
                        yOffset = offset;
                    } else if (y > MIN_Y_COORD && centerY > world.player.centerY) {
                        yOffset = -offset;
                    }
                }

                moveBy(xOffset, yOffset, "enemy", true);
            }
        }

        public function destroy(withExplosion:Boolean = true):void {
            if (withExplosion) {
                collidable = false;
                for (var i:uint = 0; i < 100; i++) {
                    explosionEmitter.emit("explosion", centerX, centerY);
                }

                enemyImage.visible = false;
            } else {
                FP.world.recycle(this);
            }
        }
    }
}