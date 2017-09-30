//
// hsjs-2048/lib.js
// Add some more comment here.
// Created: 2017.9.12 by liftA42.
// Restart: 2017.9.27 by liftA42.
//
var HSJS_2048_LIB_JS = true;


var willLog = function(log) {
    return function() {
        console.log(log);
    };
};
var willSeq = function(will1, will2) {
    return will2(will1());
};