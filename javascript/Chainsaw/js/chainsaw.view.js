var ChainsawView = function(canvasEl){
  this.canvasEl = canvasEl;
  console.log("View loaded.");

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
    _trigger('startGame');

  },

  endGame: function(){
    console.log("End game in view");
    this.buttons.stop.attr('disabled','disabled');
    this.buttons.changeLevel.removeAttr('disabled');
    this.buttons.start.removeAttr('disabled');
    this.canvasEl.removeClass('active');
    _trigger('endGame');
  },

  changeLevel: function(){
    this.dialogs.container.fadeIn(200);
  },

  drawResultLabel: function(x,y,valid){
    if(valid){
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
    var newPath = "M"+log.x+","+log.y;

    var segmentCount = Math.floor(Math.random()*(4)+4);
    var averageWidth = Math.floor(log.width/segmentCount);
    var currentPosition = log.x; 
    for(i = 0;i < segmentCount; i++) { // add a new segment to our log 
      lastPosition = currentPosition; 
      currentPosition = currentPosition+averageWidth;
      newPath += "S"+((currentPosition+lastPosition)/2)+","+(log.y-05)+" "+currentPosition+","+log.y;
    }
    newPath += "L"+(log.x+log.width)+","+(log.y+log.height);
    newPath += "L"+log.x+","+(log.y+log.height);
    newPath += "L"+log.x+","+log.y;
    console.log(newPath);
    var newLog = this.paper.path(newPath);
    this.svgLogs.push(newLog);
    //this.svgLogs.push(this.paper.rect(log.x, log.y, log.width, log.height));

    log.cutSurface = this.paper.rect(log.x, log.y, log.width, 5).mouseover(function(e){
      _trigger('handleMouse', e);
    }.bind(this)).attr({ fill: '#764d13' });
    if(!log.active){ log.cutSurface.hide(); }

    this.svgLogs.attr({ fill: "url('assets/log_tiles.jpg')" });
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

