/**
 * Frontend logic for the Chainsaw game
 *
 * @param canvasEl The Raphael element on which to draw the logs
 */
var ChainsawView = function(canvasEl){
  this.canvasEl = canvasEl;
  // console.log(" - View loaded");

  this.width = 550;
  this.height = 350;

  /** Initiate a new Raphael instance */
  this.paper = Raphael(canvasEl[0], this.width, this.height);

  /** Prevent text from being highlighted */
  document.onselectstart = function () { return false; };


  /** Button event handlers */
  this.buttons = {
    start: $('#startButton').click(function(){
      this.startGame();
    }.bind(this)),

    stop: $('#stopButton').click(function(){
      this.endGame();
    }.bind(this)),

    mute: $('#mute').click(function(){
      this.audio.toggleMute();
    }.bind(this)),
    
    selectLevel: $('#levelselect input[type=button]').click(function(e){
      this.levelSelected(e.target.dataset.level);
    }.bind(this)),

    continue: $("#results #continue").click(function(e){
      this.dialogs.results.fadeOut(200);
      this.dialogs.levelSelect.show();

    }.bind(this))

  }

  /** The various game dialogs */
  this.dialogs = {
    levelSelect: $('#levelselect'),
    results: $('#results')
  }

  /** Labels and other small UI elements that may need their contents/positions updated */
  this.labels = {
    nametag: $('#username'),
    howgood: $('#howgood'),
    levelLabel: null,
    cutBeginArrow: null,
    cutDownArrow: null,
    /** A Raphael set of elements to hold the 'Cut edge-' labels on either side of active logs */
    playerInput: $('#playername'),
    piecesaccepted: $('#piecesaccepted'),
    piecestotal: $('#piecestotal'),
    piecespercent: $('#piecespercent'),
    fuelTank: $('#fuel #tank #contents')
  }

  /** Audio elements and functions */
  this.audio = {
    el: null,
    volume: $('#volume').change(function(){
      this.audio.el.volume = this.audio.volume[0].value;
    }.bind(this)),

    toggleMute: function(){
      if(this.muted){
        this.volume[0].value = 1;
        this.volume.trigger('change');
        this.muted = false;
      }else{
        this.volume[0].value = 0;
        this.volume.trigger('change');
        this.muted = true;
      }
    },
    muted: false,
    cutting: 'assets/Begin Cut.mp3',
    finished: 'assets/End Cut.mp3',
    play: function(sound){
      if(this.el) this.el.pause();
      this.el = new Audio(sound);
      this.el.volume = this.volume[0].value;
      this.el.play();
    }
  }
  
  /** Event listeners to be called by the Logic code */
  _bind('renderLog', function(e, log){ this.renderLog(log) }.bind(this));
  _bind('renderCut', function(e, log, x){ this.renderCut(log, x); }.bind(this));
  _bind('clear', function(){ this.clear(); }.bind(this));
  _bind('endGameView', function(){ this.endGame(); }.bind(this));
  _bind('updateFuel', function(e, fuel){ this.updateFuel(fuel); }.bind(this));
  _bind('updateActiveLog', function(e, oldLog, newLog){ this.updateActiveLog(oldLog, newLog); }.bind(this));
  _bind('drawResultLabel', function(e, x, y, valid){ this.drawResultLabel(x,y,valid); }.bind(this));
  _bind('showResults', function(e, r, w){ this.showResults(r,w); }.bind(this));
  _bind('updateCutPointer', function(e, y, cut){ this.updateCutPointer(y, cut); }.bind(this));

  this.clear();
};



