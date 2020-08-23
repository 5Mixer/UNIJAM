package entity;

import kha.graphics2.Graphics;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
import differ.shapes.Polygon;
import differ.shapes.Shape;
using spriterkha.SpriterG2;

enum WolfState {
    Idle;
    Charge;
    Retreat;
}

class Wolf extends Entity {
    public var state:WolfState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var origin = new Vector2(250, 200);
    
    var entity:EntityInstance;
    var imageSheet:ImageSheet;
    
	var velocity:Vector2;
    var gravity = .8;
    
    var life = 0;
    var scale = .25;
    var size:Vector2;
    var speed = 5;

    var animation = "run";

    var runningRight = false;
    
    override public function new(imageSheet:ImageSheet, spriter:Spriter, position:Vector2) {
        super();
        this.position = position.mult(1);
        velocity = new Vector2();
        size = new Vector2(500*scale,450*scale);

        entity = spriter.createEntity("enemy1");
        entity.play("run");
        entity.speed = 1.6;
        this.imageSheet = imageSheet;
    }
    
    override public function update(input:Input, level:Level) {
        entity.step(1/60);
        life++;

        velocity.x = runningRight ? speed:-speed;

		var collide = resolveCollisions(level.colliders);
		if (!collide) {
			velocity = velocity.add(new Vector2(0, gravity));
		}
        position = position.add(velocity);
        
        if (Math.abs(velocity.x) > .2 && animation != "run") {
            entity.play("run");
            animation = "run";
            entity.speed = 1;
        }
        if (Math.abs(velocity.x) <= .2 && animation != "idle") {
            // entity.play("idle");
            entity.play("run");
            entity.speed = 0;
            animation = "idle";
        }

		resolveCollisions(level.colliders);
    }
    function getCollider() {
        return Polygon.rectangle(position.x - (size.x * .5) + velocity.x, position.y - (size.y) + velocity.y, size.x, size.y, false);
    }
    function resolveCollisions(geometry:Array<differ.shapes.Shape>) {
        var collides = false;
        var collider = getCollider();
		for (shape in geometry) {
			var potentialCollision = shape.testPolygon(collider);
			if (potentialCollision != null) {
                collides = true;
                if (Math.abs(potentialCollision.separationX) > .1) {
                    runningRight = !runningRight;
                }
				velocity.x -= potentialCollision.separationX;
				velocity.y -= potentialCollision.separationY;
			}
		}
		return collides;
	}
    override public function render(g:Graphics) {
        var facingRight = runningRight;
		g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (facingRight ? size.x / 2 : -size.x / 2), position.y-size.y))
			.multmat(kha.math.FastMatrix3.scale(scale * (facingRight ? -1 : 1), scale)));
        // g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (-size.x / 2), position.y-size.y))
        // .multmat(kha.math.FastMatrix3.scale(scale, scale)));
        g.color = kha.Color.White;
        g.drawSpriter(imageSheet, entity, 0, 0);
        g.popTransformation();
    }
}