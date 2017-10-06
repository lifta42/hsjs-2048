The very first thing I need to remember all the time is that, it is easy, _very_ easy, to write a common 2048 game in
plain old javascript (or coffeescript).

I choose coffee because I can write many, many trivial words in this literal mode, so that I will feel this file
valuable and will be not willing to delete it, as what I did to something like `src.js`, `lib.js` and `test.js`. RIP.

> "Coffee? Must be something evil! Goodbye!"
> In case of some of you think like this, here is some preparing steps if you are not familiar with this language full
> of sugar:
> * Level 0, you are lazy: just keep reading.
> * Level 1, you don't know about coffeescript: visit [coffee's homepage](http://coffeescript.org/) for some infomation.
> * Level 2, you don't know about ES2015: visit [babel's tutorial](https://babeljs.io/learn-es2015/).
> * Level 3, you don't know about javascript: visit [w3school's tutorial](https://www.w3schools.com/js/) or any other
> website if you cannot visit it.
> * Level 4, you don't know about programming: ...then how did you find this project all the way along?
>
> You may notice that I order these levels in a more-to-less knowledged way. Because the previous level does not require
> all the things in the following ones. You may start from level 1 even you know little about ES2015, and only move 
> forward if you really cannot understand what you are looking at.
>
> Actually, there is nothing more for you to learn if you know Ruby or C++ or even neither of them. Just remember two
> things before reading:
> 1. `->` introduces a method. A simple, non-trivial example would be `addOne = (n) -> n + 1`.
> 2. There will be no parenthesis unless it is needed. `foo bar, 42` means `foo(bar, 42)`, and `foo bar 42` means
> `foo(bar(42))`.
>
> I leave this project at every horizontal split. You are recommended to do so, think about why the hell you keep
> reading (for me writing), and come back just like me.

For my first step, I want to make a simple 2048 web-page based game. It should listen to user's keyboard (or screen if
the user visits with a moblie device), make some reaction when user make actions. In the future, an AI may be
introduced (forget it), and the reaction maybe respond to actions made not by user, by the AI which would be another
part of script. So, pre anything, I need to register a listener, so that I will be able to make my reaction.

  mainLoop = ->
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
    keys = w: UP, a: LEFT, s: DOWN, d: RIGHT
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

------------------------------------------------------------------------------------------------------------------------

Good morning! Just slept for a whole night and continue gushing. It seems that it is clear enough to write a generator
after the explain above, but I'm going to start from a easier work: the utility method `whenAnyOfTheseKeysPressed`. It
accept a dict, and whenever user presses any key that is a key in this dict, the callback argument will be executed
with the value of that key.

  whenKeyPressedWithRealWorld = (onpress) ->
    (map, callback) ->
      onpress (char) ->
        callback map[char] if char of Object map

  #whenAnyOfTheseKeysPressed = whenKeyPressedWithRealWorld (callback) ->
  #  document.addEventListener 'keypress', (event) ->
  #    callback event.key

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
out that they are actually different things: the outer one is the lambda we passed to `onpress` in place in
`whenKeyPressedWithRealWorld`, which accepts a char and do something with it, and the inner one is the lambda we use
to recive the DOM event from real world. The extra arguemnts do not make code cleaner, but more confusing.
* the defination of `whenAnyOfTheseKeysPressed` becomes a sentence now! Ignore the double "real world", you can read
it as normal English. Just as the same of something above: I want to _describe_ this process, to illustrate the
function of each method, and forget the detail of their implementation as well as I can do.

One of the disadvantage of this style is that `realWorldOnKeyPressed` becomes uglier a bit. Pretend you cannot see it.
Actually, everything inside `realWorld...` is ugly, is not important, and is not something we should care about.

Let's start writing the reaction generator before everybody falling asleep.

  reactionGeneratorWithCheckerboard = (dir, board) ->
    collector = new ReactionCollector
    nextBoard = manipulateCheckerboard dir, board, collector.collect
    [collector.reaction, nextBoard]

This may be the most important framework of the whole script. We got a `...WithCheckerboard` method here, just like
the `...WithRealWorld` method before. There are several states that change from calling to calling in this program.
I divide them into three parts, and give each part a method:
* register a listener for user action events. This changes real world.
* make a move on the checkerboard. This changes checkerboard.
* apply the reaction to user interface. This changes user interface (also real world).

If I want to control these side effects in the strictest way, I would make all of them part of arguments and return
values, and maybe give them a type. Right, that's why I call them project _hsjs_. The "hs" stands for haskell. Here
is an example of how haskell handle side effect:

