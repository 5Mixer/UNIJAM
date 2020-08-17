package ;

import kha.math.Vector2;

class Player {
    public var position:Vector2;
    public var velocity:Vector2;
    public var maxJumps = 2;
    var speed = 8;
    var acceleration = 1.5;
    var deceleration = .8;
    var jumpAcceleration = 10;

    var airJumps = 0;

    var gravity = .8;

    public function new() {
        position = new Vector2(100, 500);
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
            if (Math.abs(velocity.x) > deceleration) {
                velocity.x += (velocity.x > 0) ? -deceleration : deceleration;
            }else{
                velocity.x = 0;
            }
        }
        //Gravity
        if (position.y > 500) {
            position.y = 500;
            velocity.y = 0;
            airJumps = 0;
        }else{
            velocity = velocity.add(new Vector2(0, gravity));
        }

        // Cap velocity add speed and apply
        velocity.x = Math.min(Math.abs(velocity.x), speed) * (velocity.x > 0 ? 1 : -1);
        position = position.add(velocity);

        if (position.y > 500) {
            position.y = 500;
            velocity.y = 0;
            airJumps = 0;
        }
    }

    public function attemptJump() {
        if (airJumps < maxJumps) {
            airJumps++;

            velocity.y = -jumpAcceleration;
        }
    }
    public function render(g:kha.graphics2.Graphics) {
        g.color = kha.Color.Red;
        g.fillRect(position.x, position.y, 10, 20);
        g.color = kha.Color.White;
    }
}