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
	var camera:Camera;

	function new() {
		System.start({title: "Unijam", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(onLoad);
		});
	}
	function onLoad() {
		input = new Input();
		camera = new Camera();
		player = new Player();
		layer = new Layer();
		input.onJump = function() { player.attemptJump(); };

		Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
		System.notifyOnFrames(function (frames) { render(frames[0]); });
	}
	function update(): Void {
		player.update(input);
		layer.update();

		camera.position.x = player.position.x - kha.Window.get(0).width/2;
	}

	function render(framebuffer: Framebuffer): Void {
		final g2 = framebuffer.g2;
		g2.begin();
		camera.transform(g2);
		layer.render(g2);
		player.render(g2);
		camera.reset(g2);
		g2.end();
	}

	public static function main() {
		new Main();
	}
}
