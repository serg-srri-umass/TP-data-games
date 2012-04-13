/**
 * A super-simple particle generator for Raphael
 * @author: Dylan Pyle
 */


/** Array Remove - By John Resig (MIT Licensed) */
Array.prototype.remove = function (from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

/** A particle */
var Particle = function (x, y, paper, settings) {
  this.settings = settings;
  this.x = x;
  this.y = y;
  this.velX = (Math.random() * this.settings.spread * 2) - this.settings.spread;
  this.velY = (Math.random() * this.settings.spread * 2) - this.settings.spread;
  this.life = 0;
  this.raphaelEl = paper.circle(this.x, this.y, this.settings.radius);
  this.raphaelEl.attr({
    'stroke-opacity': 0,
    'fill': this.settings.color
  });
};

Particle.prototype = {
  update: function () {
    this.life++;
    // If we've exceeded lifespan, remove particle
    if (this.life > this.settings.lifespan) {
      this.destroy();
      return false;
    } else {
      // Update position and push to raphael
      this.velX *= this.settings.drag;
      this.velY *= this.settings.drag;
      this.velY += this.settings.gravity;
      this.x += this.velX;
      this.y += this.velY;
      this.raphaelEl.attr({
        'cx': this.x,
        'cy': this.y
      });
      return true;
    }
  },
  destroy: function () {
    this.raphaelEl.remove();
  }
};

/**
 * Particle generator
 * @param canvasEl The Raphael paper to draw particles upon
 */
var Sparks = function (paper) {
  /** Default particle settings. These can be changed on-the-fly without modifying this file. */
  this.settings = {
    color: '#ffe1c1', // Particle color
    radius: 1.2,      // Particle radius
    gravity: 1,       // Particle gravity (added to y-velocity)
    drag: 0.9,        // Drag / "friction" factor (between 0 and 1)
    spread: 5,        // Spread factor (max initial velocity)
    lifespan: 100     // Number of loops to exist for
  };
  this.paper = paper;
  this.particles = [];

  /** Maximum visible particles */
  this.maxParticles = 60;

  /** Starting position */
  this.xPos = 0;
  this.yPos = 0;

  /** Timer placeholder */
  this.timer = null;

  /** Whether or not to generate particles */
  this.generating = false;
};

Sparks.prototype = {
  /** Start particle generation (i.e. cut begins) */
  start: function () {
    this.generating = true;
    if (!this.timer) {
      this.timer = setInterval(function () { this.loop(); }.bind(this), 1000 / 20);
    }

  },

  /** Stop particle generation (i.e. cut ends) */
  stop: function () {
    this.generating = false;
  },

  /**
   * Create some particles
   * @param n Number of particles to generate
   */
  createParticles: function (n) {
    var i, p;
    for (i = 0; i < n; i++) {
      p = new Particle(this.xPos, this.yPos, this.paper, this.settings);
      this.particles.push(p);
    }
  },

  /** Loop through particles, update positions */
  loop: function () {
    var i;

    if (this.generating) {
      this.createParticles(4);
    }

    for (i = 0; i < this.particles.length; i++) {
      if (!this.particles[i].update()) { // Particle is dead
        this.particles.remove(i);
      }
    }

    while (this.particles.length > this.maxParticles && this.particles.length > 0) {
      this.particles.shift().destroy();
    }

    if (this.particles.length === 0) {
      clearInterval(this.timer);
    }

  },

  /** Update Particle spawn position */
  move: function (x, y) {
    this.xPos = x;
    this.yPos = y;
  }
};

