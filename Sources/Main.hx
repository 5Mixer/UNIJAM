package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var player:Player;
	var input:Input;

	function new() {
		System.start({title: "Unijam", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				input = new Input();
				player = new Player();

				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames[0]); });
			});
		});
	}
	function update(): Void {
		player.update(input);
	}

	function render(framebuffer: Framebuffer): Void {
		final g2 = framebuffer.g2;
		g2.begin();
		player.render(g2);
		g2.end();
	}

	public static function main() {
		new Main();
	}
}
