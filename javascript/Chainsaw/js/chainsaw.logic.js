var ChainsawLogic = function(canvasEl, data){ // Constructor
  this.data = data;

  // console.log(" - Logic loaded");

  this.game = {
    playerName: 'Player',
    level: 'practice',
    inProgress: false,
    firstRun: true,
    mousedown: false,
    alreadyCut: false
  };
  
  this.logs = {
    color: '#c09256',
    count: 4,
    list: [] // An array containing info about all the logs
  };

  this.referenceLog = {
    length: 75,
    tolerance: (1 / 8) * 75,
    test: function(p1, p2){ // Given two positions, see if they make a valid cut
      var maxLength = this.length + this.tolerance,
          minLength = this.length - this.tolerance,
          length = Math.abs(p1 - p2);

      if(length > maxLength){ return "No - Long"; }
      else if(length < minLength){ return "No - Short"; }
      else if(length >= minLength && length <= maxLength){ return "Yes"; }
      else{ return "Error"; }
    }
  };

  this.referenceLog.test(1,2);

  this.fuel = {
    initial: 85, // You start with this much
    current: 85,
    speed: 100, // milliseconds per timer loop
    step: 0.5, // amount to decrease per timer run
    timer: null
  };

  canvasEl.mousedown(function(){ this.game.mousedown = true; }.bind(this))
          .mouseup(function(){ this.game.mousedown = false; }.bind(this))
          .mousemove(function(e){ this.handleMouse(e); }.bind(this));

  // Global event listeners
  _bind('startGame', function(e, player){ this.startGame(player); }.bind(this));
  _bind('endGame', function(e){ this.endGame(e); }.bind(this));
  _bind('levelSelected', function(e, lvl){ this.levelSelected(lvl); }.bind(this) );
  
};

ChainsawLogic.prototype = { // Functions

  startGame: function(player){
    if(this.game.inProgress) return;

    this.playerName = player;
    this.data.newGame(this.playerName);

    if(!this.game.firstRun) this.generateLogs(); // New logs for a new game
    this.game.inProgress = true;
    if(this.game.level != 'practice') this.fuel.timer = setInterval(function(){ this.timerStep(); }.bind(this), this.fuel.speed);
  },

  timerStep: function(){
    this.fuel.current = this.fuel.current - this.fuel.step;
    _trigger('updateFuel', [this.fuel.current]);
    if(this.fuel.current <= 0){
      this.endGame(); 
    }

  },

  levelSelected: function(level){
    this.game.level = level;
    this.game.firstRun = true;
    this.generateLogs();
    this.fuel.current = this.fuel.initial;
    _trigger('updateFuel', [this.fuel.current]);
  },

  generateLogs: function(){
    this.logs.list = [];
    
    for(var i = 0; i < this.logs.count; i++){
      var newLog = {};
      newLog.width = 210 + Math.floor(Math.random() * 230);
      newLog.height = 35;
      newLog.x = 40 + Math.floor(Math.random() * 51);
      newLog.y = 75 * i + 40;
      newLog.cuts = [{pos: newLog.x}, {pos: newLog.x + newLog.width}];
      newLog.active = (i == 0 || this.game.level == 'free') ? true : false;
      newLog.direction = (i % 2 == 0) ? 'right' : 'left';
      newLog.lastCut = (i % 2 == 0) ? newLog.x : newLog.x + newLog.width;

      this.logs.list.push(newLog);
      
      _trigger('renderLog', [newLog]);
    }
    if(this.game.level != 'free'){
      _trigger('updateActiveLog', [null, this.logs.list[0]]);
    }
  },

  handleMouse: function(e){
    if(!this.game.inProgress) return;
    if(!this.game.mousedown) return; // Mouse needs to be held down

    var x = e.offsetX,
        y = e.offsetY,
        justCut = false;

    $.each(this.logs.list, function(i,log){               // Loop through each log, and:
      if(x > log.x && x < (log.x + log.width) && 
         y > (log.y-1) && y < log.y + 6 && log.active){     // - Test that it fits within a cut boundary

        if((log.direction == 'right' && x < log.lastCut) ||
           (log.direction == 'left' && x > log.lastCut)){ // - Test that we're cutting in the right direction
          console.log("Invalid cut direction");
          if(this.game.level != 'free') return false; 
        }

        if(!this.game.alreadyCut){
          this.doCut(log, x,i);
        }
        justCut = true;
      }
        
    }.bind(this)); 
    if(!justCut){ this.game.alreadyCut = false; }else{ this.game.alreadyCut = true; }
  },

  doCut: function(log, x, i){ // TODO make this not need index. shouldnt be hard
    
    var valid = this.referenceLog.test(log.lastCut, x);
    var fuelPercent = (this.fuel.current / this.fuel.initial) * 100;

    this.data.addCut(Math.abs(x - log.lastCut), valid, "No", i+1, this.fuel.current, fuelPercent);

    log.cuts.push({'pos': x, 'valid': valid});
    log.lastCut = x;

    if(this.game.level != 'free') _trigger('updateCutPointer', [log.y, x]);
    _trigger('renderCut', [log, x]);



    if(this.game.level == 'free' || i == this.logs.count - 1) return; // We don't need to check for end pieces

    var cutoff = this.referenceLog.length + this.referenceLog.tolerance;
    
    if((log.direction == 'right' && (log.x + log.width - x) < cutoff)
    || (log.direction == 'left' && (x - log.x) < cutoff) ){ // It's time to jump down to the next log

      this.updateActiveLog(log, this.logs.list[i+1]);
      
      var endPosition = (log.direction == 'left' ? log.x : log.x + log.width);
          createsValidCut = this.referenceLog.test(x, endPosition);
      
      this.data.addCut(Math.abs(x - endPosition), createsValidCut, "Yes", i+1, this.fuel.current, fuelPercent);

    }
  },

  updateActiveLog: function(oldLog, newLog){
    oldLog.active = false;
    newLog.active = true;
    _trigger('updateActiveLog', [oldLog, newLog]);
  },

  endGame: function(e){
    if(!this.game.inProgress) return;

    this.data.endGame();
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

      log.cuts = log.cuts.sort(function(a,b){ return a.pos-b.pos; }); // Sort the cuts in ascending order

      log.cuts.forEach(function(cut, index){
        if(index == 0) return; // There's no previous cut

        var midX = (cut.pos + previousCut)/2, 
            midY = log.y + 18; // The x and y position of the checkmark/X labels
        if(this.referenceLog.test(cut.pos, previousCut) == "Yes"){
          _trigger('drawResultLabel', [midX, midY, true]);
          accepted++; 
        }else{ 
          _trigger('drawResultLabel', [midX, midY, false]);
          wrong++;
        }
        previousCut = cut.pos;

      }.bind(this));

    }.bind(this));
    _trigger('showResults', [accepted, wrong]);
  }

}
  
