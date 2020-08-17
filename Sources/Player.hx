package ;

import kha.math.Vector2;

class Player {
    public var position:Vector2;
    public var velocity:Vector2;
    var speed = 5;
    var acceleration = 1;
    var deceleration = .8;
    public function new() {
        position = new Vector2();
        velocity = new Vector2();
    }
    public function update(input:Input) {
        // Left/right change horizontal velocity
        if (input.left) {
            velocity = velocity.add(new Vector2(-acceleration, 0));
        }
        if (input.right) {
            velocity = velocity.add(new Vector2(acceleration, 0));
        }

        // Decelerate on no input
        if (!input.left && !input.right) {
            velocity = velocity.normalized().mult(Math.max(0, velocity.length - deceleration));
        }

        // Cap velocity add speed and apply
        velocity = velocity.normalized().mult(Math.min(velocity.length, speed));
        position = position.add(velocity);
    }
    public function render(g:kha.graphics2.Graphics) {
        g.color = kha.Color.Red;
        g.fillRect(position.x, position.y, 10, 20);
        g.color = kha.Color.White;
    }
}