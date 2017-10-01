The very first thing I need to remember all the time is that, it is easy, _very_ easy, to write a common 2048 game in
plain old javascript (or coffeescript).

I choose coffee because I can write many, many trivial words in this literal mode, so that I will feel this file
valuable and will be not willing to delete it, as what I did to something like `src.js`, `lib.js` and `test.js`. RIP.

For my first step, I want to make a simple 2048 web-page based game. It should listen to user's keyboard (or screen if
the user visits with a moblie device), make some reaction when user make actions. In the future, an AI may be
introduced (forget it), and the reaction maybe respond to actions made not by user, by the AI which would be another
part of script. So, pre anything, I need to register a listener, so that I will be able to make my reaction.

  main = ->
    responseWith(reactionGenerator).applyTo userInterface

This is a two-step process. Firstly, the register is generated. Notice that I passed a generator into the register
method, because I want to make different, dynamicly generated reactions since user's input may change from time to time.

Secondly, the product a generator made is packed, which means, it must be unboxed and then it can make some effects in
the real world. So I apply the product to something called `userInterface`, which represents everything user knows, like
the pixels on the screen, etc.

And finally, by observing this process at a whole, someone may notice that the two verbs have some differences about
_time_, that, the "resgistry" is happened only once, but the "apply" is happened every time user actions. So it not a
good idea to understand this process as a registry, just regaurd it as a description of how this program works in the
top-most view.

  responseWith = (gen) ->
    keys = {w: UP, a: LEFT, s: DOWN, d: RIGHT}

    applyTo: (ui) ->
      whenAnyOfTheseKeysPressed keys, (direction) ->
        reaction = gen direction
        reaction ui

In the above code, `gen` is `reactionGenerator`, and `ui` is `userInterface`. In my oponion, it is necessary to
determine global names against local names, but `ALL_CAPITAL_LETTERS_NAME` or some other ways are not pretty, so I
choose to give up to use different shapes, only make them in different length. Usually, a global name will be made up
with at least two words, and a local name would rarely exceed one word. Good enough.

Coffee is an elegant language, and the above method shows that with two facts: no need of `return` in most case, the
last expression will be returned automatically, and here, the expression is all the things below `applyTo: ...` line.
The second fact is that, an object (dict) can come without curly braces. Actually, it is in YAML style. With this two
features, it is clear that I have returned a object, with a key named `applyTo`, whose value is a method that accepts
a `ui`, aka user interface as its argument. All of this satisfy the way I used this method.

I mentioned "unbox" previously. And here, I reveal how to apply a reaction to a user interface: just call it! You may
start to guess what happened in the generator. There must exist a checkerboard somewhere. After the generator gets
user's action, it calculated how this action would affect checkerboard's situation. The checkerboard is changed, so as
the "checkerboard" on the screen. The changing may be splited into several animations, some dirty black-magical DOM
things. All of these will be packed inside one method and be returned, which happened to be `reaction`.

Good morning! Just slept for a whole night and continue gushing. It seems that it is clear enough to write a generator
after the explain above, but I'm going to start from a easier work: the utility method `whenAnyOfTheseKeysPressed`. It
accept a dict, and whenever user presses any key that is a key in this dict, the callback argument will be executed
with the value of that key.

  whenKeyPressedWithRealWorld = (onpress) ->
    (map, callback) ->
      onpress (char) ->
        callback map[char] if char in Object.keys map

#  whenAnyOfTheseKeysPressed = whenKeyPressedWithRealWorld (callback) ->
#    document.addEventListener 'keypress', (event) ->
#      callback event.key

  realWorldOnKeyPressed =
    withConvert: (convert) ->
      (callback) ->
        document.addEventListener 'keypress', (event) -> callback convert event

  whenAnyOfTheseKeysPressed = whenKeyPressedWithRealWorld realWorldOnKeyPressed.withConvert (event) -> event.key

