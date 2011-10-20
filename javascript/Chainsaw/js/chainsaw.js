window.Chainsaw = (function(){
  function Chainsaw(canvasEl){ // constructor
    this.canvasEl = canvasEl;
    this.paper = Raphael(canvasEl[0], 600, 330); // initiate Raphael
    document.onselectstart = function () { return false; };
  
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
      initial: 100, // You start with this much
      current: 100,
      timer: null
    };

    

    this.ui = {
      cutDownArrow: null,
      cutEdgeLabel1: null,
      cutEdgeLabel2: null,
      levelLabel: null,
      fuelTank: $('#fuel #tank #contents'),
      startButton: $("#startButton").click(function(){
        this.startGame();
      }.bind(this)),
      stopButton: $("#stopButton").click(function(){
        this.endGame();
      }.bind(this)),
      changeLevelButton: $("#changeLevel").click(function(){
        this.levelSelect.container.fadeIn(200);
      }.bind(this)),

      acceptedCuts: $("#accepted")
    }

    var self = this;
    this.levelSelect = {
      container: $('#overlay'),
      buttons: $('#levelselect input[type=button]').click(function(){
        self.selectLevel(this.dataset.level);
      })
    }
      
    

    this.generateLogs();

  };

  Chainsaw.prototype.selectLevel = function(level){
    this.game.level = level;
    this.levelSelect.container.fadeOut(200);
  }

  Chainsaw.prototype.startGame = function(){
    this.fuel.current = this.fuel.initial;
    this.fuel.timer = setInterval(function(){ this.timerStep(); }.bind(this), 200);
    this.game.inProgress = true;
    this.generateLogs();
    this.ui.acceptedCuts.html('0');
    this.canvasEl.addClass('active');

  };

  Chainsaw.prototype.timerStep = function(){
    console.log(this);
    this.fuel.current = this.fuel.current - 1.4;
    this.ui.fuelTank.height(this.fuel.current);
    if(this.fuel.current <= 0){
      this.endGame(); 
    }
  }

  Chainsaw.prototype.endGame = function(){
    if(!this.game.inProgress){ return false; }
    clearInterval(this.fuel.timer);
    this.game.inProgress = false;
    this.analyzeCuts();
    this.canvasEl.removeClass('active');

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
        active: (i == 0) ? true : false,
        direction: (i % 2 == 0) ? 'right' : 'left',
        lastCut: (i % 2 == 0) ? 0 : randomWidth,
        cutSurface: null
      });

      // Add the end of each log as a 'cut'
      this.logs.list[i].cuts.push(this.logs.list[i].width + this.logs.list[i].x);
    }

    this.renderLogs();
    
  };
  
  Chainsaw.prototype.renderLogs = function(){

    this.paper.clear();

    var svgLogs = this.paper.set(); // A Raphael set of the log elements

    // Loop through the logs
    $.each(this.logs.list, function(i,log){

      // Create SVG elements
      svgLogs.push(this.paper.rect(log.x, log.y, log.width, log.height));

      log.cutSurface = this.paper.rect(log.x, log.y, log.width, 5).mouseover(function(e){
        this.tryCut(e);
      }.bind(this)).attr({ fill: '#764d13' });
      if(!log.active){ log.cutSurface.hide(); }

    }.bind(this));

    svgLogs.attr({ fill: this.logs.color });

    this.ui.cutDownArrow = this.paper.image("assets/Down\ Arrow\ Small.png", 0, 0, 20, 33)
                                     .attr({ x: this.logs.list[0].x-10, y: this.logs.list[0].y-33});
    
  };

  // this function handles mouse movement over the cutting area
  Chainsaw.prototype.tryCut = function(e){
    if(e.which != 1 || !this.game.inProgress){ return null; } // We only care if the mouse is down and the game is in progress

    var x = e.offsetX,
        y = e.offsetY;
         
    $.each(this.logs.list, function(i,log){
      if(x > log.x && x < (log.x + log.width) && y > log.y-5 && y < log.y + 15 && log.active){ // Fits within a cut boundary

        if((log.direction == 'right' && x < log.lastCut) ||
           (log.direction == 'left' && x > log.lastCut)){
          console.log("Invalid cut direction");
          return false; // You're cutting in the wrong direction
        }

        // It' a cut!
        this.paper.rect(x, log.y+5, 2, 30)
                  .attr({ fill: 'white', 'stroke-width': 0});

        log.cuts.push(x);
        log.lastCut = x;

        this.ui.cutDownArrow.attr({x: x-10, y: log.y-33});

        // Now let's see if it's time to move to the next log
        if(this.game.level != 'free' && i != this.logs.count - 1){
          if((log.direction == 'right' && (log.x + log.width - x) < 80) ||
             (log.direction == 'left' && (x - log.x) < 80)){ // We're getting pretty close to the edge
            log.active = false;
            log.cutSurface.hide();
            this.logs.list[i+1].active = true;
            this.logs.list[i+1].cutSurface.show();
          }
             
        }


      }
    }.bind(this));

  };

  Chainsaw.prototype.analyzeCuts = function(){ // Analyze the cuts made for validity
    var accepted = 0;
    $.each(this.logs.list, function(i, log){ // Loop through each log
      var previousCut = log.x; // First 'cut' is the start of the log

      log.cuts = log.cuts.sort(function(a,b){ return a-b; }); // Sort the cuts in ascending order

      $.each(log.cuts, function(j, cut){
        if(Math.abs((cut - previousCut) - this.referenceLog.length) < this.referenceLog.tolerance){
          // The cut was valid

          this.paper.text((cut+previousCut)/2, log.y + 18, "✓")
                    .attr({ fill: '#00FF00', 'font-size': 16 });

          console.log("Valid cut of length " + (cut-previousCut));
          accepted++; 
          
        }else{ 
          // invalid cut
          this.paper.text((cut+previousCut)/2, log.y + 18, "X")
                    .attr({ fill: 'red', 'font-size': 16});
          console.log("Invalid cut of length " + (cut-previousCut)); 
        }
        previousCut = cut;
      }.bind(this));
    }.bind(this));
    this.ui.acceptedCuts.html(accepted);
  };

  return Chainsaw;
})();

