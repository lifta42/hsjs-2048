//
// Add some comment here.
// 2017.9.12
//

var IO = function(f) {
    this._action = f;
};
// IO.of :: a -> IO a
IO.of = function(a) {
    return new IO(function() { return a; });
};
// IO.bind :: IO a -> (a -> IO b) -> IO b
IO.bind = function(io, func) {
    return func(io._action())
};
// IO.log :: String -> IO String
IO.log = function(string) {
    return new IO(function() {
        console.log(string);
        return IO.of(string);
    });
};
// IO.next :: IO a -> IO b -> IO b
IO.next = function(a, b) {
    return IO.bind(a, function(_) { return b; });
};
// IO.main :: IO a -> a
// ONLY ONCE
IO.main = function(io) {
    return io._action();
};

var Delay = function(wait, callback) {
    this._wait = wait;
    this._callback = callback;
};
// Delay.of :: Int -> (a -> IO ()) -> Delay a
Delay.of = function(wait, callback) {
    return new Delay(wait, callback);
};
// Delay.resolve :: Delay a -> a -> IO ()
Delay.resolve = function(delay, value) {
    return new IO(function() {
        setTimeout(function() {
            IO.main(delay._callback(value));
        }, delay._wait);
    });
};
// Delay.cons :: Int -> (a -> b) -> Delay b -> Delay a
Delay.cons = function(wait, func, delay) {
    return Delay.of(wait, function(a) {
        return Delay.resolve(delay, func(a));
    });
};

// add42ToString :: Int -> String
var add42ToString = function(a) { return '' + (a + 42); };
// delayLog :: Delay String
var delayLog = Delay.of(1000, IO.log);
// someDelay :: Delay Int
var someDelay = Delay.cons(500, add42ToString, delayLog);
// strLength :: String -> Int
var strLength = function(s) { return s.length; };
// someOtherDelay :: Delay String
var someOtherDelay = Delay.cons(500, add42ToString, Delay.cons(500, strLength, delayLog));
var delayIO = Delay.resolve(someOtherDelay, 42);
IO.main(delayIO);

