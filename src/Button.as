package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
    import net.flashpunk.World;
    import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;

	/**
	 * A type for adding bare-bones buttons to a World.
	 */
	public class Button
	{
        private var entity:Entity;
		private var label:String;
		private var clickHandler:Function;
        private var width:int;
        private var height:int;
        private var isHovered:Boolean = false;
		
		public function Button(world:World, x:int, y:int, width:int, height:int, label:String, clickHandler:Function)
		{
            entity = new Entity;
			entity.graphic = new Image(new BitmapData(width, height, false, 0x999999));
			entity.x = x;
			entity.y = y;
            entity.type = "button";

            this.width = width;
            this.height = height;

            entity.setHitbox(width,  height);

			this.clickHandler = clickHandler;
			
			var labelText:Text = new Text(label);
			labelText.color = 0xffffff;
            labelText.font = "MainFont"; // embedded in MyWorld.as
            labelText.size = 24;
			var textEntity:Entity = new Entity;
			textEntity.graphic = labelText;
			textEntity.x = x + width / 2 - labelText.textWidth / 2;
            textEntity.y = y + height / 2 - labelText.textHeight / 2;

            world.add(entity);
            world.add(textEntity);
		}

		public function update():void
		{
			// check for hover
            if (entity.collidePoint(entity.x,  entity.y, FP.world.mouseX, FP.world.mouseY)) {
                if (!isHovered) {
                    entity.graphic = new Image(new BitmapData(width, height, false, 0xbbbbbb));
                }

                isHovered = true;
            }
            else {
                if (isHovered) {
                    entity.graphic = new Image(new BitmapData(width, height, false, 0x999999));
                }

                isHovered = false;
            }

            // click detection
            if (isHovered && Input.mousePressed && clickHandler != null) {
                clickHandler();
            }
		}
	}
}