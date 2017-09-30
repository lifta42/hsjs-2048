The very first thing I need to remember all the time is that, it is easy, _very_ easy, to write a common 2048 game in
plain old javascript (or coffeescript).

I choose coffee because I can write many, many trivial words in this literal mode, so that I will feel this file
valuable and will be not willing to delete it, as what I did to something like `src.js`, `lib.js` and `test.js`. RIP.

For my first step, I want to make a simple 2048 web-page based game. It should listen to user's keyboard (or screen if
the user visits with a moblie device), make some reaction when user make actions. In the future, an AI may be
introduced (forget it), and the reaction maybe respond to actions made not by user, by the AI which would be another
part of script. So, pre anything, I need to register a listener, so that I will be able to make my reaction.

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