Wait, wait. What the hell is this? I know that when you read the description above, you must think that this method is
only a simple wrapper around `document.addEventListener`. But no, that will be bad, worst of all. Why? Because the
`whenAnyOfTheseKeysPressed` written in that way will be something with __side effect__. For each time it being executed,
it will modify a transparent global register table for event listeners. Maybe this is confusing, but just understand
that the world will not be the __same__ before and after the calling. Consider you have called `addEventListener` for
twice, the things going on here is that after first calling, one callback method will be executed when you press a key,
and after the second calling, two same callback will advent! This accident happens with the executing of
`addEventListener`, and of course it happens with the executing of `whenAnyOfTheseKeysPressed`, because it has to call
the previous method somewhere.

But we have a chance to protect our world, by turning off the lights whenever leaving a room... just kidding. I just
add a _middleware_, called `whenKeyPressedWithRealWorld`, between the dirty code and the pure code. Other middlewares
like this will also be named as `...withRealWorld` in the following code. Thanks to this middleware, all the evil things
are packed in the `onpress` argument that passed to `whenKeyPressedWithRealWorld`, thus, the `whenAnyOfTheseKeysPressed`
and `whenKeyPressedWithRealWorld` itself, are pure now. They are _pure_ means that you can call them as many times as
you like, and nothing changes in the real world, as long as you keep the `onpress` argument pure.

What does the previus statement remind you? __Unit testing__ and __debuging__. What is the different between a repl and
a breakpoint? In a improper way, the code stopped by a breakpoint is something with an "environment". The program maybe
just be in its middle to modify some global state. All the faking, or "mocking", is something for setting a "corrent"
global state, so that the method whose result depends on the global state will run as we expect. This hard work can be
saved when we deal with pure methods. They are angel that do not care about global state, aka "real world". When you ask
them to interact with real world, you need to pass a real world as argument to them. With some helper method, we can
fake a real world easily. Notice, this is not like fake an environment, which you can not touch and see. A real world
is probably an object, or in our case, a method. I call it `realWorldOnKeyPressed.withConvert`, the prefix `realWorld`
determines that it makes side effects, that change the real world.

The dot in the middle of the name is only something cool (or stupid maybe). Compare this method with the comment above.
They are almost the same, only it accepts a `convert` first, which allows us to adjust the event in a custom way before
sending it to the callback. Notice how I defined `whenAnyOfTheseKeysPressed`. WebStorm even treats it as a variable, not
a method! I can do this because of the defination of `whenKeyPressedWithRealWorld` and `realWorldOnKeyPressed`. The
first one returns a method that happens to have interface as same as we want `whenAnyOfTheseKeysPressed` has, and the
second one returns a method just in the shape of `onpress` argument. This is designed. It is equivalent to the following
"regular" code:

```coffeescript
whenAnyOfTheseKeysPressed = (map, callback) ->
  whenKeyPressedWithRealWorld(realWorldOnKeyPressed.withConvert((event) -> event.key))(map, callback)
```

and futher more:

```coffeescript
whenAnyOfTheseKeysPressed = (map, callback) ->
  whenKeyPressedWithRealWorld((callback) ->
    realWorldOnKeyPressed.withConvert((event) -> event.key)(callback)
  )(map, callback)
```

This is called [beta-reduction](https://en.wikipedia.org/wiki/Lambda_calculus#.CE.B2-reduction). The argument-free
(they call it "point-free") style is better because:
* ~~it's shorter.~~
* what is the different between the outer `callback` and the inner one? If you trace the calling stack, you will find
out that they are actually the same callback: the lambda we passed to `onpress` in place in
`whenKeyPressedWithRealWorld`. The extra arguemnts do not make code cleaner, but more confusing.
* the defination of `whenAnyOfTheseKeysPressed` becomes a sentence now! Ignore the double "real world", you can read
it as normal English. Just as the same of something above: I want to _describe_ this process, to illustrate the
function of each method, and forget the detail of their implementation as well as I can do.

One of the disadvantage of this style is that `realWorldOnKeyPressed` becomes uglier a bit. Pretend you cannot see it.
Actually, everything inside `realWorld...` is ugly, is not important, and is not something we should care about.

