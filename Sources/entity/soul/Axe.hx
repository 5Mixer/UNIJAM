package entity.soul;

import kha.Assets;
import kha.audio1.Audio;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.FastMatrix3;
import differ.shapes.Polygon;
import differ.shapes.Shape;

enum AxeState {
    Thrown;
    Retract;
    Inactive;
}

class Axe extends Soul {
    public var state = Thrown;

    // float dimensions
    var throwSpeed = 35;
    var throwDampening = 1;
    var retractSpeed = 40;
    var debug = false;

    // Prevent instant recall of axe with minor time lag to button listen
    var t = 0;

    // 50% ratio
    var scaledSize = new Vector2(60, 60);
    var centerRotationOffset = new Vector2(30, 30);

    // Rotation params
    var angularVelocityUnit = Math.PI / (2 * 6 * 4);
    var angularVelocity = Math.PI / (2 * 6);
    var angle = -Math.PI / 2;
    var inGround: Bool = false;
    var collisionScale: Float = 0.8;

    // freefall dimensions
    public var velocity: Vector2;
    var gravityAcceleration = new Vector2(0,1.5);

    override public function new(position: Vector2, direction: Vector2) {
        super(position);
        // EDIT
        velocity = direction.normalized().mult(throwSpeed);
        var sounds = [Assets.sounds.shortKnifeSlice, Assets.sounds.knifeSlice];
        var slashChannel = Audio.play(sounds[Math.floor(Math.random() * sounds.length)]);
        slashChannel.volume = .1+Math.random()*.1;
        slashChannel.play();
    }

    function transitionTo(newState: AxeState) {
        state = newState;
    }

    override public function update(input:Input, level:Level) {
        super.update(input, level); // parses mouse position
        t++; // quickfix to avoid insta-return
        var collide = resolveCollisions(level.colliders);

        // Collide-obeying rotational momentum for throws
        if (state == Thrown) {
            if (!collide) {
                angle = angle + angularVelocity;
            } else {
                velocity = new Vector2(0,0);
                angularVelocity = 0;
                inGround = true;
            }
        }
        
        // ORDER IMPORTANT
        // transition into idle
        if (state == Retract) {
            if (position.sub(targetPosition).length < 20) {
                // FLAG FOR DESPAWN
                deactivate();
            }
        } 
        if (state != Retract && t > 20 && input.leftMouseDown) {
            transitionTo(Retract);
            targetPosition = thrower.position.add(thrower.chestOffset);
        }
        if (state == Thrown) {
            freefall();
        }
        if (state == Retract) {
            targetPosition = thrower.position.add(thrower.chestOffset);
            inGround = false;
            retract();
        }
    }

    override public function isActive() {
        return state != Inactive;
    }

    override public function deactivate() {
        state = Inactive;
    }

    function freefall() {
        if (!inGround) {
            velocity = velocity.mult(throwDampening).add(gravityAcceleration);
        }
        position = position.add(velocity);
    }

    function retract() {
        position = position.add(
            targetPosition.sub(position).normalized().mult(retractSpeed)
        );
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

    override public function render(g:Graphics) {
        if (state != Inactive) {
            g.color = kha.Color.fromFloats(.1,.1,.1,1);
            // Need to offset for center of sword
            if (state == Retract) {
                g.drawScaledImage(Assets.images.shuriken, position.x, position.y, scaledSize.x, scaledSize.y);
                if (debug) {
                    g.color = kha.Color.Magenta;
                    var positionCollision = position.add(scaledSize.mult(1-collisionScale).div(2));
                    g.drawRect(positionCollision.x, positionCollision.y, scaledSize.x * collisionScale, scaledSize.y * collisionScale);
                }
            } else if (state == Thrown) {
                renderRotation(g);
            }
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
		g.drawScaledImage(
			Assets.images.shuriken,
			position.x, position.y,
            scaledSize.x, scaledSize.y);
        if (debug) {
            g.color = kha.Color.Magenta;
            var positionCollision = position.add(scaledSize.mult(1-collisionScale).div(2));
            g.drawRect(positionCollision.x, positionCollision.y, scaledSize.x * collisionScale, scaledSize.y * collisionScale);
        }
		g.popTransformation();
    }
}