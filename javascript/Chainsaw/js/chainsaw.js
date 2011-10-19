window.Chainsaw = (function(){
  function Chainsaw(canvasEl){ // constructor
    this.paper = Raphael(canvasEl, 600, 330); // initiate Raphael
  
    // Define some game variables 
    this.game = {
        playerName: 'Player',
        level: 'practice',
        inProgress: false
    };
    
    this.logs = {
      color: '#c09256',
      count: 4,
      list: [] // An array containing info about all the logs
    };

    // The 'ideal log' that you're trying to cut
    this.referenceLog = {
      length: 75,
      tolerance: (1 / 8) * 75
    };

    // The fuel meter
    this.fuel = {
      initial: 40, // You start with this much
      current: 40
    };

    
    var game = this; // TODO fix

    this.ui = {
      cutDownArrow: null,
      cutEdgeLabel1: null,
      cutEdgeLabel2: null,
      levelLabel: null,
      fuelTank: $('#fuel #tank'),
      startButton: $("#startButton").click(function(){
        game.startGame();
      }),
      stopButton: $("#stopButton").click(function(){
        game.endGame();
      }),
      changeLevelButton: $("#changeLevel").click(function(){
        alert("Changed level!"); 
      }),
      acceptedCuts: $("#accepted")
    }
    

    this.generateLogs();

  };

  Chainsaw.prototype.startGame = function(){
    this.game.inProgress = true;
    this.generateLogs();

  };

  Chainsaw.prototype.endGame = function(){
    this.game.inProgress = false;
    this.analyzeCuts();

  };
  

  Chainsaw.prototype.generateLogs = function(){
    this.logs.list = []; // Clear the current lgos

    // ... and generate some random ones
    for(var i = 0; i < this.logs.count; i++){

      var randomWidth = 300 + Math.floor(Math.random() * 200),
          randomX = 20 + Math.floor(Math.random() * 51);

      this.logs.list.push({
        width: randomWidth,
        height: 35,
        x: randomX,
        y: 75 * i + 40,
        cuts: [],
        active: true,
        direction: (i % 2 == 0) ? 'right' : 'left',
        lastCut: (i % 2 == 0) ? 0 : randomWidth
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

    // Loop through the logs
    $.each(this.logs.list, function(i,log){

      // Create SVG elements
      svgLogs.push(game.paper.rect(log.x, log.y, log.width, log.height));

      if (log.active) { // Draw 'active' rectangle, give it functionality
        game.paper.rect(log.x, log.y, log.width, 5).mouseover(function(e){
          game.tryCut(e);
        }).attr({ fill: '#764d13' });
      }

    });

    svgLogs.attr({ fill: this.logs.color });

    this.ui.cutDownArrow = this.paper.image("assets/Down\ Arrow\ Small.png", 0, 0, 20, 33)
                                     .attr({ x: this.logs.list[0].x-10, y: this.logs.list[0].y-33});
    
  };

  // this function handles mouse movement over the cutting area
  Chainsaw.prototype.tryCut = function(e){
    if(e.which != 1 || !this.game.inProgress){ return null; } // We only care if the mouse is down and the game is in progress

    var x = e.layerX,
        y = e.layerY,
        game = this; // TODO fix this
         
    $.each(this.logs.list, function(i,log){
      if(x > log.x && x < (log.x + log.width) && y > log.y-5 && y < log.y + 15 && log.active){ // Fits within a cut boundary

        if((log.direction == 'right' && x < log.lastCut) ||
           (log.direction == 'left' && x > log.lastCut)){
          console.log("Invalid cut direction");
          return false; // You're cutting in the wrong direction
        }

        // It' a cut!
        game.paper.rect(x, log.y+5, 2, 30)
                  .attr({ fill: 'white', 'stroke-width': 0});

        log.cuts.push(x);
        log.lastCut = x;

        game.ui.cutDownArrow.attr({x: x-10, y: log.y-33});

        // Now let's see if it's time to move to the next log
        if(game.game.level != 'free'){
             
        }


      }
    });

  };

  Chainsaw.prototype.analyzeCuts = function(){ // Analyze the cuts made for validity
    var game = this;
    var accepted = 0;
    $.each(this.logs.list, function(i, log){ // Loop through each log
      var previousCut = log.x; // First 'cut' is the start of the log

      log.cuts = log.cuts.sort(function(a,b){ return a-b; }); // Sort the cuts in ascending order

      $.each(log.cuts, function(j, cut){
        if(Math.abs((cut - previousCut) - game.referenceLog.length) < game.referenceLog.tolerance){
          // The cut was valid

          game.paper.text((cut+previousCut)/2, log.y + 18, "✓")
                    .attr({ fill: '#00FF00', 'font-size': 16 });

          console.log("Valid cut of length " + (cut-previousCut));
          accepted++; 
          
        }else{ 
          // invalid cut
          game.paper.text((cut+previousCut)/2, log.y + 18, "X")
                    .attr({ fill: 'red', 'font-size': 16});
          console.log("Invalid cut of length " + (cut-previousCut)); 
        }
        previousCut = cut;
      });
    });
    this.ui.acceptedCuts.html(accepted);
  };

  return Chainsaw;
})();

