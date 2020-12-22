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
    var systemPosition:Vector2;
    public var alive = true;

    public function new(systemPosition:Vector2) { this.systemPosition = systemPosition; reset(); }
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
        g.fillCircle(position.x, position.y, 32 - 21*(age/deathAge));
    }
}

enum VerticalParticleType {
    Death;
    Jump;
}
class VerticalParticle extends Particle {
    var resets = 0;
    var type:VerticalParticleType;

    override public function new(systemPosition:Vector2, type:VerticalParticleType) { super(systemPosition); this.type = type; }
    override public function reset() {
        if (resets > 0) {
            alive = false;
            return;
        }
        resets++;

        deathAge = Math.ceil(Math.random() * 10)+5;

        age = 0;
        var centerFactor = Math.pow(Math.random(),2);
        position = new Vector2(systemPosition.x + (Math.random()>.5?-1:1)*(centerFactor)*20, systemPosition.y);
        velocity = new Vector2(0, -1 + Math.random() * -1 - (1-centerFactor)*3);
        if (type == Death && Math.random() > .5) {
            velocity.y *= -1;
        }
        if (type == Death) {
            velocity.y -= 25;
        }
    }
    override public function render(g:Graphics) {
        g.color = type == Jump ? kha.Color.White : kha.Color.Black;
        g.fillRect(position.x, position.y, 4, velocity.y);
    }
}

class ParticleSystem {
    public var particles:Array<Particle> = [];
    public function new(spawnCount) {
        for (i in 0...spawnCount) {
            particles.push(new Particle(new Vector2()));
        }
    }
    public function update() {
        for (particle in particles) {
            if (!particle.alive) {
                particles.remove(particle);
            }else{
                particle.update();
            }
        }
    }
    public function render(g:Graphics) {
        for (particle in particles) {
            particle.render(g);
        }
        g.color = kha.Color.White;
    }
}
class JumpParticleSystem extends ParticleSystem{
    override public function new(position:Vector2) {
        super(0);
        for (i in 0...10) {
            particles.push(new VerticalParticle(position, VerticalParticleType.Jump));
        }
    }
}

class DeathParticleSystem extends ParticleSystem{
    override public function new(position:Vector2) {
        super(0);
        for (i in 0...40) {
            particles.push(new VerticalParticle(position, VerticalParticleType.Death));
        }
    }
}
