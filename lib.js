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

var Listen = function(f) {
    return {action: f};
};
// Listen.DocEvent :: String -> Listen
Listen.DocEvent = function(eventName) {
    return Listen(function(callback) {
        // Listen once by default, because no remove event listener API is provided by now.
        // noinspection JSCheckFunctionSignatures
        document.addEventListener(eventName, callback, {once: true});
        return null;
    });
};
// Listen.listen :: Listen -> (_Event -> IO ()) -> IO ()
Listen.listen = function(event, callback) {
    return IO(function() {
        event.action(callback);
        return null;
    });
};

// Delay.Listened :: Listen -> (_Event -> IO b) -> Delay a b
Delay.Listened = function(listen, delayed) {
    return Delay(function(_, follower) {
        return IO.main(Listen.listen(listen, function(ev) {
            var ioB = delayed(ev);
            IO.bind(ioB, follower);
            return null;
        }));
    });
};
