//
// hsjs-2048/test.js
// 2017.9.21 by liftA42.
//
if (typeof HSJS_2048_LIB_JS === 'undefined') {
    throw Error('Library (lib.js) is not imported.');
}

var HSJS_2048_TEST_JS = true;


var it = function(desc, block) {
    block(function(expr) {
        if (expr !== true) {
            throw Error('Test not passed: ' + desc);
        }
    });
};

// safeCheckAndDo :: IO () -> ()
var safeCheckAndDo = function(action) {
    it('should pass', function(assert) {
        assert(42 === 40 + 2);
    });
    // IO
    // io42 :: IO Int
    var io42 = IO.return(42);
    it('should bind to the right value', function(assert) {
        IO.bind(io42, function(fortyTwo) {
            assert(fortyTwo === 42);
        });
    });
    // inc :: Int -> IO Int
    var inc = function(n) { return IO.return(n + 1); };
    var io43 = IO.bind(io42, inc);
    it('should get to correct result', function(assert) {
        IO.bind(io43, function(n) {
            assert(n === 43);
        });
    });
    it('should return second function\'s result', function(assert) {
        var io43Next = IO.next(io43, io43);
        IO.bind(io43Next, function(n) {
            assert(n === 43);
        });
    });
    it('should result in correct value after executing', function(assert) {
        assert(IO.main(io42) === 42);
    });

    // Delay & DelayList
    // toutAdd42 :: Delay Int Int
    var toutAdd42 = Delay.Timeout(0, function(n) { return IO.return(n + 42); });
    // toutCheck :: Assert -> Int -> Delay Int ()
    var toutCheck = function(assert, expected) {
        return Delay.Timeout(0, function(x) {
            assert(x === expected);
            return IO.return(null);
        });
    };
    it('should add 42 after delaying', function(assert) {
        var list = DelayList.Cons(toutAdd42, DelayList.Cons(toutCheck(assert, 42), DelayList.Empty()));
        IO.main(DelayList.resolve(0, list));
    });
    it('should add 84 after delaying twice', function(assert) {
        var list = DelayList.Cons(toutAdd42, DelayList.Cons(toutAdd42,
            DelayList.Cons(toutCheck(assert, 84), DelayList.Empty())));
        IO.main(DelayList.resolve(0, list));
    });

    // IO.main(action);
    return null;
};
