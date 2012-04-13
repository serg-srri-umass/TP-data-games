/**
 * Constructor for a "Log" object
 * 
 * // TODO update
 * @param weight The weight of the log - normal/heavy
 */
var Log = function(index, weight, direction) {
  this.weight = weight;
  this.direction = direction;

  if(this.weight === "heavy") {
    this.height = 45;
  }else{
    this.height = 35;
  }

  // Generate a random width for the log. TODO - base this on segment
  this.width = 210 + Math.floor(Math.random() * 230);
  this.x = 50 + Math.floor(Math.random() * 51);
  this.y = 75 * index + 40;
  this.active = true;

  // Placeholder for the Raphael element for the log
  this.el = null;

  // Placeholder for the DOM element to render the log shadow
  this.domEl = null;

  // Placeholder for "log end" image
  this.logEndEl = null;

  this.cuts = [];
  this.currentCut = null;
  this.beingCut = false;
};
  Log.prototype = {
    /**
     * Render a log
     * @return A Raphael path string containing the relative path to render the log
     */
    render: function () {
      // An empty SVG Path
      // Unfortunately the SVG path language is a little tricky to wrap your head around
      // See http://www.w3.org/TR/SVG/paths.html#PathData for detailed info

      var logPath = "";
      var currentPosition = { x: 0, y: 0 }; // Current 'cursor' as we render

      var segmentCount = Math.floor((2 + Math.random()*0.6)*(this.width/200));
      var averageWidth = Math.floor(this.width/segmentCount);

      // Render the left-hand side
      logPath += "l0," + this.height;
      this.logEndEl = context.image('../assets/Log End.png', this.x-6, this.y-1, 12, this.height + 1);
      
      // Render the bottom TODO segmented
      logPath += "l" + this.width + ",0";
      
      // Render the right
      //logPath += "l0,-" + this.height;
      logPath += "s6," + -(this.height/2) + " 0," + -this.height;
      // sx1,y1 x,y

      // Render the top
      logPath += "l-" + this.width + ",0";

      // Add shadow via DOM - better-looking than SVG unfortunately.
      this.domEl = $("<div>").addClass('shadow').css({
      'top': this.y+3,
      'left': this.x+3,
      'width': this.width-6,
      'height': this.height-6
      }).appendTo(DOM.shadows);

      return logPath;
    },

    /**
     * Provide event listeners for mouse events on the logs
     * This needs to happen every time new logs are created
     */
    addEventHandlers: function () {
      var that = this;
      this.el.mouseover(function (e) { that.mouseOver(e); });
      this.el.mousemove(function (e) { that.mouseMove(e); });
      this.el.mouseout(function (e) { that.mouseOut(e); });
    },

    /**
     * Destroy a log and un-render all elements involved
     */
    destroy: function () {
      this.el.remove(); // Remove Raphael log element
      this.logEndEl.remove(); // Remove Raphael log end image element
      this.domEl.remove(); // Remove DOM element (CSS shadow)
    },

    /**
     * Set a given log as active or inactive
     * @param bool True or false
     */
    setActive: function (bool) {
      this.active = bool;
    },

    /**
     * Analyze all cuts on a given log, return object describing them
     */
    analyzeCuts: function () {
      return {

      };
    },

    /**
     * Log mouseover event - potential beginning of a new cut
     */
    mouseOver: function (e) {
      if(!mouseDown || !this.active || this.beingCut) return false;
      var x = e.pageX - canvasEl.offset().left,
          y = e.pageY - canvasEl.offset().top;

      var lastCut = this.cuts[this.cuts.length - 1];

      // If we're trying to cut in the wrong direction, prevent that
      if(lastCut && ( (this.direction === "right" && x < lastCut.initialX) ||
                      (this.direction === "left" && x > lastCut.initialX) ) ) {
        console.log("Can't cut this direction");
        return false;
      }

      this.beingCut = true;

      this.currentCut = new Cut(this, x, y);
    },

    /**
     * Log mousemove event - continuing a cut
     */
    mouseMove: function (e) {
      if(!mouseDown || !this.active || !this.beingCut) return false;
      var x = e.pageX - canvasEl.offset().left,
          y = e.pageY - canvasEl.offset().top;

      var currentCut = this.cuts[this.cuts.length - 1];
      this.currentCut.continue(x, y);
    },

    /**
     * Log mouseout event - ending a cut
     */
    mouseOut: function (e) {
      if(!mouseDown || !this.active || !this.beingCut) return false;
      var x = e.pageX - canvasEl.offset().left,
          y = e.pageY - canvasEl.offset().top;

      // TODO IF successful cut
      this.cuts.push(this.currentCut);
      console.log("adding succesful cut");
      this.currentCut = null;
      this.beingCut = false;

    }
  };