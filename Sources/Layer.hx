package ;

import kha.graphics2.Graphics;

class Layer {
    public function new() {}

    public function update() {}

    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.level1bg, 0, 0);
        g.drawImage(kha.Assets.images.level1fg, 0, 0);
    }
}