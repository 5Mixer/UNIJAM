package states;

import js.html.Image;
import entity.Entity;
import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import entity.Player;
import entity.Bat;
import entity.Shielder;
import entity.Wolf;
import effects.ParticleSystem;
import spriter.Spriter;
import imagesheet.ImageSheet;

import kha.Assets;

class Play extends State {
	var player:Player;
	var layer:Layer;
	var level:Level;
	var camera:Camera;
	var input:Input;
	var particleSystems:Array<ParticleSystem> = [];
	
	var enemies:Array<Entity> = [];
	var shielders:Array<Shielder> = [];
	var angle = 0.0;

	var playerTexture:rendering.RenderPass;
	var playerMaskTexture:rendering.RenderPass;
	var playerMask:rendering.MaskPass;
	var renderPasses:Array<rendering.RenderPass> = [];

	var playerTextureParticles:effects.ParticleSystem;

	var imageSheet:ImageSheet;
	var spriter:Spriter;

	var levelNumber:Int;

    override public function new(input, levelNumber=1) {
		super();
		
		this.input = input;
		this.levelNumber = levelNumber;
		
		camera = new Camera();
		input.camera = camera;

		// register render passes
		renderPasses.push(playerTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMaskTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMask = new rendering.MaskPass(camera));

		imageSheet = ImageSheet.fromTexturePackerJsonArray(kha.Assets.blobs.texture_packing_json.toString());
		spriter = Spriter.parseScml(kha.Assets.blobs.animations_scml.toString());
		
		player = new Player(playerMaskTexture, imageSheet, spriter);
		layer = new Layer(camera, levelNumber);
		level = new Level(levelNumber);
		
		for (tiledEntity in level.tiled.entities) {
			var entityPosition = tiledEntity.position.mult(1); // Clone position
			var entity:Entity = switch tiledEntity.type {
				case "bat": new Bat(player, imageSheet, spriter, entityPosition);
				case "shielder": new Shielder(imageSheet, spriter, entityPosition);
				case "wolf": new Wolf(imageSheet, spriter, entityPosition);
				default: null;
			};
			if (tiledEntity.type == "spawn") {
				player.position = entityPosition.mult(1);
				continue;
			}
			if (entity == null) {
				throw "Unexpected entity type loaded";
			}

			if (tiledEntity.type == "shielder") {
				shielders.push(cast entity);
			}

			enemies.push(entity);
		}

		playerTextureParticles = new ParticleSystem(100);

		// connect the render pipeline for player masking
		playerMask.mask = playerMaskTexture.passImage;
		playerMask.image = playerTexture.passImage;

		playerTexture.clearColour = kha.Color.fromFloats(0,0,0,0);
		playerTexture.clear = false;
		playerMaskTexture.clear = true;
		playerMaskTexture.applyCamera = true;
		playerMaskTexture.clearColour = kha.Color.fromFloats(1,1,1,0);
		playerTexture.registerRenderer(function(pass) {
			playerTextureParticles.render(pass.passImage.g2);
		});
		playerTexture.passImage.g2.begin(kha.Color.fromFloats(.4*245/255,.4*66/255,.4*105/255));
		playerTexture.passImage.g2.end();

		// bindings
		input.onJump = function() {
			if (player.airJumps == 0)
				particleSystems.push(new JumpParticleSystem(player.position.mult(1)));
			
			player.attemptJump();
		}
		input.onSoulSummon = function(type: String) { 
			player.changeSoulTo(type); 
		}
		input.restart = die;
		input.onDespawn = function() {player.soul.deactivate();}
	}

	function die() {
		Main.overlay.startTransition();
		Main.overlay.callback = function() {
			Main.overlay.callback = null;
			Main.overlay.endTransition();
			Main.state = new Play(input, levelNumber);
		}
	}
	function nextLevel() {
		Main.overlay.startTransition();
		Main.overlay.callback = function() {
			Main.overlay.callback = null;
			Main.overlay.endTransition();
			Main.state = new Play(input, levelNumber+1);
		}
	}

