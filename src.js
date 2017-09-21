//
// hsjs-2048/src.js
// 2017.9.21 by liftA42.
//
if (typeof HSJS_2048_LIB_JS === 'undefined') {
    throw Error('Library (lib.js) is not imported.');
}
if (typeof HSJS_2048_TEST_JS === 'undefined') {
    throw Error('Test cases (test.js) are not imported.');
}


// main :: IO ()
var main = IO.log('This is the main process.');
safeCheckAndDo(main);
