package ;

import differ.shapes.Polygon;
import differ.sat.SAT2D;
import differ.shapes.Shape;
import kha.math.Vector2;

class Player {
    public var position:Vector2;
    public var velocity:Vector2;

    var airJumps = 0;
    public var maxJumps = 2;

    var speed = 8;
    var acceleration = 1.5;
    var deceleration = .8;
    var jumpAcceleration = 10;
    var gravity = .8;

    // var worldGeom = Polygon.rectangle(0, 450, 500, 40);
    var worldGeom = [Polygon.create(100, 850, 45, 500), Polygon.create(800, 850, 45, 500), Polygon.rectangle(800, 350, 500, 5)];
    public function new() {
        position = new Vector2(100, 100);
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

        // var potentialCollision = worldGeom.testPolygon(Polygon.rectangle(position.x,position.y+velocity.y,10,20,false));
        // if (potentialCollision == null) {
        //     velocity = velocity.add(new Vector2(0, gravity));
        // }
        var collide = resolveCollisions();
        if (!collide) {
            velocity = velocity.add(new Vector2(0, gravity));
        }

        // if (position.y > 500) {
        //     position.y = 500;
        //     velocity.y = 0;
        //     airJumps = 0;
        // }else{
        //     velocity = velocity.add(new Vector2(0, gravity));
        // }

        // Cap velocity add speed and apply
        velocity.x = Math.min(Math.abs(velocity.x), speed) * (velocity.x > 0 ? 1 : -1);
        position = position.add(velocity);

        resolveCollisions();
        // if (position.y > 500) {
        //     position.y = 500;
        //     velocity.y = 0;
        //     airJumps = 0;
        // }
    }
    function resolveCollisions() {
        var collides = false;
        for (shape in worldGeom) {
            var collision = shape.testPolygon(Polygon.rectangle(position.x,position.y,10,20,false));
            var potentialCollision = shape.testPolygon(Polygon.rectangle(position.x+velocity.x,position.y+velocity.y,10,20,false));
            // if (collision != null) {
            //     position.x += collision.separationX;
            //     position.y += collision.separationY;
            //     airJumps = 0;
            // }
            if (potentialCollision != null) {
                collides = true;
                velocity.x -= potentialCollision.separationX;
                velocity.y -= potentialCollision.separationY;
                airJumps = 0;
            }
        }
        return collides;
    }

    public function attemptJump() {
        if (airJumps < maxJumps) {
            airJumps++;

            velocity.y = -jumpAcceleration;
        }
    }
    public function render(g:kha.graphics2.Graphics) {
        g.color = kha.Color.Magenta;
        var lastPoint = null;
        for (shape in worldGeom) {
            for (point in shape.transformedVertices) {
                if (lastPoint == null) {
                    lastPoint = point;
                    continue;
                }
                g.drawLine(lastPoint.x, lastPoint.y, point.x, point.y);
                lastPoint = point;
            }
            g.color = kha.Color.Red;
            g.fillRect(position.x, position.y, 10, 20);
            g.color = kha.Color.White;
        }
    }
}