window.Chainsaw = (function(){
  function Chainsaw(canvasEl){ // A Constructor
    this.paper = Raphael(canvasEl, 600, 330); // initiate Raphael
  
    // Define some game variables 
    this.game = {
        playerName: 'Player',
        level: 'practice',
        inProgress: true
    };
    
    this.logs = {
      color: '#c09256',
      count: 4,
      list: [] // An array containing info about all the logs
    };

    // The 'ideal log' that you're trying to cut
    this.referenceLog = {
      length: 100,
      tolerance: (1 / 8) * 100
    };

    // The fuel meter
    this.fuel = {
      initial: 40, // You start with this much
      current: 40,
      el: $('#fuel #tank')
    };
    
    var game = this;
    // DOM event handlers - we can move these to a seperate class if desired
    $('#startButton').click(function(){
      game.generateLogs();
    });

    $('#stopButton').click(function(){
      game.analyzeCuts();
    });

    this.generateLogs();

  };
  

  Chainsaw.prototype.generateLogs = function(){
    this.logs.list = []; // Clear the current lgos

    // ... and generate some random ones
    for(var i = 0; i < this.logs.count; i++){
      this.logs.list.push({
        width: 300 + Math.floor(Math.random() * 200),
        height: 35,
        x: 20 + Math.floor(Math.random() * 51),
        y: 60 * i + 50,
        cuts: [],
        active: true
      });

      // Add the end of each log as a 'cut'
      this.logs.list[i].cuts.push(this.logs.list[i].width + this.logs.list[i].x);
    }

    this.renderLogs();
    
  };
  
  Chainsaw.prototype.renderLogs = function(){
    this.paper.clear();
    var svgLogs = this.paper.set(); // A Raphael set of the log elements

    var game = this; // NOT OK. TODO fix this soon with .call
    $.each(this.logs.list, function(i,log){ // loop through logs

      // create SVG element
      svgLogs.push(game.paper.rect(log.x, log.y, log.width, log.height));

      if (log.active) { // Draw 'active' rectangle, give it functionality
        game.paper.rect(log.x, log.y, log.width, 5).mouseover(function(e){
          game.tryCut(e);
        }).attr({ fill: '#764d13' });
      }
    });

    svgLogs.attr({ fill: this.logs.color });
    
  };

  // this function handles mouse movement over the cutting area
  Chainsaw.prototype.tryCut = function(e){
    if(e.which != 1){ return null; } // We only care if the mouse is down

    var x = e.layerX,
        y = e.layerY,
        game = this; // TODO fix this
         
    $.each(this.logs.list, function(i,log){
      if(x > log.x && x < (log.x + log.width) && y > log.y-5 && y < log.y + 15 && log.active){
        // It' a cut!
        game.paper.rect(x, log.y+5, 2, 30)
                  .attr({ fill: 'white', 'stroke-width': 0});

        log.cuts.push(x);

        // Now let's see if it's time to move to the next log
        if(game.game.level != 'free'){}

      }
    });

  };

  Chainsaw.prototype.analyzeCuts = function(){ // Analyze the cuts made for validity
    var game = this;
    $.each(this.logs.list, function(i, log){ // Loop through each log
      var previousCut = log.x; // First 'cut' is the start of the log

      log.cuts = log.cuts.sort(function(a,b){ return a-b; }); // Sort the cuts in ascending order

      $.each(log.cuts, function(j, cut){
        if(Math.abs((cut - previousCut) - game.referenceLog.length) < game.referenceLog.tolerance){
          // The cut was valid
          game.paper.text((cut+previousCut)/2, log.y + 18, ":)").attr({ fill: '#00FF00', 'font-size': 16 });
          console.log("Valid cut of length " + (cut-previousCut)); 
        }else{ // invalid
          game.paper.text((cut+previousCut)/2, log.y + 18, ":(").attr({ fill: 'red', 'font-size': 16});
          console.log("Invalid cut of length " + (cut-previousCut)); 
        }
        previousCut = cut;
      });
    });
  };

  return Chainsaw;
})();

