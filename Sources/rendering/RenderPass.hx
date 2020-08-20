package rendering;

import kha.Color;
import kha.Image;

// An abstraction of g2 as a render pass, facilitating more complex render pipelines
class RenderPass {
    var drawers:Array<(pass:RenderPass)->Void> = [];
    public var passImage:Image;
    public var clearColour:kha.Color = kha.Color.fromFloats(1,1,1,0);
    public var clear = true;
    public function new() {
        passImage = Image.createRenderTarget(kha.Window.get(0).width, kha.Window.get(0).height);
    }
    public function pass() {
        passImage.g2.begin(clear, kha.Color.fromBytes(0,0,0,0));
        passImage.g2.color = clearColour;
        passImage.g2.fillRect(0,0,kha.Window.get(0).width, kha.Window.get(0).height);
        passImage.g2.color = Color.White;
        for (drawer in drawers) {
            drawer(this);
        }
        passImage.g2.end();
    }
    public function registerRenderer(renderer:(pass:RenderPass)->Void) {
        drawers.push(renderer);
    }
    public function render(g:kha.graphics2.Graphics) {
        g.pushTransformation(kha.math.FastMatrix3.identity());
        g.drawImage(passImage, 0, 0);
        g.popTransformation();
    }
}