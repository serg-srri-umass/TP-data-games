var Chainsaw = function(){

  console.log("Chainsaw loaded.");
  
  /*
   * Create aliases for jQuery's bind & trigger, just to make things easier on the eyes.
   * _bind listens for global events, _trigger triggers them
   */ 
  var beacon = $({}); /* Generic element to bind events to */
  _bind = function(e,fn){ beacon.bind(e, fn); }
  _trigger = function(e, params){ beacon.trigger(e, params); }

  /*
   * Initiate the Chainsaw classes
   */
  this.Data = new ChainsawData();
  this.Logic = new ChainsawLogic($('#canvas'), this.Data);
  this.View = new ChainsawView($('#canvas'));
}
