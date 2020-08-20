package entity;

import kha.graphics2.Graphics;
import kha.math.Vector2;

enum ShielderState {
    Blocking;
    Walking;
    Charging;
}

class Bat extends Entity {
    public var state:ShielderState = Walking;

    override public function update() {
        if (state == Walking) {

        }
    }
    override public function render(g:Graphics) {

    }
}