/** 
 * Handle data output from Chainsaw to DG
 * Exposes a .controller object that commands can be run against.
 */
var ChainsawData = function(){
  //console.log(" - Data loaded");

  /**
   * Try and create a reference to the DG controller,
   * but don't break everything else if we're not running in DG
   */
  try {
    this.controller = window.parent.DG.currGameController;
  } catch(e){
    console.log("Could not init DG controller"); // We're not running in DG
    this.controller = (function(){
      var foo = function(){ return; };
      foo.prototype.doCommand = function(){ return {success: false }; };
      return new foo;
    })();
  }

  this.openRoundID = null;
  
  this.gameNumber = 0;
  this.player = "Player";
  this.piecesAccepted = 0;
  this.piecesRejected = 0;
  this.fuelLeftAmount = 0;
  this.fuelLeftPercent = 0;

  this.pieceNumber = 0;
 

  this.init();
}

/**
 * Functions on the ChainsawData class
 */
ChainsawData.prototype = {
  init: function() {
    /** Intiate a game with all required fields */
    this.controller.doCommand( {
      action: 'initGame',
      args: {
        name: "Chainsaw",
        dimensions: { width: 400, height: 250 },
        collections: [
          {
            name: "Games",
            attrs: [  { name: "GameNumber", type: 'numeric', precision: 0 },
                      { name: "Player", type: 'nominal' },
                      { name: "PiecesAccepted", type: 'numeric', precision: 0 },
                      { name: "PiecesRejected", type: 'numeric', precision: 0 },
                      { name: "FuelLeftAmount", type: 'numeric', precision: 0 },
                      { name: "FuelLeftPercent", type: 'numeric', precision: 0 },
                  ],
            childAttrName: "Cut_Record"
          },
          {
            name: "CutPieces",
            attrs: [  { name: "PieceNumber", type: 'numeric', precision: 0 },
                      { name: "Player", type: 'nominal' },
                      { name: "GameNumber", type: 'numeric', precision: 0 },
                      { name: "Length", type: 'numeric', precision: 0 },
                      { name: "Accepted", type: 'nominal' },
                      { name: "EndPiece", type: 'nominal' },
                      { name: "LogNumber", type: 'numeric', precision: 0 },
                      { name: "FuelLeftAmount", type: 'numeric', precision: 0 },
                      { name: "FuelLeftPercent", type: 'numeric', precision: 0 },
                    ],
            defaults: {
              xAttr: "PieceNumber",
              yAttr: "Length"
            }
          }
        ],
      }
    });

  },

  /**
   * Create a new game
   *
   * @param playerName The player name string to initiate with
   */
  newGame: function(playerName){
    this.player = playerName;
    this.gameNumber++;
    this.piecesAccepted = 0;
    this.piecesRejected = 0;
    this.fuelLeftAmount = 0;
    this.fuelLeftPercent = 0;
    this.pieceNumber = 0;
  },

  /**
   * Add a cut to the data
   *
   * @param - All pertinent cut information
   */
  addCut: function(length, accepted, endpiece, lognumber, fuelamount, fuelpercent) {
    this.pieceNumber++;
    this.fuelLeftAmount = fuelamount;
    this.fuelLeftPercent = fuelpercent;
    
    if(accepted == "Yes") this.piecesAccepted++;
    else this.piecesRejected++;

    var result;

    if( !this.openRoundID) {
      /* Add a new game */
      result = this.controller.doCommand({
                            action: 'openCase',
                            args: {
                              collection: "Games",
                              values: [ null, null, null, null, null, null, null ]
                            }
                          });
      if (result.success) this.openRoundID = result.caseID;
      else console.log("Error: Could not create game");
    }
    else {
      /* Update existing game */
      result = this.controller.doCommand({
                            action: 'updateCase',
                            args: {
                              collection: "Games",
                              caseID: this.openRoundID,
                              /* Seems to be that the accepted procedure is to
                               * keep null values here until the end of the game,
                               * then update.
                               */
                              values: [ null, null, null, null, null, null, null ]
                            }
                          });
      if(!result.success) console.log("Error: Could not update existing game");
    }


    /* Add our current data */
    result = this.controller.doCommand( {
      action: 'createCase',
      args: {
        collection: "CutPieces",
        parent: this.openRoundID,
        values: [ this.pieceNumber, this.player, this.gameNumber, length, accepted, endpiece, lognumber, this.fuelLeftAmount, this.fuelLeftPercent ]
      }
    });
    if(!result.success) console.log("Error: could not add cut");
  },
  
  /**
   * End the game, and close the current case
   * This is where the finalized data (left table in DG) gets sent
   */
  endGame: function() {
    if( this.openRoundID) {
      console.log("Adding game...");
      var result = this.controller.doCommand({
        action: 'closeCase',
        args: {
          collection: "Games",
          caseID: this.openRoundID,
          values: [ this.gameNumber, this.player, this.piecesAccepted, this.piecesRejected, this.fuelLeftAmount, this.fuelLeftPercent ]
        }
      });
      this.openRoundID = null;
      if(!result.success) console.log("Error: could not close case");
    }
  },

  
}
