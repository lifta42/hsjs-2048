//
// hsjs-2048/test.js
// 2017.9.21 by liftA42.
//
if (typeof window.HSJS_2048_LIB_JS === 'undefined') {
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


var safeCheckAndDo = function(action) {
    var test = new Test();
    test.after = action;
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

    it('should be executed in seq', function(assert) {
        assert(willSeq(function() {
            return 42;
        }, function(n) {
            return function() {
                return n + 1;
            };
        })() === 43);
    });

    test.end();
    return null;
};
