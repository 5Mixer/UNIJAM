package entity.soul;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.FastMatrix3;
import differ.shapes.Polygon;
import differ.shapes.Shape;

import kha.audio1.Audio;

enum DaggerState {
    Attack;
    AttackIdle;
    Retract;
    Inactive;
}

class Dagger extends Soul {
    public var state = Attack;

    // attack dimensions
    var baseSpeed = 35;

    // 50% ratio
    var scaledSize = new Vector2(60, 80);
    var centerRotationOffset = new Vector2(30, 40);

    var velocity: Vector2 = new Vector2(0,0);
    var angle: Float = 0;
    var collisionScale: Float = 2/3;
    var debug = false;

    override public function new(position: Vector2) {
        super(position);
        // TWEAK THEN APPLY TO RENDER()
        Audio.play(Assets.sounds.shortKnifeSlice);
    }

    function transitionTo(newState: DaggerState, newTarget: Vector2) {
        state = newState;
        targetPosition = newTarget;
    }

    override public function update(input:Input, level:Level) {
        super.update(input, level); // parses mouse position

        // Collision resolution
        var collide = resolveCollisions(level.colliders);
        var isTargetClose = position.sub(targetPosition).length < 20;

        // ORDER IMPORTANT
        // transition into idle
        if (state == Attack) {
            if (isTargetClose || collide) {
                transitionTo(AttackIdle, position);
            }
        }
        if (state == Retract && isTargetClose) {
            // FLAG FOR DESPAWN
            deactivate();
        } 
        if (input.leftMouseDown && state == AttackIdle) {
            transitionTo(Retract, thrower.position.add(thrower.chestOffset));
        }
        

        if (state == Attack) {
            shootToTarget();
        }
        if (state == AttackIdle) {}
        if (state == Retract) {
            targetPosition = thrower.position.add(thrower.chestOffset);
            shootToTarget(); 
        }
    }

    override public function isActive() {
        return state != Inactive;
    }

    override public function deactivate() {
        state = Inactive;
    }

    function resolveCollisions(geometry:Array<differ.shapes.Shape>) {
		var collides = false;
		for (shape in geometry) {
			var potentialCollision = shape.testPolygon(getCollider());
			if (potentialCollision != null) {
                collides = true;
				velocity.x -= potentialCollision.separationX;
				velocity.y -= potentialCollision.separationY;
			}
		}
		return collides;
    }
    
    override public function getCollider() {
        var collisionSize = scaledSize.mult(collisionScale);
        var positionCollision = position.add(scaledSize.mult(1-collisionScale).div(2));
        return Polygon.rectangle(positionCollision.x, positionCollision.y, collisionSize.x, collisionSize.y,
            false);
    }

    function shootToTarget() {
        // calibrate angle
        var direction = targetPosition.sub(position).normalized();
        angle = Math.atan2(direction.x, -direction.y);
        velocity = direction.mult(baseSpeed);
        position = position.add(velocity);  
    }

    override public function render(g:Graphics) {
        if (state != Inactive) {
            g.color = kha.Color.Purple;
            // Need to offset for center of sword
            renderRotation(g);
            g.color = kha.Color.White;
        }
    }

    function renderRotation(g: Graphics) {
        var translation = position.add(centerRotationOffset);
        g.pushTransformation(
			g.transformation.multmat(
				FastMatrix3.translation(translation.x, translation.y)
			).multmat(FastMatrix3.rotation(angle)).multmat(
				FastMatrix3.translation(-translation.x, -translation.y)
			)
		);
        g.drawScaledImage(Assets.images.dagger3, position.x, position.y, scaledSize.x, scaledSize.y);
        if (debug) {
            g.color = kha.Color.Magenta;
            var positionCollision = position.add(scaledSize.mult(1-collisionScale).div(2));
            g.drawRect(positionCollision.x, positionCollision.y, scaledSize.x * collisionScale, scaledSize.y * collisionScale);
        }
        g.popTransformation();
    }
}