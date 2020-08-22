package states;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import entity.Player;
import entity.Bat;
import effects.ParticleSystem;

import kha.Assets;

class Play extends State {
	var player:Player;
	var layer:Layer;
	var level:Level;
    var camera:Camera;
    
	var bat:Bat;
	var angle = 0.0;

	var playerTexture:rendering.RenderPass;
	var playerMaskTexture:rendering.RenderPass;
	var playerMask:rendering.MaskPass;
	var renderPasses:Array<rendering.RenderPass> = [];

	var playerTextureParticles:effects.ParticleSystem;

    override public function new(input) {
        super();
		
		camera = new Camera();
		input.camera = camera;

		// register render passes
		renderPasses.push(playerTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMaskTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMask = new rendering.MaskPass(camera));

		player = new Player(playerMaskTexture);
		layer = new Layer();
        level = new Level();
        
		bat = new entity.Bat();

		playerTextureParticles = new ParticleSystem();

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

		// bindings
		input.onJump = function() { player.attemptJump(); }
		input.onSoulSummon = function(type: String) { 
			player.changeSoulTo(type); 
		}
	}

    override public function update(input:Input) {
		player.update(input, level);
        layer.update();
		bat.update(input, level);
        playerTextureParticles.update();
		bat.targetPosition = player.position;
		// not a good idea - assumes always tracks player

		camera.position.x = player.position.x - kha.Window.get(0).width/2;
	}
    override public function prerender() {
		for (pass in renderPasses) {
			pass.pass();
		}
    }
    override public function render(g:Graphics) {
		camera.transform(g);
		level.render(g);
		layer.render(g);
		player.render(g);
        playerMask.render(g);
		bat.render(g);

		// draw a spinning axe
		angle = angle + Math.PI / (2 * 30);
		// g.drawScaledImage(Assets.images.axe, 300, 600, 60, 60);
		var image = Assets.images.axe;
		var x = 300;
		var y = 450;
		var originX = 30;
		var originY = 30;
		var width = 60;
		var height = 60;

		// Draw references
		g.color = kha.Color.Blue;
		g.drawScaledImage(
			image,
			x,y,
			width, height);
		
		// g.drawScaledSubImage(image, sx, sy, sw, sh, dx, dy, dw, dh);
		sketch_rotating(g, image, angle, 
			new Vector2(x, y), 
			new Vector2(originX, originY), 
			new Vector2(width, height)
		);

		camera.reset(g);
		
		/*g.color = kha.Color.Blue;
		g.fillRect(0,0,1300,210);
		g.color = kha.Color.White;
		for (i in 0...renderPasses.length) {
			g.drawScaledImage(renderPasses[i].passImage,400*i,0,390,200);
		}*/
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