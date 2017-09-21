//
// hsjs-2048/test.js
// 2017.9.21 by liftA42.
//
if (typeof HSJS_2048_LIB_JS === 'undefined') {
    throw Error('Library (lib.js) is not imported.');
}

var HSJS_2048_TEST_JS = true;


var TEST_TIMEOUT = 1000;
var it = function(desc, block) {
    var finished = false;
    block(function(expr) {
        if (finished) {
            throw Error('Duplicated test: ' + desc);
        }
        if (expr !== true) {
            throw Error('Test not passed: ' + desc);
        }
        finished = true;
    });
    setTimeout(function() {
        if (!finished) {
            throw Error('Test timeout: ' + desc);
        }
    }, TEST_TIMEOUT);
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
    var inc = compose(IO.return, function(n) { return n + 1; });
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
    var toutAdd42 = Delay.Timeout(0, compose(IO.return, function(n) { return n + 42; }));
    // toutCheck :: _Assert -> a -> Delay a ()
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

    // Delay & Listen
    it('should result event\'s type after event triggered', function(assert) {
        // lisType :: Delay a String
        var lisType = Delay.Listened(Listen.DocEvent('someEvent'), compose(IO.return, prop('type')));
        var list = DelayList.Cons(lisType, DelayList.Cons(toutCheck(assert, 'someEvent'), DelayList.Empty()));
        IO.main(DelayList.resolve(null, list));
        // unsafe
        document.dispatchEvent(new Event('someEvent'));
    });
    it('should listen for an event after delayed', function(assert) {
        // unsafe
        // Dispatch two events, the first one should be missed.
        var timestamp;
        document.dispatchEvent(new Event('someEvent'));
        setTimeout(function() {
            var event = new Event('someEvent');
            timestamp = event.timeStamp;
            document.dispatchEvent(event);
        }, 10);

        // lisTime :: Delay a Float
        var lisTime = Delay.Listened(Listen.DocEvent('someEvent'), compose(IO.return, prop('timeStamp')));
        // toutWait :: Delay a ()
        var toutWait = Delay.Timeout(0, function() {
            return IO.return(null);
        });
        // toutCheckTimestamp :: Delay Float ()
        // Can not use outside `toutCheck` because timestamp will be set after a while.
        var toutCheckTimestamp = Delay.Timeout(0, function(x) {
            assert(x === timestamp);
            return IO.return(null);
        });

        var list = DelayList.Cons(toutWait, DelayList.Cons(lisTime,
            DelayList.Cons(toutCheckTimestamp, DelayList.Empty())));
        IO.main(DelayList.resolve(null, list));
    });

    // IO.main(action);
    return null;
};
