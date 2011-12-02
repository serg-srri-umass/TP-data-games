/**
 * Backend logic for the Chainsaw game
 *
 * @param canvasEl The DOM element on which to draw the logs
 * @param data A reference to the ChainsawData object
 */
var ChainsawLogic = function(canvasEl, data){
  this.canvasEl = canvasEl;
  this.data = data;

  /** Initiate variables related to the current game */
  this.game = {
    playerName: 'Player',
    level: 'practice',
    inProgress: false,
    firstRun: true,
    mousedown: false,
    alreadyCut: false
  };
  
  /** Log variables, including .list - an array of all the log object */
  this.logs = {
    color: '#c09256',
    count: 4,
    list: []
  };
  

  /** Reference log variables */
  this.referenceLog = {
    length: 75,
    tolerance: (1 / 8) * 75,
    /*
     * Given two x positions, check if they make a valid cut
     *
     * @param p1, p2 The relevant positions
     * @returns "No - Long", "No - Short", or "Yes"
     */
    test: function(p1, p2){
      var maxLength = this.length + this.tolerance,
          minLength = this.length - this.tolerance,
          length = Math.abs(p1 - p2);

      if(length > maxLength){ return "No - Long"; }
      else if(length < minLength){ return "No - Short"; }
      else if(length >= minLength && length <= maxLength){ return "Yes"; }
      else{ return "Error"; }
    }
  };

  /** Fuel variables */
  this.fuel = {
    /** You start with this much */
    initial: 85,
    current: 85,
    /** Miliseconds per timer loop */
    speed: 100,
    /** Amount to decrement by per loop */
    step: 0.5,
    /** Provide a reference to the (as yet uninitiated) timer itself */
    timer: null
  };

  /** Provide handlers for mouse events */
  this.canvasEl.mousedown(function(){ this.game.mousedown = true; }.bind(this))
          .mouseup(function(){ this.game.mousedown = false; }.bind(this))
          .mousemove(function(e){ this.handleMouse(e); }.bind(this));

  /** Global _bind event listeners */
  _bind('startGame', function(e, player){ this.startGame(player); }.bind(this));
  _bind('endGame', function(e){ this.endGame(e); }.bind(this));
  _bind('levelSelected', function(e, lvl){ this.levelSelected(lvl); }.bind(this) );
  
};

