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
    var worldGeom = [];
    var tiled:Tiled;
    public function new() {
        position = new Vector2(100, 100);
        velocity = new Vector2();
        tiled = new Tiled(kha.Assets.blobs.level1_tmx.toString());
        for (triangle in tiled.entities[0].triangles) {
            var vertices = [];
            for (point in triangle.points)
                vertices.push(new differ.math.Vector(point.x, point.y));

            worldGeom.push(new Polygon(0,0, vertices));
        }
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

        // Cap velocity add speed and apply
        velocity.x = Math.min(Math.abs(velocity.x), speed) * (velocity.x > 0 ? 1 : -1);
        position = position.add(velocity);

        resolveCollisions();
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
        tiled.entities[0].render(g);
        for (shape in worldGeom) {
            g.color = kha.Color.Red;
            g.fillRect(position.x, position.y, 10, 20);
            g.color = kha.Color.White;
        }
    }
}