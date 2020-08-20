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
        g.drawString("Unijam", 100, 100);
        g.fontSize = 80;
        g.drawString("Skin and Soul", 110, 180);
        g.fontSize = 30;
        g.drawString("By Callum, Daniel, and Jordan.", 130, 280);
    }
}