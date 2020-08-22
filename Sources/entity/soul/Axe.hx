package entity.soul;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.FastMatrix3;

enum AxeState {
    Thrown;
    Retract;
    Inactive;
}

class Axe extends Soul {
    public var state = Thrown;

    // float dimensions
    var throwSpeed = 35;
    var throwDampening = 0.995;
    var retractSpeed = 40;

    // Prevent instant recall of axe with minor time lag to button listen
    var t = 0;

    // 50% ratio
    var scaledSize = new Vector2(60, 60);
    var centerRotationOffset = new Vector2(30, 30);

    // Rotation params
    var angularVelocity = Math.PI / (2 * 8);
    var angle = 0.0;    

    // freefall dimensions
    public var velocity: Vector2;
    var gravityAcceleration = new Vector2(0,1.5);

    override public function new(position: Vector2, direction: Vector2) {
        super(position);
        trace("Axe spawn");
        // EDIT
        velocity = direction.normalized().mult(throwSpeed);
    }

    function transitionTo(newState: AxeState) {
        state = newState;
    }

    override public function update(input:Input, level:Level) {
        super.update(input, level); // parses mouse position
        t++; // quickfix to avoid insta-return
        angle = angle + angularVelocity;
        // ORDER IMPORTANT
        // transition into idle
        if (state == Retract) {
            if (position.sub(targetPosition).length < 50) {
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
            retract();
        }
    }

    override public function isActive() {
        return state != Inactive;
    }

    override public function deactivate() {
        state = Inactive;
        trace("Axe will die");
    }

    function freefall() {
        velocity = velocity.add(gravityAcceleration).mult(throwDampening);
        position = position.add(velocity);
    }

    function retract() {
        position = position.add(
            targetPosition.sub(position).normalized().mult(retractSpeed)
        );
    }

    override public function render(g:Graphics) {
        if (state != Inactive) {
            g.color = kha.Color.Green;
            // Need to offset for center of sword
            if (state == Retract) {
                g.drawScaledImage(Assets.images.axe, position.x, position.y, 60, 60);
            } else if (state == Thrown) {
                renderRotation(g);
            }
            g.color = kha.Color.White;
        }
    }

    function renderRotation(g: Graphics) {
        var point = position.sub(centerRotationOffset);
        var translation = position.add(centerRotationOffset);
        g.pushTransformation(
			g.transformation.multmat(
				FastMatrix3.translation(translation.x, translation.y)
			).multmat(FastMatrix3.rotation(angle)).multmat(
				FastMatrix3.translation(-translation.x, -translation.y)
			)
		);
		g.drawScaledImage(
			Assets.images.axe,
			point.x, point.y,
			scaledSize.x, scaledSize.y);
		g.popTransformation();
    }
}