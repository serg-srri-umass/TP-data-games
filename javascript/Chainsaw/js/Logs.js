/**
 * Constructor for a collection of Log objects
 */
var Logs = function() {
  // Array to hold created logs
  this.logs = [];
  // Number of logs to generate
  this.logCount = 4;
  // Styling info for the logs
  this.logsAttr = {
    fill: "90-#b17603-#bea379",
    'stroke-width': 2,
    stroke: '#764d13'
  };
}
  Logs.prototype = {
    /**
     * Generate a set of logs
     * @param level The game level
     * @param mode The game mode
     */
    generate: function (level, mode) {
      for(var i = 0; i < this.logCount; ++i){
        var direction = (i % 2 == 0) ? 'right' : 'left';

        // If mixed mode, alternate between heavy and normal logs
        if(mode === "mixed"){
          var logWeight = (i % 2 == 0) ? 'heavy' : 'normal';
        }else{
          var logWeight = mode;
        }

        var log = new Log(i, logWeight, direction);
        this.logs.push(log);

      }

    },

    // Remove all logs from the collection
    clear: function () {
      this.logs.forEach(function(log) {
        log.destroy();
      });
      this.logs = [];
    },

    // Render each log in the collection
    render: function () {
      var that = this;
      // Loop through each log in the collection
      this.logs.forEach(function(log) {
        // Move the starting position to the correct coordinate, then render the rest
        var logPath = "M" + log.x + "," + log.y;
        logPath += log.render();
        log.el = context.path(logPath).attr(that.logsAttr);
        log.logEndEl.toFront();
        log.addEventHandlers();
      });

    }
  };