ChainsawView.prototype = {
  /**
   * Clear the game window and all UI elements
   */
  clear: function(){
    this.labels.cutDownArrow = null;
    this.paper.clear();
    this.svgLogs = this.paper.set();
    this.labels.cutBeginArrow = this.paper.image("assets/Cut From Here left.png", 0, 0, 58, 38).attr({opacity: 0});
  },


  /**
   * Handle level selection
   */
  levelSelected: function(level){
    this.clear();
    /** Update labels */
    this.labels.nametag.html(this.labels.playerInput.val() || "Player");
    var niceLevelName = level.replace('practice','Practice').replace('directional','Directional Cut').replace('free','Free Cut');
    this.labels.levelLabel = this.paper.text(this.width/2, this.height-12, niceLevelName).attr({fill: 'black', font: '300 12px Helvetica, arial, sans-serif'});
    this.buttons.start.removeAttr('disabled');
    this.dialogs.levelSelect.fadeOut(100);
    _trigger('levelSelected', level);
  },


  /**
   * Start the game, initialize UI
   */
  startGame: function(){
    this.buttons.stop.show();
    this.buttons.start.hide();
    this.canvasEl.addClass('active');
    this.audio.play(this.audio.cutting);
    _trigger('startGame', [this.labels.nametag.html()]);

  },

  /**
   * End the game
   */
  endGame: function(){
    this.buttons.stop.hide();
    this.buttons.start.attr('disabled', 'disabled').show();
    this.canvasEl.removeClass('active');
    this.audio.play(this.audio.finished);
    _trigger('endGame');
  },

  /**
   * Draw result labels on valid/invalid log segments
   *
   * @param x The x coord of the label
   * @param y The y coordinate of the label
   * @param valid Whether or not the segment was valid
   */
  drawResultLabel: function(x,y,valid){
    if(valid){
      this.paper.text(x, y, "✓")
                .attr({ fill: '#00FF00', 'font-size': 16 });
    }else{
      this.paper.text(x, y, "X")
                .attr({ fill: 'red', 'font-size': 16});
    }
  },
  
  /**
   * Show results dialog
   *
   * @param right Number of accepted cuts
   * @param wrong Number of incorrect cuts
   */
  showResults: function(right, wrong){
    var percentCorrect = (right + wrong == 0 ? 0 : Math.floor(right/(right+wrong) * 100));
    if(percentCorrect < 33){
      this.labels.howgood.html("Good try");
    }else if(percentCorrect < 66){
      this.labels.howgood.html("Nice job");
    }else{
      this.labels.howgood.html("Great game");
    }
    this.labels.piecesaccepted.html(right);
    this.labels.piecestotal.html(right + wrong);
    this.labels.piecespercent.html(percentCorrect + '%');
    this.dialogs.results.delay(800).fadeIn(200);
  },


  /**
   * Update fuel tank
   */
  updateFuel: function(fuel){
    this.labels.fuelTank.height(fuel);
  },

  /**
   * Update 'last cut' pointer after a cut is made
   */
  updateCutPointer: function(y, cut){
    if(!this.labels.cutDownArrow){
      /** Create the arrow if it hasn't been initialized */
      this.labels.cutDownArrow = this.paper.image("assets/Down Arrow Small.png", 0, 0, 20, 33);
    }
    /** Reposition */
    this.labels.cutDownArrow.attr({ x: cut-10, y: y -33});
    /** Remove initial arrow */
    this.labels.cutBeginArrow.animate({opacity: 0}, 200);
  },

  /**
   * Update the position of the "Begin cut here" label for a new log
   *
   * @param log The log to label
   */
  updateCutEdgeLabels: function(log){
    if(this.labels.cutDownArrow){ this.labels.cutDownArrow.hide(); this.labels.cutDownArrow = null; }
    var xPos = log.x - 52,
        yPos = log.y - 25;

    /**  Move the label to the right side of the log if necessary */
    if(log.direction == 'left'){ xPos += log.width + 50; }
    this.labels.cutBeginArrow.attr({x: xPos, y: yPos, src: "assets/Cut From Here "+log.direction+".png"}).animate({opacity: 1}, 200);

  },
  
  /**
   * Render a log, piece by piece (top, right, bottom, left, end, shadow)
   *
   * Path strings ("M0,0S0,0 2,2" etc) are defined by the SVG specification, and are nice and confusing
   * See http://raphaeljs.com/reference.html#Paper.path for an explanation of what each path element means
   *
   * @param log The log to render
   *
   */
  renderLog: function(log){
    
    /** Start the path in the right place */
    var newPath = "M"+log.x+","+log.y;


    /** 
     * Draw the top line in segments 
     * Pick a random number of segments to draw, and create them
     */
    var segmentCount = Math.floor((1 + Math.random()*1.4)*(log.width/200));
    var averageWidth = Math.floor(log.width/segmentCount);

    var currentPosition = log.x; 
    var lastPosition;
    var endOfLog = false;
    while(!endOfLog) { // add a new segment to our log 
      lastPosition = currentPosition; 
      if(currentPosition + averageWidth + 50 > log.x + log.width){
        currentPosition = log.x + log.width;
        endOfLog = true;
      }else{
        currentPosition = currentPosition + averageWidth + (Math.random() - 0.5)*75;
      }
      newPath += "S"+((currentPosition+lastPosition)/2)+","+(log.y-3)+" "+currentPosition+","+log.y;
    }
    newPath += 'l0,0' // Sharp corners


    /** 
     * Draw the right hand side curve of the log
     */
    newPath += "S"+(log.x+log.width+5)+","+(log.y+(log.height/2))+" "+(log.x+log.width)+","+(log.y+log.height);
    newPath += 'l0,0' // Sharp corners


    /**
     * Draw the bottom line in segments, as we did with the top
     */
    var currentPosition = log.x+log.width; 
    var lastPosition;
    var endOfLog = false;
    while(!endOfLog) { // add a new segment to our log 
      lastPosition = currentPosition; 
      if(currentPosition - averageWidth - 50 < log.x){
        currentPosition = log.x;
        endOfLog = true;
      }else{
        currentPosition = currentPosition - averageWidth - (Math.random() - 0.5)*75;
      }
      newPath += "S"+((currentPosition+lastPosition)/2)+","+(log.y+log.height+3)+" "+currentPosition+","+(log.y+log.height);
    }
    newPath += 'l0,0' // Sharp corners


    /**
     * Draw the left hand side
     */
    newPath += "S"+(log.x+5)+","+(log.y+(log.height/2))+" "+log.x+","+log.y;
    newPath += 'l0,0' // Sharp corners

    /**
     * Draw the end of the log
     */
    logEndPath = "M"+log.x+","+log.y;
    logEndPath += "s-8,0 0,"+log.height+"l0,0";
    logEndPath += "s8,0 0,-"+log.height;


    /**
     * Draw shadows using the Raphael blur plugin
     * On browsers where this isn't supported, a gray shadow-like shape (unblurred) will be rendered instead
     */
    var shadow = this.paper.rect(log.x-2, log.y + log.height-5, log.width+4, 13, 10).attr({ fill: 'rgba(0,0,0,0.6)' });
    shadow.blur(3);

    var newLog = this.paper.path(newPath);
    var newLogEnd = this.paper.path(logEndPath);

    /** Add the new log to the Raphael set */
    this.svgLogs.push(newLogEnd, newLog);

    /** Create the cut surface */
    log.cutSurface = this.paper.rect(log.x, log.y, log.width, 5).attr({ fill: '#764d13' });
    if(!log.active){ log.cutSurface.hide(); }

    /** Define styles on the Raphael log set */
    this.svgLogs.attr({ fill: "90-#b17603-#bea379", 'stroke-width': 2, stroke: '#764d13' });
  },

  /**
   * Render a completed 'cut'
   * 
   * @param log The log being cut
   * @param x The x coordinate of the cut
   */
  renderCut: function(log, x){
    this.paper.path("M"+x+","+log.y+"s3,0 0,35")
              .attr({ 'stroke-width': 2, stroke: '#764d13'});

  },

  /**
   * Update the active (cuttable) log
   *
   * @param oldLog The previous log (optional; pass null if this is the first log)
   * @param newLog THe new 'current' log
   */
  updateActiveLog: function(oldLog, newLog){
    if(oldLog) oldLog.cutSurface.hide();
    newLog.cutSurface.show();
    this.updateCutEdgeLabels(newLog);
  }
}

