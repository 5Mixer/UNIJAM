package states;

import kha.graphics2.Graphics;
import entity.Player;
import entity.Bat;
import effects.ParticleSystem;

class Play extends State {
	var player:Player;
	var layer:Layer;
	var level:Level;
    var camera:Camera;
    
    var bat:Bat;

	var playerTexture:rendering.RenderPass;
	var playerMaskTexture:rendering.RenderPass;
	var playerMask:rendering.MaskPass;
	var renderPasses:Array<rendering.RenderPass> = [];

	var playerTextureParticles:effects.ParticleSystem;

    override public function new(input) {
        super();
        
        camera = new Camera();

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
    }
    override public function update(input:Input) {
		player.update(input, level);
        layer.update();
        bat.update(input, level);
        playerTextureParticles.update();
        bat.targetPosition = player.position;

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
        playerMask.render(g);
        bat.render(g);
		camera.reset(g);
		
		/*g.color = kha.Color.Blue;
		g.fillRect(0,0,1300,210);
		g.color = kha.Color.White;
		for (i in 0...renderPasses.length) {
			g.drawScaledImage(renderPasses[i].passImage,400*i,0,390,200);
		}*/
    }
}