package ;

import kha.graphics2.Graphics;

class Layer {
    var camera:Camera;
    public function new(camera:Camera) {
        this.camera = camera;
    }

    public function update() {}

    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.level1bg, camera.position.x*.05, 0);
        g.drawImage(kha.Assets.images.level1fg, 0, 0);
    }
}