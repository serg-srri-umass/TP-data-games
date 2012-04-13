/**
 * Chainsaw (JS) version 4/13/2012
 */

$(function(){

  // Get references to HTML elements using jQuery selectors
  var DOM = {
    shadows: $('#shadows'), // Container 
    dialogs: {
      levelSelect: $('#levelselect'),
      results: $('#results')
    }
  };

  // Initiate a Raphael instance
  var canvasEl = $('#canvas'), // The DOM element to bind Raphael to
      width = 550,
      height = 350,
      context = Raphael(canvasEl[0], width, height);

  // Prevent text/etc from being highlighted
  document.onselectstart = document.ondragstart = function () { return false; };

  // Keep track of whether the mouse is currently up or down
  var mouseDown = false;
  canvasEl.mousedown(function() { mouseDown = true; });
  canvasEl.mouseup(function(){ mouseDown = false; });
  canvasEl.mouseleave(function(){ mouseDown = false; });

  var Chainsaw = new Game();

});
