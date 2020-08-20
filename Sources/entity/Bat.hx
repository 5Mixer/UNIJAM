package entity;

import kha.graphics2.Graphics;
import kha.math.Vector2;

enum BatState {
    Idle;
    Charge;
    Retreat;
}

class Bat extends Entity {
    public var state:BatState = Idle;

    override public function update() {
        if (state == Idle) {

        }
    }
    override public function render(g:Graphics) {

    }
}