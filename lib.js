//
// hsjs-2048/lib.js
// Add some more comment here.
// 2017.9.12 by liftA42.
//

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
    return io.action();
};