    override public function update(input:Input) {
		for (system in particleSystems)
			system.update();
		player.update(input, level);
		layer.update();
		for (enemy in enemies) {
			enemy.update(input, level);
		}
		playerTextureParticles.update();

		var playerCollider = player.getCollider();
		for (zone in level.tiled.zones) {
			if (playerCollider.testPolygon(zone.collider) != null) {
				if (zone.type == "death") {
					trace("Death zone");
					particleSystems.push(new DeathParticleSystem(player.position.mult(1)));
					die();
				}
				if (zone.type == "exit") {
					nextLevel();
				}
			}
		}
		
		for (shielder in shielders) {
			var collision = playerCollider.testPolygon(shielder.getShieldCollider());
			if (collision != null) {
				player.velocity.x = collision.separationX > 0 ? 20 : -20;
				player.velocity.y -= 5;
			}
		}
		if (player.soul != null) {
			var soulCollider = player.soul.getCollider();
			for (enemy in enemies) {
				var enemyCollider = enemy.getCollider();
				var collision = (enemyCollider != null) ? soulCollider.testPolygon(enemyCollider) : null;
				if (collision != null) {
					enemies.remove(enemy);
					if (Std.is(enemy, Shielder)) {
						shielders.remove(cast enemy);
					}
				}
			}
		}

		for (enemy in enemies) {
			var enemyCollider = enemy.getCollider();
			var collision = (enemyCollider != null) ? playerCollider.testPolygon(enemyCollider) : null;
			if (collision != null) {
				die();
			}
		}

		camera.position.x = Math.max(0, Math.min(8000 - kha.Window.get(0).width, player.position.x - kha.Window.get(0).width/2));
		camera.position.y = Math.max(0, Math.min(1800 - kha.Window.get(0).height, player.position.y - kha.Window.get(0).height/2));
    }
    override public function prerender() {
		for (pass in renderPasses) {
			pass.pass();
		}
    }
    override public function render(g:Graphics) {
		camera.transform(g);
		layer.render(g);
		for (system in particleSystems)
			system.render(g);
		player.render(g);
		playerMask.render(g);
		for (enemy in enemies)
			enemy.render(g);
	
		camera.reset(g);
			
		var baseIconPosition = new Vector2(40, kha.Window.get(0).height - 160);
		var iconSize = new Vector2(60, 60);
		var weaponIcons = new Map<String, kha.Image>();
		weaponIcons["dagger"] = Assets.images.dagger3;
		weaponIcons["shuriken"] = Assets.images.shuriken;
		var count = 0;
		for (icon in weaponIcons.keys()) {
			g.color = kha.Color.fromFloats(1,1,1,0.5);
			g.fillRect(baseIconPosition.x + count * iconSize.x, baseIconPosition.y, iconSize.x, iconSize.y);
			if (icon == player.soulSelection) {
				g.color = kha.Color.fromFloats(0.5, 0.5, 0.5, 1);
			} else {
				g.color = kha.Color.fromFloats(1,1,1,0.5);
			}
			if (icon == "dagger") {
				g.drawScaledImage(weaponIcons[icon], baseIconPosition.x + (1/8) * iconSize.x, baseIconPosition.y, iconSize.x * (3/4), iconSize.y);
			} else {
				g.drawScaledImage(weaponIcons[icon], baseIconPosition.x + count * iconSize.x, baseIconPosition.y, iconSize.x, iconSize.y);
			}
			// Last thing
			count++;
		}
	}

	function sketch_rotating(g:Graphics, image, angle, point: Vector2, origin: Vector2, size: Vector2) {
		g.pushTransformation(
			g.transformation.multmat(
				FastMatrix3.translation(point.x + origin.x, point.y + origin.y)
			).multmat(FastMatrix3.rotation(angle)).multmat(
				FastMatrix3.translation(-point.x - origin.x, -point.y - origin.y)
			)
		);
		g.drawScaledImage(
			image,
			point.x, point.y,
			size.x, size.y);
		g.popTransformation();
	}
}