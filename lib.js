//
// hsjs-2048/lib.js
// Add some more comment here.
// 2017.9.12 by liftA42.
//

var IO = function(f) {
    return {_action: f};
};
// IO.return :: a -> IO a
IO.return = function(a) {
    return IO(function() { return a; });
};
// IO.bind :: IO a -> (a -> IO b) -> IO b
IO.bind = function(io, func) {
    return func(io._action())
};
// IO.log :: String -> IO String
IO.log = function(string) {
    return IO(function() {
        console.log(string);
        return IO.return(string);
    });
};
// IO.next :: IO a -> IO b -> IO b
IO.next = function(a, b) {
    return IO.bind(a, function() { return b; });
};
// IO.main :: IO a -> a
// ONLY ONCE
IO.main = function(io) {
    return io._action();
};

var Delay = function(wait, callback) {
    return {_wait: wait, _callback: callback};
};
// Delay.Delay :: Int -> (a -> IO ()) -> Delay a
Delay.Delay = function(wait, callback) {
    return Delay(wait, callback);
};
// Delay.resolve :: Delay a -> a -> IO ()
Delay.resolve = function(delay) {
    return function(value) {
        return IO(function() {
            setTimeout(function() {
                IO.main(delay._callback(value));
            }, delay._wait);
        });
    };
};
// Delay.cons :: Int -> (a -> IO b) -> Delay b -> Delay a
Delay.cons = function(wait, func, delay) {
    return Delay.Delay(wait, function(a) {
        var iob = IO.bind(IO.return(a), func);
        return IO.bind(iob, Delay.resolve(delay));
    });
};

// secondLog :: Delay String
var secondLog = Delay.Delay(500, IO.log);
// middleMan :: String -> IO String
var middleMan = function(first) {
    return IO.next(IO.log(first), IO.return('second'));
};
// firstLog :: Delay String
var firstLog = Delay.cons(500, middleMan, secondLog);
// firstIO :: IO ()
var firstIO = Delay.resolve(firstLog)('first');
IO.main(firstIO);
