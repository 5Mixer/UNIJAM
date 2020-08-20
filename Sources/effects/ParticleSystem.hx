package effects;

import kha.Window;
import kha.graphics2.Graphics;
import kha.math.Vector2;
using kha.graphics2.GraphicsExtension;

class Particle {
    public var position:Vector2;
    public var velocity:Vector2;
    public var age:Int = 0;
    public var deathAge:Int = 80;

    public function new() { reset(); }
    public function reset() {
        age = Math.floor(Math.random() * deathAge);
        position = new Vector2(Window.get(0).width * Math.random(), Window.get(0).height * Math.random());
        var angle = Math.random() * Math.PI * 2;
        var speed = 2;
        velocity = new Vector2(speed * Math.cos(angle), speed * Math.sin(angle));
    }
    public function update() {
        age++;
        position = position.add(velocity);
        velocity = velocity.mult(.98);

        if (age > deathAge) {
            reset();
        }
    }
    public function render(g:Graphics) {
        var b = .5 + .5 * (age/deathAge);
        g.color = kha.Color.fromFloats(b*245/255,b*66/255,b*105/255);
        // g.color = kha.Color.fromFloats(b,b,b);
        g.fillCircle(position.x, position.y, 12 - 4*(age/deathAge));
    }
}

class ParticleSystem {
    public var particles:Array<Particle> = [];
    var count = 3000;
    public function new() {
        for (i in 0...count) {
            particles.push(new Particle());
        }
    }
    public function update() {
        for (particle in particles) {
            particle.update();
        }
    }
    public function render(g:Graphics) {
        for (particle in particles) {
            particle.render(g);
        }
    }
}