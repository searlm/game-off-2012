package {
    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.World;
    import net.flashpunk.graphics.Image;

    /**
     * A simple set of static tutorial slides with next/skip buttons.
     */
    public class TutorialScreen extends World {
        private var tutorialStep:int = 0;

        private var tutorialEntity:Entity;

        private var nextButton:Button;
        private var skipButton:Button;

        [Embed(source='assets/tutorial-01.png')]
        private const TUTORIAL_ONE:Class;

        [Embed(source='assets/tutorial-02.png')]
        private const TUTORIAL_TWO:Class;

        [Embed(source='assets/tutorial-03.png')]
        private const TUTORIAL_THREE:Class;

        [Embed(source='assets/tutorial-04.png')]
        private const TUTORIAL_FOUR:Class;

        private var tutorialImages:Array = [
            new Image(TUTORIAL_ONE), new Image(TUTORIAL_TWO),
            new Image(TUTORIAL_THREE), new Image(TUTORIAL_FOUR)
        ];

        public function TutorialScreen() {
            FP.screen.color = 0x2b2b2b;

            tutorialEntity = new Entity;
            tutorialEntity.graphic = tutorialImages[tutorialStep];
            tutorialEntity.layer = 9999;
            add(tutorialEntity);

            nextButton = new Button(this, FP.width - 64 - 16, FP.height / 2 - 32, 64, 64, "Next", next);
            skipButton = new Button(this, FP.width / 2 - 32, FP.height - 96, 96, 64, "Skip tutorial", skip);
        }

        override public function update():void {
            tutorialEntity.graphic = tutorialImages[tutorialStep];
            tutorialEntity.update();

            // iterate through the list of bitmap tutorial images
            // as the "next" button is pressed
            nextButton.update();
            skipButton.update();

            super.update();
        }

        /**
         * Skip the tutorial, and go straight to the title screen.
         */
        private function skip():void {
            FP.world = new TitleScreen;
        }

        /**
         * Proceed to the next tutorial slide.
         */
        private function next():void {
            if (tutorialStep >= tutorialImages.length - 1) {
                skip();
            } else {
                tutorialStep++;
            }
        }
    }
}