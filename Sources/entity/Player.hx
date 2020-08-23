package entity;

import kha.Scheduler;
import differ.shapes.Ray.InfiniteState;
import rendering.RenderPass;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import kha.math.Vector2;
import spriter.Spriter;
import spriter.EntityInstance;
import imagesheet.ImageSheet;
import entity.soul.Soul;

import kha.audio1.Audio;
import kha.audio1.AudioChannel;
import kha.Sound;
import kha.Assets;

using spriterkha.SpriterG2;

class Player extends Entity {
	public var velocity:Vector2;

	var size:Vector2;

	public var airJumps = 0;
	public var walkChannel: AudioChannel;

	public var maxJumps = 2;

	var speed = 6;
	var acceleration = 1.5;
	var deceleration = .8;
	var jumpAcceleration = 13;
	var gravity = .8;

	var entity:EntityInstance;
	var imageSheet:ImageSheet;
    var animation = "idle";

    public var soul: Soul = null;
    public var soulSelection = "";
    public var chestOffset = new Vector2(-50, -100); // offset from player position to get chest
    
    var scale = .25;
	var onGround = false;
	var debug = false;

	var facingRight = true;

	var times = [75/400, 290/400];

	override public function new(maskControlPass:rendering.RenderPass, imageSheet:ImageSheet, spriter:Spriter) {
		super();

		position = new Vector2(100, 100);
		velocity = new Vector2();
        size = new Vector2(250*scale, 480*scale);
        
		maskControlPass.registerRenderer(renderMask);
        entity = spriter.createEntity("player");
        this.imageSheet = imageSheet;
		entity.speed = .5;
		
		walkChannel = Audio.play(Assets.sounds.footstep05, false);
		walkChannel.volume = .3;
		// walkChannel.stop();
	}

    var t = 0;
	override public function update(input:Input, level:Level) {
		t++;

		entity.step(1/60);

        onGround = false;
		for (shape in level.colliders) {
            if (shape.testPolygon(Polygon.rectangle(position.x-(size.x*.5)+velocity.x, position.y+velocity.y, size.x, 25, false)) != null) {
                onGround = true;
            }
        }

		// Left/right change horizontal velocity
		if (input.left) {
			// velocity = velocity.add(new Vector2(-acceleration, 0));
            velocity.x = Math.max(-speed, velocity.x - acceleration);
            facingRight = false;
		}
		if (input.right) {
            velocity.x = Math.min(speed, velocity.x + acceleration);
            facingRight = true;
		}

		var prevCount = times.filter(function(a){ return a > (entity.progress - 1/30)%1;}).length;
		var count = times.filter(function(a){ return a > entity.progress;}).length;
		if (count != prevCount && onGround && (input.left || input.right)) {
			walkChannel.play();
		} else {
			// walkChannel.stop();
		}
		// for (time in times) {
		// 	if (entity.progress > time && entity.progress - 1/60 <= time) {
		// 		// Walking sound
		// 	}
		// }

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
		// velocity.x = Math.min(Math.abs(velocity.x), speed) * (velocity.x > 0 ? 1 : -1);
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

    override public function getCollider() {
        return Polygon.rectangle(position.x - (size.x * .5) + velocity.x, position.y - (size.y) + velocity.y, size.x, size.y, false);
    }

	function resolveCollisions(geometry:Array<differ.shapes.Shape>) {
        var collides = false;
        var collider = getCollider();
		for (shape in geometry) {
			var potentialCollision = shape.testPolygon(collider);
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
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (facingRight ? -size.x / 2 : size.x / 2), position.y-size.y))
			.multmat(kha.math.FastMatrix3.scale(scale * (facingRight ? 1 : -1), scale)));
		g.color = kha.Color.White;
		// g.drawRect(0, 0, size.x, size.y);

        g.popTransformation();
		if (soul != null) soul.render(g);
		if (debug) {
			if (onGround) {
				g.color = kha.Color.Green;
			} else {
				g.color = kha.Color.Red;
			}
			g.fillRect(position.x, position.y, 10, 10);
		}
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