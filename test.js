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

    IO.main(action);
    return null;
};
