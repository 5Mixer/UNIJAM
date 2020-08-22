package entity.soul;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.FastMatrix3;

enum DaggerState {
    Attack;
    AttackIdle;
    Retract;
    Inactive;
}

class Dagger extends Soul {
    public var state = Attack;

    // attack dimensions
    var baseSpeed = 25;

    // 50% ratio
    var scaledSize = new Vector2(60, 80);
    var centerRotationOffset = new Vector2(30, 40);

    var angle: Float = 0;

    override public function new(position: Vector2) {
        super(position);
        trace("Dagger spawn");
        // TWEAK THEN APPLY TO RENDER()
    }

    function transitionTo(newState: DaggerState, newTarget: Vector2) {
        state = newState;
        targetPosition = newTarget;
    }

    override public function update(input:Input, level:Level) {
        super.update(input, level); // parses mouse position

        // ORDER IMPORTANT
        // transition into idle
        if (position.sub(targetPosition).length < 20) {
            if (state == Attack) {
                transitionTo(AttackIdle, position);
            } else if (state == Retract) {
                // FLAG FOR DESPAWN
                deactivate();
            }
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
        trace("Dagger will die");
        state = Inactive;
    }

    function shootToTarget() {
        // calibrate angle
        var direction = targetPosition.sub(position).normalized();
        angle = Math.atan2(direction.x, -direction.y);
        position = position.add(direction.mult(baseSpeed));    
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
		g.popTransformation();
    }
}