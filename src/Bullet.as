package {
    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.graphics.Image;

    /**
     * The basic player weapon.
     */
    public class Bullet extends Entity {
        private static const LAYER:int = 100;
        private static const SPEED:uint = 300;

        [Embed(source='assets/bullet_17x17.png')]
        private const BULLET:Class;

        private var bulletImage:Image;

        public function Bullet() {
            bulletImage = new Image(BULLET);
            graphic = bulletImage;

            setHitbox(17, 17);
            layer = LAYER;
            type = "bullet";
        }

        /**
         * Prep for display as a new instance (used after
         * getting a potentially recycled instance).
         */
        public function reset():void {
        }

        override public function update():void {
            moveBy(0, -SPEED * FP.elapsed);

            if (y < height) {
                FP.world.recycle(this);
            }
        }

        public function destroy():void {
            FP.world.recycle(this);
        }
    }
}