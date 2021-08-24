## Day 13 - Care Package
This is the Breakout game implemented in Intcode.  My solution provides animation of part2, if run in a terminal that supports VT100 emulation.  It would be nice to produce an animated image of that as well.
## Day 17 - Set and Forget
This is the one where the droid has to navigate the scaffolding. For part2, I analyzed my input and detected the patterns by hand.  I would like to implement a version that programmatically detects the patterns.
## Day 18 - Many-Worlds Interpretation
This is the one with the maze with locked doors.  You need to find the matching keys to navigate fully.  Since my code is quite complex and too slow, I probably am missing something.  Need to revisit this one.
## Day 19 - Tractor Beam
In this one you need to figure out how the tractor beam works.  I need to confirm that my part2 works on any input.
## Day 21 - Springdroid Adventure
In this one you have to guide the droid to safely jump over wholes in the hull.  I have used code to partially analyze the problem and then finished the analysis by hand to get the results.  I would like to completely automate the process.  I started to do this with day21a but did not complete it.
## Day 23 - Category Six
In this one you monitor the traffic in a network of interconnectd Intcode computers.  My part2 takes too long to run.  I would like to speed it up.
## Day 25 - Cryostasis
This probably is my favorite problem.  It is a classic text adventure game implemented in Intcode.  My initial solution was to implement a wrapper around the Inccode that allowed me to interact with the game and play it.  To make that easier I added the ability to give an initial sequence of commands so that I didn't have to type them over every time I had to restart.

Once I completed the game manually, I could set the initial commands so that they fully solved the game.  Of course this approach only works on my input data.

So I also implemented a general solution that plays the game automatically with minimal assumptions.  I also left in the ability to play manually.

But even now there are more fun things that I could do.  I could generate an image file with a map of Santa's ship.  Once I have that I could generate an animation of the solution.

I could reverse engineer the Intcode.  Then use that to determine the structure of Santa's ship and hence the commands needed to win. Or I could figure out how to extract the solution directly from the input.

I have already made some progress on that last one.  I found the code that sums the weights of the items you are holding when you step on the pressure plate.  This revealed that the solution is the sum of those weights.  Next I have to determine how they conclude that the sum is the correct one.  They have obfuscated that so I need to dig deeper.