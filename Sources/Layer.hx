package ;

import kha.graphics2.Graphics;

class Layer {
    var camera:Camera;
    var number = 1;
    public function new(camera:Camera, levelNumber) {
        this.camera = camera;
        this.number = levelNumber;
    }

    public function update() {}

    public function render(g:Graphics) {
        if (number == 1) {
            g.drawImage(kha.Assets.images.level1bg, camera.position.x*.05, camera.position.y*.05);
            g.drawImage(kha.Assets.images.level1fg, 0, 0);
        }else if (number == 2) {
            g.drawImage(kha.Assets.images.level2fg, 0, 0);
        }
    }
}