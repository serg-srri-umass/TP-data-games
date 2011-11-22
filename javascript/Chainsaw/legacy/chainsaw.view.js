var ChainsawView = function(canvasEl){
  this.canvasEl = canvasEl;
  // console.log(" - View loaded");

  this.width = 600;
  this.height = 330;
  this.paper = Raphael(canvasEl[0], this.width, this.height);

  document.onselectstart = function () { return false; };

  this.buttons = {
    start: $('#startButton').click(function(){
      this.startGame();
    }.bind(this)),

    stop: $('#stopButton').click(function(){
      this.endGame();
    }.bind(this)),

    mute: $('#mute').click(function(){

    }.bind(this)),
    
    changeLevel: $('.changeLevel').click(function(){
      this.changeLevel();
    }.bind(this)),

    selectLevel: $('#levelselect input[type=button]').click(function(e){
      this.levelSelected(e.target.dataset.level);
    }.bind(this)),

  }

  this.dialogs = {
    container: $("#overlay"),
    levelSelect: $("#levelselect"),
    results: $('#results')
  }

  this.labels = {
    nametag: $("#username"),
    levelLabel: null,
    cutDownArrow: null,
    cutEdges: this.paper.set(), // The "cut edge -" labels on either side
    playerInput: $('#playername'),
    acceptedCuts: $('#accepted'),
    fuelTank: $('#fuel #tank #contents')
  }

  this.audio = {
    el: null,
    volume: $('#volume').change(function(){
      this.audio.el.volume = this.audio.volume[0].value;
    }.bind(this)),
    cutting: 'assets/start.mp3',
    finished: 'assets/stop.mp3',
    play: function(sound){
      if(this.el) this.el.pause();
      this.el = new Audio(sound);
      this.el.volume = this.volume[0].value;
      this.el.play();
    }
  }
  
  // Global event listeners
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
  clear: function(){
    this.labels.cutDownArrow = null;
    this.paper.clear();
    this.svgLogs = this.paper.set();
  },

  startGame: function(){
    this.buttons.start.attr('disabled','disabled');
    this.buttons.changeLevel.attr('disabled','disabled');
    this.buttons.stop.removeAttr('disabled');
    this.canvasEl.addClass('active');
    this.audio.play(this.audio.cutting);
    _trigger('startGame', [this.labels.nametag.html()]);

  },

  endGame: function(){
    this.buttons.stop.attr('disabled','disabled');
    this.buttons.changeLevel.removeAttr('disabled');
    this.buttons.start.removeAttr('disabled');
    this.canvasEl.removeClass('active');
    this.audio.play(this.audio.finished);
    _trigger('endGame');
  },

  changeLevel: function(){
    this.dialogs.container.fadeIn(200);
  },

  drawResultLabel: function(x,y,valid){
    if(valid){
      //this.paper.text(x, y, width)
      this.paper.text(x, y, "✓")
                .attr({ fill: '#00FF00', 'font-size': 16 });
    }else{
      this.paper.text(x, y, "X")
                .attr({ fill: 'red', 'font-size': 16});
    }
  },

  showResults: function(right, wrong){
    this.labels.acceptedCuts.html(right+" / "+(right+wrong));
  },

  updateFuel: function(fuel){
    this.labels.fuelTank.height(fuel);
  },

  updateCutPointer: function(y, cut){
    if(!this.labels.cutDownArrow){
      this.labels.cutDownArrow = this.paper.image("assets/Down\ Arrow\ Small.png", 0, 0, 20, 33);
    }
    this.labels.cutDownArrow.attr({ x: cut-10, y: y -33});
  },

  updateCutEdgeLabels: function(log){
    this.labels.cutEdges.forEach(function(e){ e.remove(); });

    var label1 = this.paper.text(0, 0, "cut edge -"),
        label2 = this.paper.text(0, 0, "- cut edge");
    label1.attr({x:log.x-8-(label1.node.clientWidth/2), y:log.y});
    label2.attr({x:log.x+8+log.width+(label2.node.clientWidth/2), y:log.y});

    this.labels.cutEdges.push(label1, label2)
                        .attr({'font-size':12});
  },

  levelSelected: function(level){
    this.clear();
    this.labels.nametag.html(this.labels.playerInput.val() || "Player");
    this.dialogs.container.fadeOut(200);
    _trigger('levelSelected', level);
  },

  renderLog: function(log){
    // Paths as defined by the SVG spec - nice and confusing
    
    // Start the path in the right place  
    var newPath = "M"+log.x+","+log.y;


    /* Draw the top line in segments */
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


    /* Draw the right hand side */
    newPath += "S"+(log.x+log.width+5)+","+(log.y+(log.height/2))+" "+(log.x+log.width)+","+(log.y+log.height);
    newPath += 'l0,0' // Sharp corners


    /* Draw the bottom line in segments */
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


    /* Draw the left hand side */
    newPath += "S"+(log.x+5)+","+(log.y+(log.height/2))+" "+log.x+","+log.y;
    //newPath += "L"+log.x+","+log.y;
    newPath += 'l0,0' // Sharp corners


    /* Render shadows */
    var shadow = this.paper.rect(log.x-2, log.y + log.height-5, log.width+4, 13, 10).attr({ fill: 'rgba(0,0,0,0.6)' });
    shadow.blur(3);


    var newLog = this.paper.path(newPath);
    this.svgLogs.push(newLog);

    log.cutSurface = this.paper.rect(log.x, log.y, log.width, 5).attr({ fill: '#764d13' });
    if(!log.active){ log.cutSurface.hide(); }


    // this.svgLogs.attr({ fill: "url('assets/log_tiles.jpg')" });
    this.svgLogs.attr({ fill: "90-#b17603-#bea379", 'stroke-width': 2, stroke: '#764d13' });
  },

  renderCut: function(log, x){
    this.paper.rect(x, log.y, 1, 35)
              .attr({ fill: 'white', 'stroke-width': 0});

  },

  updateActiveLog: function(oldLog, newLog){
    oldLog.cutSurface.hide();
    newLog.cutSurface.show();
    this.updateCutEdgeLabels(newLog);
  }
}

