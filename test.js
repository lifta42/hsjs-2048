//
// hsjs-2048/test.js
// 2017.9.21 by liftA42.
//
if (typeof HSJS_2048_LIB_JS === 'undefined') {
    throw Error('Library (lib.js) is not imported.');
}

var HSJS_2048_TEST_JS = true;
var Test = function() {
    this.after = null;
    this._tests = [];
    this._testingIndex = 0;

    var self = this;
    this.it = function(desc, testBlock) {
        self._tests.push(function() {
            var finished = false;
            testBlock(function(expr) {
                if (finished) {
                    throw Error('Dup assertion in test: ' + desc);
                }

                finished = true;
                if (expr !== true) {
                    throw Error('Test not passed: ' + desc);
                }
                else {
                    if (self._testingIndex === self._tests.length - 1) {
                        console.log('All test passed');
                        if (self.after) {
                            self.after();
                        }
                        else {
                            throw Error('The main process is not set.');
                        }
                    }
                    else {
                        self._testingIndex++;
                        self._tests[self._testingIndex]();
                    }
                }
            });

            setTimeout(function() {
                if (!finished) {
                    throw Error('Test timeout: ' + desc);
                }
            }, 1000);
        })
    };
    this.end = function() {
        if (self._tests.length === 0) {
            throw Error('There is no test case.');
        }
        else {
            self._tests[0]();
        }
    }
};


// safeCheckAndDo :: IO () -> ()
var safeCheckAndDo = function(action) {
    var test = new Test();
    test.after = function() { return IO.main(action); };
    var it = test.it;

    it('should pass', function(assert) {
        assert(42 === 40 + 2);
    });
    var firstFinished = false;
    it('should be in seq (part 1)', function(assert) {
        setTimeout(function() {
            firstFinished = true;
            assert(true);
        }, 42);
    });
    it('should be in seq (part 2)', function(assert) {
        assert(firstFinished);
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
    // eventPropIO :: String -> _Event -> a -> IO b
    var eventPropIO = function(key) {
        return function(ev, a) {
            return compose(IO.return, prop(key))(constant(ev, a));
        };
    };
    it('should result event\'s type after event triggered', function(assert) {
        // lisType :: Delay a String
        var lisType = Delay.Listened(Listen.DocEvent('someEvent'), eventPropIO('type'));
        var list = DelayList.Cons(lisType, DelayList.Cons(toutCheck(assert, 'someEvent'), DelayList.Empty()));
        IO.main(DelayList.resolve(null, list));
        // unsafe
        document.dispatchEvent(new Event('someEvent'));
    });
    it('should listen for an event after delayed', function(assert) {
        // unsafe
        // Dispatch two events, the first one should be missed.
        setTimeout(function() {
            document.dispatchEvent(new Event('someEvent'));
        }, 5);
        var timestamp;
        setTimeout(function() {
            var event = new Event('someEvent');
            timestamp = event.timeStamp;
            document.dispatchEvent(event);
        }, 10);

        // lisTime :: Delay a Float
        var lisTime = Delay.Listened(Listen.DocEvent('someEvent'), eventPropIO('timeStamp'));
        // toutWait :: Delay a ()
        var toutWait = Delay.Timeout(7, function() {
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
    // lisAdd42 :: Delay Int Int
    var lisAdd42 = Delay.Listened(Listen.DocEvent('someEvent'), function(_, n) {
        return IO.return(n + 42);
    });
    it('should pass the value after event triggered', function(assert) {
        var list = DelayList.Cons(lisAdd42, DelayList.Cons(toutCheck(assert, 42), DelayList.Empty()));
        IO.main(DelayList.resolve(0, list));
        // unsafe
        document.dispatchEvent(new Event('someEvent'));
    });
    it('should be able to listen one event for more than once', function(assert) {
        var list = DelayList.Cons(lisAdd42, DelayList.Cons(lisAdd42,
            DelayList.Cons(toutCheck(assert, 84), DelayList.Empty())));
        IO.main(DelayList.resolve(0, list));
        // unsafe
        document.dispatchEvent(new Event('someEvent'));
        document.dispatchEvent(new Event('someEvent'));
    });

    test.end();
    return null;
};
