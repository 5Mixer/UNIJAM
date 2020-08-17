package ;

import kha.graphics2.Graphics;

class Layer {
    public function new() {}

    public function update() {}

    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.layer, 0, 0);
    }
}