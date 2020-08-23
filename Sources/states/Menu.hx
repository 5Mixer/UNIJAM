package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

class Menu extends State {
    override public function render(g:Graphics) {
        g.clear(Color.fromBytes(87, 63, 76));
        g.color = Color.White;
        g.fontSize = 60;
        g.font = Assets.fonts.FrederickatheGreat_Regular;
        g.drawString("Unijam", 200, 200);
        g.fontSize = 80;
        g.drawString("Soulink", 210, 280);
        g.fontSize = 30;
        g.drawString("By Callum, Daniel, and Jordan.", 230, 380);
    }
    override public function update(input:Input) {
        if (input.leftMouseDown) {
            Main.overlay.startTransition();
            Main.overlay.callback = function() {
                Main.overlay.callback = null;
                Main.overlay.endTransition();
                // Main.state = new Play(input);
                Main.state = new states.CutScene();
            }
        }
    }
}