package entity;

import kha.math.FastMatrix3;
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
	// public var walkChannel: AudioChannel;

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
    public var soulSelection = "dagger";
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
		if (input.rightMouseDown && soul != null && soul.isActive()) {
			velocity = soul.position.sub(position).mult(.1);
		}

		var prevCount = times.filter(function(a){ return a > (entity.progress - 1/30)%1;}).length;
		var count = times.filter(function(a){ return a > entity.progress;}).length;
		if (count != prevCount && onGround && (input.left || input.right)) {
			// walkChannel.play();
			
			var sounds = [Assets.sounds.footstep05, Assets.sounds.footstep04, Assets.sounds.footstep06];
			var walkChannel = Audio.play(sounds[Math.floor(Math.random() * sounds.length)], false);
			walkChannel.volume = .1+Math.random()*.1;
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
			var jumps = [Assets.sounds.jump1, Assets.sounds.jump2, Assets.sounds.jump3 ];
			var jump = Audio.play(jumps[Math.floor(Math.random() * jumps.length)], false);
			jump.volume = .1 + Math.random() * .1;
			jump.play();
		}
	}

	override public function render(g:kha.graphics2.Graphics) {
        g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(position.x + (facingRight ? -size.x / 2 : size.x / 2), position.y-size.y))
			.multmat(kha.math.FastMatrix3.scale(scale * (facingRight ? 1 : -1), scale)));
		g.color = kha.Color.White;
		// g.drawRect(0, 0, size.x, size.y);

        g.popTransformation();
		if (soul != null){
			// Draw link
			var from = new Vector2(position.x, position.y-size.y*.7);
			var to = new Vector2(soul.position.x+30., soul.position.y+30);

			var length = to.sub(from).length;
			var angle = Math.atan2(to.y - from.y, to.x - from.x);

			g.pushTransformation(
				g.transformation.multmat(
					FastMatrix3.translation(from.x, from.y)
				).multmat(FastMatrix3.rotation(angle)).multmat(
					FastMatrix3.translation(-from.x, -from.y)
				)
			);
			g.color = kha.Color.fromFloats(.2,.2,.2,1);
			g.drawScaledImage(kha.Assets.images.link, from.x, from.y-5, length, 20);
			g.color = kha.Color.fromFloats(.8,.8,.8,1);
			g.drawScaledImage(kha.Assets.images.link, from.x, from.y, length, 10);
			g.popTransformation();
			
			soul.render(g);
		}
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

		if (soul != null){
			// Draw link
			var from = new Vector2(position.x, position.y-size.y*.7);
			var to = new Vector2(soul.position.x+30., soul.position.y+30);

			var length = to.sub(from).length;
			var angle = Math.atan2(to.y - from.y, to.x - from.x);

			g.pushTransformation(
				g.transformation.multmat(
					FastMatrix3.translation(from.x, from.y)
				).multmat(FastMatrix3.rotation(angle)).multmat(
					FastMatrix3.translation(-from.x, -from.y)
				)
			);
			g.color = kha.Color.fromFloats(.2,.2,.2,1);
			g.drawScaledImage(kha.Assets.images.link, from.x, from.y-5, length, 20);
			g.color = kha.Color.fromFloats(.8,.8,.8,1);
			g.drawScaledImage(kha.Assets.images.link, from.x, from.y, length, 10);
			g.popTransformation();
	}

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
		} else if (soulSelection == "shuriken") {
			soul = new entity.soul.Axe(
                this.position.add(chestOffset),
                input.getMousePosition().sub(this.position.add(chestOffset))
            );
            soul.thrower = this;
		}
    }
}