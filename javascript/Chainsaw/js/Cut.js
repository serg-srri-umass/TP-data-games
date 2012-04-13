var Cut = function(log, x, y) {
  // Whether the cut is currently active (i.e. being cut)
  this.active = true;

  this.log = log;

  // Initial X position of the cut
  this.initialX = x;

  // Determine which direction the log is being cut from
  if(y <= this.log.y + (this.log.height / 2)){
    this.direction = "down";
    // Set initial and final Y positions of the cuts based on this
    this.initialY = log.y;
    this.finalY = log.y + log.height;
  } else {
    this.direction = "up";
    this.initialY = log.y + log.height;
    this.finalY = log.y;
  }

  this.calculatePath();

  // Placeholder for the path of the cut so far
  this.pathSoFar = null;

};

  Cut.prototype = {
    /**
     * Calculate the visual path for the entire, finished cut so that we can
     * calculate sub-paths as the log is gradually cut
     */
    calculatePath: function () {
      this.path = "M" + this.initialX + "," + this.initialY;
      if(this.direction === "down"){
        // A cut from top to bottom
        this.path += "s6," + (this.finalY - this.initialY)/2 + " 0," + this.log.height;
      }else{
        // A cut from bottom to top
        this.path += "s6," + -(this.initialY - this.finalY)/2 + " 0," + -this.log.height;
      }
    },

    /**
     * Continue a cut in progress
     */
    continue: function (x, y) {
      if(Math.abs(this.x - this.initialX) > 50){
        // We've moved too far from the initial point to still be cutting
        this.end();
      }

      var totalLength = Raphael.getTotalLength(this.path);
      var renderedLength = (Math.abs(y - this.initialY)/this.log.height) * totalLength;
      this.pathSoFar = Raphael.getSubpath(this.path, 0, renderedLength);

      this.render();
    },

    /**
     * Render the cut as it stands so far
     */
    render: function () {
      context.path(this.pathSoFar);
    },

    /**
     * Finish a cut, whether due to mouse up, distance too far, etc
     */ 
    end: function () {
      this.active = false;

    }
  }