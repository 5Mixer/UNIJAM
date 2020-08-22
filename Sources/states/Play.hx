package states;

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
    
	var bat:Bat;
	var wolf:Wolf;
    var shielder:Shielder;
	var angle = 0.0;

	var playerTexture:rendering.RenderPass;
	var playerMaskTexture:rendering.RenderPass;
	var playerMask:rendering.MaskPass;
	var renderPasses:Array<rendering.RenderPass> = [];

	var playerTextureParticles:effects.ParticleSystem;

	var imageSheet:ImageSheet;
	var spriter:Spriter;

    override public function new(input) {
        super();
		
		camera = new Camera();
		input.camera = camera;

		// register render passes
		renderPasses.push(playerTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMaskTexture = new rendering.RenderPass(camera));
		renderPasses.push(playerMask = new rendering.MaskPass(camera));

		imageSheet = ImageSheet.fromTexturePackerJsonArray(kha.Assets.blobs.texture_packing_json.toString());
		spriter = Spriter.parseScml(kha.Assets.blobs.animations_scml.toString());
		
		player = new Player(playerMaskTexture, imageSheet, spriter);
		layer = new Layer(camera);
        level = new Level();
        
        bat = new entity.Bat(player, imageSheet, spriter);
        // wolf = new entity.Wolf(imageSheet, spriter);
        // shielder = new entity.Shielder(imageSheet, spriter);

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
		input.onDespawn = function() {player.soul.deactivate();}
	}

    override public function update(input:Input) {
		player.update(input, level);
		layer.update();
		// wolf.update(input, level);
		bat.update(input, level);
		// shielder.update(input, level);
        playerTextureParticles.update();

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
		playerMask.render(g);
		player.render(g);
		bat.render(g);
		// wolf.render(g);
		// shielder.render(g);
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