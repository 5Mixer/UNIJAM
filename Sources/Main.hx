package;

import kha.audio1.Audio;
import kha.audio2.AudioChannel;
import states.State;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	public static var overlay:Overlay;
	var input:Input;
	public static var state:State;
	function new() {
		System.start({title: "Unijam", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(onLoad);
		});
	}
	function onLoad() {
		// create camera
		input = new Input();
		overlay = new Overlay();
		// state = new states.Play(input);
		state = new states.Menu();
		var music = Audio.play(Assets.sounds.ambient, true);
		music.volume = .6;

		Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
		System.notifyOnFrames(function (frames) { render(frames[0]); });
	}
	function update(): Void {
		overlay.update();
		state.update(input);
	}

	function render(framebuffer: Framebuffer): Void {
		final g = framebuffer.g2;
		state.prerender();
		g.begin();
		state.render(g);
		overlay.render(g);
		g.end();
	}

	public static function main() {
		new Main();
	}
}
