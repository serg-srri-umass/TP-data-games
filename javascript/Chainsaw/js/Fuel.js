/**
 * Constructor for a fuel tank object
 */
var Fuel = function() {
  this.el = $('#fuel #tank #contents'); // jQuery selector for visible "fuel" element
  this.percent = 100;
  this.initial = this.amount = 40;
  this.interval = 100; // Milliseconds

  this.timer = null;
};
  Fuel.prototype = {
    /**
     * Begin counting down fuel
     */
    begin: function () {
      this.timer = setInterval(increment, interval);
    },

    /**
     * Increment the fuel decrease
     */
    increment: function () {
      this.amount -= 1;
      this.percent = Math.round((this.amount / this.initial) * 100);

      if(this.amount <= 0){
        this.end();
      }
    },

    end: function () {
      clearTimeout(this.timer);
    }
  }