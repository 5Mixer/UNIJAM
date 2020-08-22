package entity;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;

enum BatState {
    Idle;
    Charge;
    Retreat;
}

class Bat extends Entity {
    public var state:BatState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var idleTargetPosition:Vector2 = new Vector2();
    var targetFollowSpeed = 5;
    var origin = new Vector2(260, 280);
    var targetOffset = new Vector2(0, 100);

    var life = 0;

    override public function new() {
        super();
    }

    override public function update(input:Input, level:Level) {
        life++;
        if (state == Idle) {
            var angle = life/100*(Math.PI*2);
            var radius = 200;
            idleTargetPosition = targetPosition.add(new Vector2(Math.cos(angle)*radius, Math.sin(angle)*radius)).sub(targetOffset);
            position = position.add(idleTargetPosition.sub(position).normalized().mult(targetFollowSpeed));
        }
    }
    override public function render(g:Graphics) {
        // g.drawImage(Assets.images.bat, position.x-origin.x, position.y-origin.y);
    }
}