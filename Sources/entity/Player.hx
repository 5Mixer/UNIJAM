package entity;

import rendering.RenderPass;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
import entity.soul.Soul;

using spriterkha.SpriterG2;

class Player extends Entity {
	public var velocity:Vector2;

	var size:Vector2;

	var airJumps = 0;

	public var maxJumps = 2;

	var speed = 6;
	var acceleration = 1.5;
	var deceleration = .8;
	var jumpAcceleration = 10;
	var gravity = .8;

	var entity:EntityInstance;
	var imageSheet:ImageSheet;
    var animation = "idle";

    public var soul: Soul = null;
    public var soulSelection = "";
    public var chestOffset = new Vector2(-50, -100); // offset from player position to get chest
    
    var scale = .25;

    var facingRight = true;

	override public function new(maskControlPass:rendering.RenderPass, imageSheet:ImageSheet, spriter:Spriter) {
		super();

		position = new Vector2(100, 100);
		velocity = new Vector2();
        size = new Vector2(250*scale, 480*scale);
        
		maskControlPass.registerRenderer(renderMask);
        entity = spriter.createEntity("player");
        this.imageSheet = imageSheet;
        entity.speed = .5;
	}

	override public function update(input:Input, level:Level) {
		entity.step(1/60);

		// Left/right change horizontal velocity
		if (input.left) {
			velocity = velocity.add(new Vector2(-acceleration, 0));
            facingRight = false;
		}
		if (input.right) {
            velocity = velocity.add(new Vector2(acceleration, 0));
            facingRight = true;
		}

		// Decelerate on no input
		if (!input.left && !input.right) {
			if (Math.abs(velocity.x) > deceleration) {
				velocity.x += (velocity.x > 0) ? -deceleration : deceleration;
			} else {
				velocity.x = 0;
			}
		}
		// Gravity
		var collide = resolveCollisions(level.colliders);
		if (!collide) {
			velocity = velocity.add(new Vector2(0, gravity));
		}

		// Cap velocity add speed and apply
		velocity.x = Math.min(Math.abs(velocity.x), speed) * (velocity.x > 0 ? 1 : -1);
		position = position.add(velocity);

		resolveCollisions(level.colliders);

		if (Math.abs(velocity.x) < 2 && animation != "idle") {
			entity.transition("idle", .1);
            animation = "idle";
        } else if (Math.abs(velocity.x) > 2 && animation != "run") {
            entity.transition("run", .1);
            animation = "run";
        }
        // Soul spawn/updating
        if (soul == null && soulSelection != "" && input.leftMouseDown) {
            // spawn
            spawnSoul(input, level);
        }
        if (soul != null && !soul.isActive()) {
            soul = null;
        }
        if (soul != null) {
            soul.update(input, level);
        }
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

	override public function render(g:kha.graphics2.Graphics) {
		// var debug = false;
		// if (debug)

        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (facingRight ? -size.x / 2 : size.x / 2), position.y-size.y))
			.multmat(kha.math.FastMatrix3.scale(scale * (facingRight ? 1 : -1), scale)));
		g.color = kha.Color.White;
        // g.drawRect(0, 0, size.x, size.y);

        g.popTransformation();
        if (soul != null) soul.render(g);
	}

	public function renderMask(pass:RenderPass) {
		var g = pass.passImage.g2;

        // g.fillRect(position.x - size.x/2, position.y - size.y, size.x, size.y);
		g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (facingRight ? -size.x / 2 : size.x / 2), position.y-size.y))
			.multmat(kha.math.FastMatrix3.scale(scale * (facingRight ? 1 : -1), scale)));
        g.color = kha.Color.White;
		g.drawSpriter(imageSheet, entity, 0, 0);

        g.popTransformation();

    }
    
    public function changeSoulTo(selection: String) {
        this.soulSelection = selection;
    }
    
    public function spawnSoul(input: Input, level: Level) {
        if (soul != null) {
            soul.deactivate();
            soul = null;
        }
        if (soulSelection == "dagger") {
			soul = new entity.soul.Dagger(
                this.position.add(chestOffset)
            );
            soul.thrower = this;
            soul.targetPosition = input.getMousePosition();
		} else if (soulSelection == "axe") {
			soul = new entity.soul.Axe(
                this.position.add(chestOffset),
                input.getMousePosition().sub(this.position.add(chestOffset))
            );
            soul.thrower = this;
		}
    }
}