```haskell
getLineWithPrompt :: String -> IO String
getLineWithPrompt prompt = do
  putStrLn prompt
  getLine
```

The `IO` data constructor determines that there is cost of side effect if you want to get the result. When this method
returns, nothing happened, no side effect. Everything only takes place if you make some usage of the string inside this
`IO` box, such as bind this value into `map length` (which has type `IO String -> IO Int`)... all right, still nothing
happens, because the result is still in a `IO` box. Actually, because of the concept of
[monad](https://en.wikipedia.org/wiki/Monad_(functional_programming), there's no way for a programmer to extract the
value out of the box. The only chance is to define a method called `main`, which would has type `IO ()`. The language
runtime will calculate the value inside the box, which will absolutely be a unit (`()`), so the only meaning to do so
is to make the side effect you want during the calculating. And beside this, everything is pure. All you __can__ do is
to "collect" the side effects from every corner of code, with the tools haskell provides to help you to grub several
side effects to a bigger one, such as the do-notation above.

Familiar? This is just the way I design the generator! The changes I would like to make which apply to user interface
will be spreaded everywhere inside to logic of `manipulateCheckerboard`, and what the worse, they will not be discovered
in the same order as they should be performed (which will be discussed below). So I will collect them with a `collector`
object. They are froozen inside the `collector`, and are only alive when the `reaction` property is applied to the user
interface.

The last thing that needs to be noticed is that through this is a `...With...` method, it is not pure at all. the
`collector` is a mutable variable. However, it is possible to refactor this method to a pure version, just by
introducing some haskell tools like `<$>`, `>>=`, `<*>`... and done, I can pass an "empty reaction" into the
manipulation method and get a full one in return. But that is hard. That is why I dropped the old `src.js` and so on.
If you check the git history you will find out that I have tried to build a haskell world in the past time. I was not
on the edge of failure, but it became too hard, too hard to have fun with it. Also, there is something pretty called
[purescript](http://www.purescript.org/) exists, and I will never beat it on my own. Just remember:

> Haskell-style javascript does not mean haskell in javascript syntax, but javascript with haskell spirit.

Time for lunch ^_^. See you when I figure out the easiest way to go on.

------------------------------------------------------------------------------------------------------------------------

All right. Today is the third day working on this easy haskell-style js 2048 project. Remind myself again. Keep it
simple, easy, stupid the best. Try to __describe__ it as much as I can.

I am not going to define the reaction generator now, because that would require a checkerboard (probably a class of it).
I am going to _use_ that class first, and then I will know what functions I need to provide in that class. So as the
collector, if you still remember.

Update: Notice the `->` down there. This would delay the resolve of `manipulateCheckerboard`. I have to do this because
There is no `splitCheckerboardAndMap` for now, and browser will complain if I not only _use the name_ of a method, but
also _apply_ it. God, everybody know I won't use this method until I define the `split...` thing! Stupid JS.

  manipulateCheckerboard = -> splitCheckerboardAndMap extrusionEachColumn

The method `extrusionEachColumnWith` will accept a list (actually array) of numbers and "extrude" them to the front.
This is related to the rule of 2048. Think about a situation like this:

```
8 | 8 | 4 |
8 | 4 | 4 | 2   ^
4 | 2 | 4 | 2   |
4 | 2 |   |
```

If the player makes a slide toward up now, we can "split" the checkerboard into columns, and each column will not affect
the result of others. Then we "map" a transformation to each column, bring them together and get the new checkerboard.
This is how `splitCheckerboardAndMap` works. It splits the checkerboard in a proper way according to the direction, and
feed the callback with every column. Finally, combine the results of the mapped callback and get
the final result. There are several difficulties in this method:
* it is also responsible to judge whether the action player made really changed the checkerboard. If so, then a new
random number should be generated at a random position.
* `extrusionEachColumn` does not know anything about the original position of the column it gets. So it needs a wrapped
reaction collector which just require a few infomation that `extrusionEachColumn` can provide, and where is the rest
infomation? Yeah. So it is also work of `splitCheckerboardAndMap` to construct this faked collector.

Let's try the easier one first. What is the rule insife `extrusionEachColumn`? Observe the four column in above
checkerboard. The right most one is easy: just combine two "2" and get a "4" on the top. If we write the blank space
as a "0" then this shoud be:

```
(<-) 0 2 2 0 ==> 4 0 0 0
```

The single left arrow indicates the direction. The second column from the right has three "4" in it, and we should
combine two of them and move the rest:

```
(<-) 4 4 4 0 ==> 8 4 0 0
```

The third column from the right looks like a combo! Should we get a "16"? No. We should stop after the combination of
the "2"s. Just like this:

```
(<-) 8 4 2 2 ==> 8 4 4 0
```

And the last one. First we should combine the two "8"s. Then move and combine the two "4"s.

```
(<-) 8 8 4 4 ==> 16 8 0 0
```

It seems that there are millions of prossibility! Actually, there is a "general" algorithm for this problem.
1. Start from the second position. I will quote it as "current position".
2. Check whether the current position is not emtpy. If it is empty, then jump to step 8.
3. Mark the left neighbour of current position as "destination".
4. Keep move the destination left forward until we reach a position which is not empty. (Maybe this step can be ignored
if the destination is not empty from the start.)
5. Now we should have number both on current position and destination, or we have reach the edge during finding the
destination. If so, them _move_ the number on current position to the edge (the first position), and goto step 8.
6. ...Now both current position and destination should have number on them. If the number is the same, and the
destination has not been marked as "merged", them _merge_ the number on the two positions and write it back to
destination. The current position would be empty now. Goto step 8.
7. Whatever the reason you reach this step, just move the destination backward. If the destination is still not the
same position of the current one, then _move_ the current position's number to destination, which should be an empty
place. Otherwise, just do nothing.
8. Mark the right neighbour of current position as the new current position. Repeat until the last number's work is
done.

There are two kinds of "marking" above. The two positions are the infomation in one turn (from 1 to 8), and will be
reset every turn; but the merged positions keeps this status till the end. Try this algorithm in above cases to prove
its correctness, and here is the method based on it.

  extrusionEachColumn = (vect, record) ->
    len = vect.length
    merged = (no for [0..len])
    changed = no
    for cur in [1...len]
      if vect[cur] == 0 then continue

      found = no  # have found the destination?
      for dest in [cur - 1..0]
        if vect[dest] == 0 then continue
        found = yes
        if vect[dest] == vect[cur] and not merged[dest]
          record MERGE, cur, dest, vect[cur]
          merged[dest] = yes
          changed = yes
          vect[dest] += vect[cur]
          vect[cur] = 0
        else if dest + 1 != cur
          record MOVE, cur, dest, vect[cur]
          changed = yes
          vect[dest] = vect[cur]
          vect[cur] = 0
      if not found
        record MOVE, cur, 0, vect[cur]
        changed = yes
        vect[0] = vect[cur]
        vect[cur] = 0

    [vect, changed]

Wow, so long! Longer than the sum of the code I have written! There are several chances I can make it shorter and more
"fluent", such as modify the `vect` in `record` calling, since they are both provided by parent, but that may be
confusing.

The result of this method is not only the new vector and the "side effect" it makes, but also a flag called `changed`,
indicates whether there is changing in this column. So the tracking job left for `splitCheckerboardAndMap` is only
calculate a logical or on each `changed`. Great!

  splitCheckerboardAndMap = (mapped) ->
    (dir, board, collect) ->  # if you forget this, scroll back and see how we used `manipulateCheckerboard`
      size = board.size
      range = if dir == UP or dir == LEFT then [0..size] else [size..0]
      changed = (no for [0..size])
      if dir == UP or dir == DOWN
        for col in [0..size]
          vect = board.grid[col][y] for y in range
          record = (action, from, to, num) ->
            collect action, [col, from], [col, to], num
          [nextVect, changed[col]] = mapped vect, record
          board.grid[col][y] = nextVect[y] for y in range
      else
        for row in [0..size]
          vect = board.grid[x][row] for x in range
          record = (action, from, to, num) ->
            collect action, [from, row], [to, row], num
          [nextVect, changed[row]] = mapped vect, record
          board.grid[x][row] = nextVect[x] for x in range

      if changed.some Boolean  # any column changed
        board.addNumber collect  # **stop the game here maybe**
      board

  manipulateCheckerboard = manipulateCheckerboard()  # Again, stupid JS

Have to say that Coffee is great at simplify and unify, just check how pretty the first and the last line of two `for`.
This code is compressed in a naive way, because I have written this logic for many times and figure this out. You may
want to check [the original implementation of this move method]
(https://github.com/gabrielecirulli/2048/blob/master/js/game_manager.js#L130). I feel more confident than the first
saw of that maybe two years ago. But still nervous since this code did not vary since I thought it out.

Something to notice: the `**stop the game here maybe**` comment line. Here we add a new number to the checkerboard,
that would make user interface change centainly. At the same time, I will check whether the game is still alive in this
method. The word "alive" means the player can still move after the random number is added. If the game is over, then
some more side effect will be collected, such as display "The game is OVER!", turn off the screen and make player's
device exploit... I mean, suggest the player to share this game or something... So in a word, this method `addNumber`,
is not that simple as adding a number and done. This can be treated as a mistake that in the previous designing I did
not think about how this game would end too much. So that the registry of this reaction generator seems to be forever.
Actually not. The binding will be removed after the game is over, and this job will be done here, in this `addNumber`.

Okay, enough for today. See you tomorrow.

------------------------------------------------------------------------------------------------------------------------

There is no "tuple" in javascript (coffee, either). So I have to simulate it with short array. When I call `collect`
the second and third arguments have structure `[x, y]`. This will be the default way for passing position in this
script.

Actually, I have done this job already! No kidding, all the update-the-checkerboard logic are in the two methods above.
There are just some more utils to write down. The most compicated one may be the collector. I have to use a class and
some other "OOP" things because it needs local state, or I need to use an iterative method, which take a collector as
its argument, and return the new one. We do that all the time in somewhat "functional programming". All right. No more
talk. Now you happy the Rubist!

  class ReactionCollector
    constructor: ->
      @after = @move = @merge = @advent = (done) -> done

    reaction: (@ui) ->
      (@move @merge @advent @after ->)()

Hey, writing readless thing again! Don't worry, let's try it first.

  (->
    rc = new ReactionCollector
    vec = []
    pushAndDoneFactory = (num) ->
      (done) ->
        ->
          setTimeout ->
            vec.push num
            done()
          , 0
    rc.move = pushAndDoneFactory 0
    rc.merge = pushAndDoneFactory 1
    rc.advent = pushAndDoneFactory 2
    # I forgot the `@after` in the first time, so there's no `after` line here.
    rc.reaction()
    setTimeout ->
      (throw new Error unless vec[i] == i) for i in [0..2]
    , 10
  )()

This example tells us two things. First, it shows you how to use the `ReactionCollector`, and you may figure out how
to implement `collect` if you are clever enough. Second, it reveals that I am not suitable for writing code today,
because I cannot write anything easy now... Sorry & Goodbye.

------------------------------------------------------------------------------------------------------------------------

Ok. I come back to explain what I have done. Firstly, the reaction applies to user interface can to divided into three
parts: _move_, _merge_ and _advent_. Notice that I am just talking about the checkerboard. Several other reactions such
as update the score when a merging is happening will be inserted into the proper position of this three stages. The
most important thing is that all the reactions that happen in the same stage will be executed __simultaneously__, and
every reaction that happens in the next stage will not start until all the reactions in the previous stage have been
done. Recall the things happen during your sliding on the screen (or maybe play the 2048 and observe it). Totally, there
are following reactions:
1. Move stage: every number block move to their destination. Some of them may be overlapping.
2. Merge stage: the two number block on the same position will update theirs content and become a new block. The score
will be updated, too.
3. Advent stage: new number block will be appeared on the checkerboard.
4. After stage: if the game is ending, them the screen will change to the game over scene.

Some of these stages can be passed. Such as there's nothing happened in after stage if the game is not ended, and all
the stages can be passed if the action player made have not changed to checkerboard.

------------------------------------------------------------------------------------------------------------------------

Cannot sleep today, so I come back at 3 a.m. Compare the two `move` I have defined above:

```coffeescript
# done :: () -> ()
move1 = (done) -> done  # id
move2 = (done) ->
  ->
    # do something and...
    done()
    # something more...
```

The second one is a part of `pushAndDoneFactory`, try to pass a number into it and find out what it would return. First,
change the first version into the following equivalent form:

```coffeescript
move1 = (done) ->
  ->
    done()
```

They are not actually the same, I know it. But if the only thing you would perform on `move1` is to call it (I cannot
think out some more things you are able to do), then there will be no differece between this two forms. Just treat it as
a special kind of point-free style (actually "currying" is a more proper way to introduce it). Now the `move1` and the
`move2` are in the same shape: if we use `()` to represent something like `void` in C/C++, and `() -> ()` will mean some
kind of method that accepts no argument and return nothing, just executes and becomes dead. Then, this two `move` can
be treated as a method that accept a `() -> ()` kind method as its argument and return another `() -> ()` as the result.
Only difference between them is that `move1` does not modify its argument: it returns the very same method that pass to
it. We usually give the name `id` (stands for "identity") for this method... yeah, in haskell. The method `move2` would
accept a simple `() -> ()` method and return a more complicated method. And during the executing of that complicated
method, the simple one would be executed somewhere properly. This way of writing code is usually called "lambda
calculus", which means there are a lot of lambda in the code, and (almost) all of the variables represent something
acts like a method, but not a normal number or string or something else. The "method" is not the same concept like
"procedure" or "function" in other languages, which mean something big and heavy, maybe relates to stack more some other
crazyness. No at all. A method just means the code inside of it will be _delayed_, the result of them, along with the
side effects they make, will be stored, and only be extracted when you really need them in the future, just like the
result of `move2`. Browser finds out that `move2` returns a lambda, and done. It prevents any futher interpreting that
performs on the result of `move2`. And if you apply that result as the argument to another calling on `move2`, or maybe,
`move42`, then its evaluating will be delayed again, as it becomes a deeper layer of the onion. OMG how I wrote so much
junk... forget it.

Look inside the defination of `reaction`, the part `@after ->` firstly. The arrow `->` here is a method actually (crazy
coffee, unh?), which accept no argument, do nothing, and return nothing. Passing this trivial method as `done` into
`@after`, which is the same as the `move1` above, you know what is happening now. The whole thing become a new 
`() -> ()` method! Let's move backward. This `() -> ()` is passed to `@advent` as its `() -> ()` argument. What will
happen? A new, bigger `() -> ()` is the result of this expression. Notice that this bigger method can be not trivial,
since we may define `@advent` similiarly to `move2`. The process repeats for a couple of times, and finally, I surround
the whold expression with a pair of parenthesis and boom! Execute it! According to `move2`, the "do something" part in
`@move` would be the very first part of code to be executed, and then its `done` is called, which would be exactly
the `@merge` property. Since there is actually no `something more` part in all of these four property, so actually it
means:

> First do the moving things, and then merging, adventing, and finally everything after them.

Look at this line of code again:

```coffeescript
(@move @merge @advent @after ->)()
```

Not as bad as we thought! I know that it would be "easier" if I write some utils and refactor it like:

```coffeescript
firstDo(@move).andThen(@merge).andThen(@advent).andFinally(@after).andDoIt()
```

But all of this frameword would be wasted if I will not use it again. And another reason is that this sequential model
is very useful so it has been implemented many times, for example the everybody-like `Promise`. And the real reason is
that I am lazy. Shame on myself.

And actually the four-verbs version is very descriptive already, right? (Say yes, please. I'm begging you.) The only
work that left for us about this collector class is that define that `collect` method, which accept some infomation,
and then turn one of this four `() -> ()` methods into another bigger `() -> ()` method and replace the old one. By the
way, the methods work like `move2` and `collect`, that accept a method and some infomation optionally, and return a new
method, are called high order methods, and more strictly, "combinators" if they do not require any information outside.
For example, suppose we have something like this:

```coffeescript
plusFactory = (addition) ->
  (func) ->
    (arg) ->
      func(arg) + addition
```

Then `plusFactory(42)` is not a combinator, because how it manipulates the execution of `func` depends on the value of
`addition`, which is `42` exactly. One of the most famous example of combinator would be the Y-combinator, which is able
to "construct" a recursive method without any recursive calling. Suppose you have a Y and a method like this:

```coffeescript
Y = # ... something crazy, ignore it
partFac = (n, self) -> if n == 1 then 1 else n * self(n - 1)
fac = Y partFac
```

And here the method called `fac` will be a real factorial method! `fac(3)` returns `6`! As a simple example, the method
`move1` aka `id` is a combinator, but the method `move2` is not sure, it depends on how you fill the "do something"
part. Ok, ok, too much talk again. It is not suitable to work at... umm, 4 a.m. now, because you would make too many
mistakes and it will become an action of wasting time 100% possible. So see you tomorrow.

------------------------------------------------------------------------------------------------------------------------

I have not memtioned that `@ui` argument for even once. Why? I just add it! I forgot that the reaction will be applied
on a user interface... but if the `@move` things accept one more argument represents user interface then the simple
`(done) -> done` has to be changed to `(done) -> (ui) -> done ui`. This may be a more "functional" style, but it is not
suitable here because it is not easy enough (and I have to modify the words above). So a little OOP things are not hurt,
since this whole reaction collector is a class already.