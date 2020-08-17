package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	public function new() {
		System.start({title: "Unijam", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames[0]); });
			});
		});
	}
	static function update(): Void {
	}

	static function render(framebuffer: Framebuffer): Void {
		final g2 = framebuffer.g2;
		g2.begin();

		g2.end();
	}

	public static function main() {
		new Main();
	}
}
