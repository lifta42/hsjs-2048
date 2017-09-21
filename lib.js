//
// hsjs-2048/lib.js
// Add some more comment here.
// 2017.9.12 by liftA42.
//
var HSJS_2048_LIB_JS = true;


var IO = function(f) {
    return {action: f};
};
// IO.return :: a -> IO a
IO.return = function(a) {
    return IO(function() { return a; });
};
// IO.bind :: IO a -> (a -> IO b) -> IO b
IO.bind = function(io, func) {
    return func(io.action())
};
// IO.log :: String -> IO ()
IO.log = function(string) {
    return IO(function() {
        console.log(string);
        return IO.return(null);
    });
};
// IO.next :: IO a -> IO b -> IO b
IO.next = function(a, b) {
    return IO.bind(a, function() { return b; });
};
// IO.main :: IO a -> a
// ONLY ONCE
IO.main = function(io) {
    return io.action();
};

var Delay = function(f) {
    // Delay a b
    // f :: a -> (b -> c) -> ()
    return {delayed: f};
};
// Delay.Timeout :: Int -> (a -> IO b) -> Delay a b
Delay.Timeout = function(wait, delayed) {
    return Delay(function(value, follower) {
        setTimeout(function() {
            var ioB = delayed(value);
            IO.bind(ioB, follower);
        }, wait);
        return null;
    })
};

var DelayList = function(f) {
    // DelayList a
    // f :: a -> ()
    return {delayed: f};
};
// DelayList.Empty :: DelayList a
DelayList.Empty = function() {
    return DelayList(function() {
        return null;
    });
};
// DelayList.Cons :: Delay a b -> DelayList b -> DelayList a
DelayList.Cons = function(delay, list) {
    return DelayList(function(a) {
        delay.delayed(a, list.delayed);  // list.delay will be called with b
        return null;
    });
};
// DelayList.resolve :: a -> DelayList a -> IO ()
DelayList.resolve = function(init, list) {
    return IO(function() {
        list.delayed(init);
    });
};