ChainsawLogic.prototype = { 

  /**
   * Start the game
   * 
   * @param player The player name as a string
   */
  startGame: function(player){
    if(this.game.inProgress) return;

    this.playerName = player;
    this.data.newGame(this.playerName);
    
    /** Generate new logs for a new game */
    if(!this.game.firstRun) this.generateLogs();
    this.game.inProgress = true;

    /** Initiate the fuel timer */
    if(this.game.level != 'practice')
      this.fuel.timer = setInterval(function(){ this.timerStep(); }.bind(this), this.fuel.speed);
  },

  /**
   * The timer increment function
   */
  timerStep: function(){
    this.fuel.current = this.fuel.current - this.fuel.step;
    _trigger('updateFuel', [this.fuel.current]);
    if(this.fuel.current <= 0){
      this.endGame(); 
    }

  },

  /**
   * Handle level setup after one is selected
   *
   * @param level The level name as a String
   */
  levelSelected: function(level){
    this.game.level = level;
    this.game.firstRun = true;
    this.generateLogs();
    this.fuel.current = this.fuel.initial;
    _trigger('updateFuel', [this.fuel.current]);
  },

  /**
   * Generate a new set of logs, and pass them off to be rendered
   */
  generateLogs: function(){
    this.logs.list = [];
    
    for(var i = 0; i < this.logs.count; i++){
      var newLog = {};
      newLog.width = 210 + Math.floor(Math.random() * 230);
      newLog.height = 35;
      newLog.x = 50 + Math.floor(Math.random() * 51);
      newLog.y = 75 * i + 40;
      /** Store the beginning and end of the log as pre-existing cuts */
      newLog.cuts = [{pos: newLog.x}, {pos: newLog.x + newLog.width}];
      newLog.active = (i == 0 || this.game.level == 'free') ? true : false;
      newLog.direction = (i % 2 == 0) ? 'right' : 'left';
      newLog.lastCut = (i % 2 == 0) ? newLog.x : newLog.x + newLog.width;

      this.logs.list.push(newLog);
      
      _trigger('renderLog', [newLog]);
    }

    /** Update the cuttable 'current' log to be the first one we created */
    if(this.game.level != 'free'){
      _trigger('updateActiveLog', [null, this.logs.list[0]]);
    }
  },

  /**
   * Handle mouse drag events, and check if they translate into a valid cut
   * @param e The triggered mouse event
   */
  handleMouse: function(e){
    if(!this.game.inProgress) return;
    if(!this.game.mousedown) return;
    /** Can't use offsetX/layerX here due to browser inconsistencies */
    var x = e.pageX - this.canvasEl.offset().left,
        y = e.pageY - this.canvasEl.offset().top,
        justCut = false;
    
    /** Loop through each cut, and: */
    $.each(this.logs.list, function(i,log){
      /** Test that it fits within a defined cut boundary */
      if(x > log.x && x < (log.x + log.width) && 
         y > (log.y-1) && y < log.y + 6 && log.active){

        /** Test that we're cutting in the correct direction */
        if((log.direction == 'right' && x < log.lastCut) ||
           (log.direction == 'left' && x > log.lastCut)){
          console.log("Invalid cut direction");
          if(this.game.level != 'free') return false; 
        }
        
        /** Make sure that we've left the cut area before we're qualified to make another */
        if(!this.game.alreadyCut){
          this.doCut(log, x,i);
        }
        justCut = true;
      }
        
    }.bind(this)); 
    this.game.alreadyCut = justCut;
  },

  /**
   * Handle and process an (already determined) valid cut
   * 
   * @param log The log object being cut
   * @param x The x position of the cut.
   * @param i The index of the log in the logs.list array. 
   *    TODO: possibly negate the need for index
   */
  doCut: function(log, x, i){
    
    /** Test whether or not the cut is of the correct length */ 
    var valid = this.referenceLog.test(log.lastCut, x);
    var fuelPercent = (this.fuel.current / this.fuel.initial) * 100;

    this.data.addCut(Math.abs(x - log.lastCut), valid, "No", i+1, this.fuel.current, fuelPercent);

    log.cuts.push({'pos': x, 'valid': valid});
    log.lastCut = x;

    if(this.game.level != 'free') _trigger('updateCutPointer', [log.y, x]);
    _trigger('renderCut', [log, x]);


    /** If we don't need to check that we're nearing the end of the log, stop here */
    if(this.game.level == 'free' || i == this.logs.count - 1) return;

    /** The maximum possible length of a log */
    var cutoff = this.referenceLog.length + this.referenceLog.tolerance;
    
    /** If the amounf of space left is smaller than the cutoff, add the cut and move down to the next log */
    if((log.direction == 'right' && (log.x + log.width - x) < cutoff)
    || (log.direction == 'left' && (x - log.x) < cutoff) ){

      this.updateActiveLog(log, this.logs.list[i+1]);
      
      var endPosition = (log.direction == 'left' ? log.x : log.x + log.width);
          createsValidCut = this.referenceLog.test(x, endPosition);
      
      this.data.addCut(Math.abs(x - endPosition), createsValidCut, "Yes", i+1, this.fuel.current, fuelPercent);

    }
  },

  /**
   * Update the 'active' (cuttable) log.
   *
   * @param oldLog The previous active log object
   * @param newLog The new active log
   */
  updateActiveLog: function(oldLog, newLog){
    oldLog.active = false;
    newLog.active = true;
    _trigger('updateActiveLog', [oldLog, newLog]);
  },


  /**
   * End the game
   *
   * @param e The event, as triggered by the view
   */
  endGame: function(e){
    if(!this.game.inProgress) return;


    this.data.endGame(this.fuel.current, (this.fuel.current/this.fuel.initial)*100);
    this.game.inProgress = false;
    this.game.firstRun = false;
    if(this.game.level != 'practice') clearInterval(this.fuel.timer);
    this.analyzeCuts();
    /** If this wasn't triggered by the view, make sure to update that */
    if(!e) _trigger('endGameView');
  },

  /**
   * After the game, run through the cuts made for analysis
   */
  analyzeCuts: function(){
    /** Keep tallys of accepted and unaccepted cuts */
    var accepted = 0,
        wrong = 0;

    /** Loop through each log */
    this.logs.list.forEach(function(log){
      /** First 'cut' is the start of the log */
      var previousCut = log.x;

      /** Sort the cuts in ascending order */
      log.cuts = log.cuts.sort(function(a,b){ return a.pos-b.pos; });

      log.cuts.forEach(function(cut, index){
        /** Exit if there's no previous cut */
        if(index == 0) return;

        /** Calculate the X and Y positions of the checkmark/X labels */
        var midX = (cut.pos + previousCut)/2, 
            midY = log.y + 18;

        /** Determine which label to draw, then draw it */
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
  
