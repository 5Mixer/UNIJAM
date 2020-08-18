package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var player:Player;
	var input:Input;
	var layer:Layer;
	var level:Level;
	var camera:Camera;

	var playerTexture:rendering.RenderPass;
	var playerMaskTexture:rendering.RenderPass;
	var playerMask:rendering.MaskPass;
	var renderPasses:Array<rendering.RenderPass> = [];

	function new() {
		System.start({title: "Unijam", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(onLoad);
		});
	}
	function onLoad() {
		// register render passes
		renderPasses.push(playerTexture = new rendering.RenderPass());
		renderPasses.push(playerMaskTexture = new rendering.RenderPass());
		renderPasses.push(playerMask = new rendering.MaskPass());

		// setup
		input = new Input();
		camera = new Camera();
		player = new Player(playerMaskTexture);
		layer = new Layer();
		level = new Level();

		// connect the render pipeline for player masking
		playerMask.mask = playerMaskTexture.passImage;
		playerMask.image = playerTexture.passImage;
		playerTexture.registerRenderer(function(pass) {
			pass.passImage.g2.clear(kha.Color.Pink);
		});
		playerMaskTexture.registerRenderer(function(pass) {
			// pass.passImage.g2.color = kha.Color.fromBytes(100,0,0,255);
			// pass.passImage.g2.fillRect(0,0,500,1000);
		});

		// bindings
		input.onJump = function() { player.attemptJump(); };

		Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
		System.notifyOnFrames(function (frames) { render(frames[0]); });
	}
	function update(): Void {
		player.update(input, level);
		layer.update();

		camera.position.x = player.position.x - kha.Window.get(0).width/2;
	}

	function render(framebuffer: Framebuffer): Void {
		for (pass in renderPasses) {
			pass.pass();
		}
		final g2 = framebuffer.g2;
		g2.begin();
		camera.transform(g2);
		level.render(g2);
		layer.render(g2);
		playerMask.render(g2);
		camera.reset(g2);
		g2.color = kha.Color.Blue;
		g2.fillRect(0,0,1300,210);
		g2.color = kha.Color.White;
		for (i in 0...renderPasses.length) {
			g2.drawScaledImage(renderPasses[i].passImage,400*i,0,390,200);
		}
		g2.end();
	}

	public static function main() {
		new Main();
	}
}
