package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

class CutScene extends State {
    var text = [
        "With a bound soul,\n you embark into the demon filled wilderness.",
        "You fall -\n to your doom,\n or the depths below?",
        "After your trials,\n you emerge to a place long forgotten,\n a place long rotted."
    ];
    var time = 0.;
    var complete = false;
    var level = 0;
    var nextState:states.State;
    override public function new(level:Int=0, after:states.State) {
        this.level = level;
        nextState = after;
        super();
    }
    override public function render(g:Graphics) {
        time+=.01;
        g.clear(Color.fromBytes(27, 23, 36));
        g.color = Color.White;
        g.fontSize = 80;
        g.font = Assets.fonts.Caveat_Regular;
        var message = text[level];
        var lines = message.split("\n");
        var i = 0;
        var opacity = time-1;
        for (line in lines) {
            g.color = kha.Color.fromFloats(.9,.9,.9,Math.max(0,Math.min(1,opacity)));
            g.drawString(line, 200+i*30, 200 + i*100);
            i++;
            opacity -= 1;
        }
        if (opacity > 1.3) {
            complete = true;
        }
    }
    override public function update(input:Input) {
        if (complete) {
            Main.overlay.startTransition();
            Main.overlay.callback = function() {
                Main.overlay.callback = null;
                Main.overlay.endTransition();
                Main.state = nextState;
            }
        }
        super.update(input);
    }
}