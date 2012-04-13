/*
Function.prototype.bind is a method introduced in ECMAscript 262-5 which allows
changes to the running context of a function  (i.e. the 'this' variable)

This extension provides .bind functionality in browsers (ex. Safari) which haven't
yet implemented it, and should be a close enough approximation to function in any
current browser.

Sourced from:
https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
and assumed to be freely distributable

*/

if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5 internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }

    var fSlice = Array.prototype.slice,
        aArgs = fSlice.call(arguments, 1), 
        fToBind = this, 
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP
                                 ? this
                                 : oThis || window,
                               aArgs.concat(fSlice.call(arguments)));
        };

    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();

    return fBound;
  };
}

