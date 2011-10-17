(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.Chainsaw = (function() {
    function Chainsaw(canvas) {
      console.log('Chainsaw game initiated');
      this.paper = Raphael('canvas', 600, 330);
      this.game = {
        playerName: 'Player',
        level: 'practice',
        inProgress: true
      };
      this.logs = {
        color: '#c09256',
        count: 4,
        list: []
      };
      this.referenceLog = {
        length: 100,
        tolerance: (1 / 8) * 100
      };
      this.fuel = {
        initial: 40,
        current: 40,
        el: $('#fuel #tank')
      };
      this.mouse = {
        cuttable: false,
        down: false,
        x: 0,
        y: 0
      };
      $(window).mousemove(__bind(function(e) {
        if (e.target === this.canvas) {
          return this.mousemove(e);
        }
      }, this));
      $('#startButton').click(__bind(function() {
        return this.generateLogs();
      }, this));
      $('#stopButton').click(__bind(function() {
        return this.analyzeCuts();
      }, this));
      this.generateLogs();
    }
    Chainsaw.prototype.generateLogs = function() {
      var i, _ref;
      this.logs.list = [];
      for (i = 1, _ref = this.logs.count; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        this.logs.list.push({
          width: 300 + Math.floor(Math.random() * 200),
          height: 35,
          x: 20 + Math.floor(Math.random() * 31),
          y: 60 * i - 10,
          cuts: [],
          active: true
        });
        this.logs.list[i - 1].cuts.push(this.logs.list[i - 1].width + this.logs.list[i - 1].x);
      }
      return this.renderLogs();
    };
    Chainsaw.prototype.renderLogs = function() {
      var log, renderLogs, _i, _len, _ref;
      this.paper.clear();
      renderLogs = this.paper.set();
      _ref = this.logs.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        log = _ref[_i];
        renderLogs.push(this.paper.rect(log.x, log.y, log.width, log.height));
        if (log.active) {
          this.paper.rect(log.x, log.y, log.width, 5).mouseover(__bind(function(e) {
            if (e.which === 1) {
              return this.tryCut(e.layerX, e.layerY);
            }
          }, this)).attr({
            fill: '#764d13'
          });
        }
      }
      return renderLogs.attr({
        fill: this.logs.color
      });
    };
    Chainsaw.prototype.tryCut = function(x, y) {
      var log, _i, _len, _ref, _results;
      _ref = this.logs.list;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        log = _ref[_i];
        _results.push(x > log.x && x < (log.x + log.width) && y > log.y - 5 && y < (log.y + 15) && log.active ? this.paper.rect(x, log.y + 5, 2, 30).attr({
          fill: 'white',
          "stroke-width": 0
        }) : void 0);
      }
      return _results;
    };
    Chainsaw.prototype.mousemove = function(e) {
      var log, _i, _len, _ref, _results;
      if (e.which !== 1) {
        return;
      }
      this.mouse.x = e.layerX;
      this.mouse.y = e.layerY;
      _ref = this.logs.list;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        log = _ref[_i];
        _results.push(this.mouse.x > log.x && this.mouse.x < (log.x + log.width) && this.mouse.y > log.y && this.mouse.y < (log.y + 5) && log.active ? (log.cuts.push(this.mouse.x), console.log('cut made')) : void 0);
      }
      return _results;
    };
    Chainsaw.prototype.analyzeCuts = function() {
      var cut, lastCutPosition, log, validCuts, _i, _j, _len, _len2, _ref, _ref2;
      validCuts = 0;
      _ref = this.logs.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        log = _ref[_i];
        lastCutPosition = 0;
        _ref2 = log.cuts;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          cut = _ref2[_j];
          if (Math.abs((cut - lastCutPosition) - this.referenceLog.length) < this.referenceLog.tolerance) {
            validCuts++;
          } else {

          }
          lastCutPosition = cut;
        }
      }
      return alert("Accepted cuts: " + validCuts);
    };
    return Chainsaw;
  })();
}).call(this);
