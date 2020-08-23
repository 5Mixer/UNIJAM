package entity;

import differ.shapes.Polygon;
import differ.shapes.Shape;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
using spriterkha.SpriterG2;

enum ShielderState {
    Idle;
    Shield;
    Charge;
}

class Shielder extends Entity {
    public var state:ShielderState = Idle;
    public var targetPosition:Vector2 = new Vector2();
    var targetFollowSpeed = 5;
    var origin = new Vector2(260, 280);
	var velocity:Vector2;
    
    var entity:EntityInstance;
    var imageSheet:ImageSheet;

    var gravity = .8;
    var animation = "idle";

    var scale = .25;
    var size:Vector2;
    
    var life = 0;
    
    override public function new(imageSheet:ImageSheet, spriter:Spriter, position:Vector2) {
        super();
        this.position = position;
        velocity = new Vector2();

        size = new Vector2(500*scale,730*scale);

        entity = spriter.createEntity("enemy3");
        entity.play("idle");
        this.imageSheet = imageSheet;
    }
    
    override public function update(input:Input, level:Level) {
        entity.step(1/60);
        life++;
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
        velocity.x *= .9;
    }
    function resolveCollisions(geometry:Array<differ.shapes.Shape>) {
		var collides = false;
		for (shape in geometry) {
			var potentialCollision = shape.testPolygon(Polygon.rectangle(position.x - (size.x * .5) + velocity.x, position.y - (size.y) + velocity.y, size.x, size.y,
				false));
			if (potentialCollision != null) {
				collides = true;
				velocity.x -= potentialCollision.separationX;
				velocity.y -= potentialCollision.separationY;
			}
		}
		return collides;
	}
    override public function render(g:Graphics) {
        // g.fillRect(position.x-size.x/2,position.y-size.y,size.x,size.y);
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (-size.x / 2), position.y-size.y))
        .multmat(kha.math.FastMatrix3.scale(scale, scale)));
        g.color = kha.Color.White;
        g.drawSpriter(imageSheet, entity, 0, 0);
        
        g.popTransformation();
    }
}