package {
    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.graphics.Image;

    /**
     * The ammo pickup entity.
     */
    public class Powerup extends Entity {
        private static const LAYER:int = 100;
        private static const SPEED:uint = 60; // pixels per second

        [Embed(source='assets/bullet_17x17.png')]
        private const BULLET:Class;

        private var powerupImage:Image;

        public function Powerup() {
            powerupImage = new Image(BULLET);
            graphic = powerupImage;

            setHitbox(17, 17);
            layer = LAYER;
            type = "powerup";
        }

        /**
         * Prep for display as a new instance (used after
         * getting a potentially recycled instance).
         */
        public function reset():void {
        }

        override public function update():void {
            moveBy(0, SPEED * FP.elapsed);

            if (y > FP.screen.height || x > FP.screen.width || x < 0 || y < 0) {
                destroy();
                (FP.world as MyWorld).missedPickups++;
            }
        }

        public function destroy():void {
            FP.world.recycle(this);
        }
    }
}