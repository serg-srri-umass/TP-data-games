/**
 * Constructor for a "Game" object
 * Keeps track of current game info, as well as handling game events (level changing/etc)
 */
var Game = function() {
  this.playerName = 'Player';
  this.level = 'directional'; // Options are 'directional' - cut only in certain direction, or 'free'
  this.mode = 'practice';
  this.logWeight = 'normal'; // 'Normal', 'mixed', and 'heavy'
  this.inProgress = false;
  this.fuel = new Fuel();

  // DEBUG
  // this.setupGame('free', 'mixed');
};
  Game.prototype = {
    /**
     * Chage the current player name
     */
    changePlayer: function(player) {
      this.player = player;
    },

    /**
     * Set up and render a new game level
     * @param level The game level to generate
     * @param mode The game mode
     */
    setupGame: function(level, mode) {
      this.level = level;
      this.mode = mode;
      // Remove previous logs
      if(this.logs) this.logs.destroy();

      // Generate and render new set
      this.logs = new Logs();
      this.logs.generate(this.level, this.mode);
      this.logs.render();
    },

    /**
     * Begin a game (i.e. start timer, allow logs to be cut)
     */
    begin: function() {
      this.inProgress = true;
      if(this.mode != 'practice'){
        this.fuel.begin();
      }
    },

    /**
     * End a game
     */
    end: function() {
      this.inProgress = false;
      this.fuel.end();
    },

    /**
     * Analyze the cuts made
     */
    analyzeCuts: function() {
      // Pull in from chainsaw.logic

    }
  };