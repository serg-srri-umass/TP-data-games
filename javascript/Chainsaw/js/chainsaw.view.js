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
      this.levelSelected(e.srcElement.dataset.level);
    }.bind(this))

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
    cutEdge1: null,
    cutEdge2: null,
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

  this.clear();
};



ChainsawView.prototype = {
  clear: function(){
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

  levelSelected: function(level){
    this.clear();
    this.labels.nametag.html(this.labels.playerInput.val() || "Player");
    this.dialogs.container.fadeOut(200);
    _trigger('levelSelected', level);
  },

  renderLog: function(log){
    this.svgLogs.push(this.paper.rect(log.x, log.y, log.width, log.height));

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
  }
}

