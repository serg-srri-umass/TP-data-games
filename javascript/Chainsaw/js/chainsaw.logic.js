var ChainsawLogic = function(){ // Constructor

  console.log("Logic loaded.");

  this.game = {
    playerName: 'Player',
    level: 'practice',
    inProgress: false,
    firstRun: true
  };
  
  this.logs = {
    color: '#c09256',
    count: 4,
    list: [] // An array containing info about all the logs
  };

  this.referenceLog = {
    length: 75,
    tolerance: (1 / 8) * 75
  };

  this.fuel = {
    initial: 100, // You start with this much
    current: 100,
    timer: null
  };

  // Global event listeners
  _bind('startGame', function(){ this.startGame(); }.bind(this));
  _bind('endGame', function(e){ this.endGame(e); }.bind(this));
  _bind('levelSelected', function(e, lvl){ this.levelSelected(lvl); }.bind(this) );
  _bind('handleMouse', function(e, mouse){ this.handleMouse(mouse); }.bind(this) );

};

ChainsawLogic.prototype = { // Functions

  startGame: function(){
    if(this.game.inProgress) return;
    if(!this.game.firstRun) this.generateLogs(); // New logs for a new game
    this.game.inProgress = true;
    this.fuel.current = this.fuel.initial;
    if(this.game.level != 'practice') this.fuel.timer = setInterval(function(){ this.timerStep(); }.bind(this), 100);

    console.log("Game started");

  },

  timerStep: function(){
    this.fuel.current = this.fuel.current - 0.7;
    _trigger('updateFuel', [this.fuel.current]);
    if(this.fuel.current <= 0){
      this.endGame(); 
    }

  },

  levelSelected: function(level){
    this.game.level = level;
    this.game.firstRun = true;
    this.generateLogs();
  },

  generateLogs: function(){
    this.logs.list = [];
    _trigger('clear'); 
    
    for(var i = 0; i < this.logs.count; i++){
      var newLog = {};
      newLog.width = 300 + Math.floor(Math.random() * 200);
      newLog.height = 35;
      newLog.x = 20 + Math.floor(Math.random() * 51);
      newLog.y = 75 * i + 40;
      newLog.cuts = [newLog.width + newLog.x];
      newLog.active = (i == 0 || this.game.level == 'free') ? true : false;
      newLog.direction = (i % 2 == 0) ? 'right' : 'left';
      newLog.lastCut = (i % 2 == 0) ? 0 : newLog.width;

      this.logs.list.push(newLog);
      
      _trigger('renderLog', [newLog]);
    }
  },

  handleMouse: function(e){
    if(!this.game.inProgress) return;
    if(e.which != 1) return; // Mouse needs to be held down

    var x = e.offsetX,
        y = e.offsetY;

    $.each(this.logs.list, function(i,log){               // Loop through each log, and:
      if(x > log.x && x < (log.x + log.width) && 
         y > log.y-5 && y < log.y + 15 && log.active){    // - Test that it fits within a cut boundary

        if((log.direction == 'right' && x < log.lastCut) ||
           (log.direction == 'left' && x > log.lastCut)){ // - Test that we're cutting in the right direction
          console.log("Invalid cut direction");
          if(this.game.level != 'free') return false; 
        }

        this.doCut(log, x,i);

      }
    }.bind(this)); 

  },

  doCut: function(log, x, i){ // TODO make this not need index. shouldnt be hard
    log.cuts.push(x);
    log.lastCut = x;
    
    // Now let's see if it's time to move to the next log
    if(this.game.level != 'free' && i != this.logs.count - 1){
      if((log.direction == 'right' && (log.x + log.width - x) < 80) || // TODO real number here
         (log.direction == 'left' && (x - log.x) < 80)){ // We're getting pretty close to the edge
        this.updateActiveLog(log, this.logs.list[i+1]);
      }
         
    }
    _trigger('renderCut', [log, x]);

  },

  updateActiveLog: function(oldLog, newLog){
    oldLog.active = false;
    newLog.active = true;
    _trigger('updateActiveLog', [oldLog, newLog]);
  },

  endGame: function(e){
    if(!this.game.inProgress) return;
    console.log("End game in model");
    this.game.inProgress = false;
    this.game.firstRun = false;
    if(this.game.level != 'practice') clearInterval(this.fuel.timer);
    this.analyzeCuts();
    if(!e) _trigger('endGameView');
  },

  analyzeCuts: function(){
    var accepted = 0,
        wrong = 0;
    this.logs.list.forEach(function(log){
      var previousCut = log.x; // First 'cut' is the start of the log

      log.cuts = log.cuts.sort(function(a,b){ return a-b; }); // Sort the cuts in ascending order

      log.cuts.forEach(function(cut){
        var midX = (cut+previousCut)/2, 
            midY = log.y + 18; // The x and y position of the checkmark/X labels

        if(Math.abs((cut - previousCut) - this.referenceLog.length) < this.referenceLog.tolerance){
          // The cut was valid
          _trigger('drawResultLabel', [midX, midY, true]);
          accepted++; 
          
        }else{ 
          // invalid cut
          _trigger('drawResultLabel', [midX, midY, false]);
          wrong++;
        }
        previousCut = cut;

      }.bind(this));

    }.bind(this));
    _trigger('showResults', [accepted, wrong]);
  }

}
  
