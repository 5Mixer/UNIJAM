package ;

import kha.Color;
import kha.Window;

class Overlay {
    public var dark = false;
    var opacity = 0.;
    var speed = 1/60;
    public function new() {

    }
    public function startTransition() {
        dark = true;
    }
    public function endTransition() {
        dark = false;
    }
    public function update() {
        if (dark && opacity < 1) {
            opacity = Math.min(1, opacity + speed);
        }
        if (!dark && opacity > 0) {
            opacity = Math.max(0, opacity - speed);
        }

    }
    public function render(g:kha.graphics2.Graphics) {
        g.color = Color.fromFloats(0,0,0,opacity);
        g.fillRect(0, 0, Window.get(0).width, Window.get(0).height);
        g.color = Color.White;
    }
}