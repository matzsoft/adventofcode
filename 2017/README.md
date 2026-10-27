## Day18 - Duet
In this one you are presented with some odd assembly code and are tasked with determining its behaviour.  You could write an interpreter and run the code, but this is too slow particularly for part2.  Instead I reverse engineered the code, pulled the parameters from within it to produce the answers.  An interesting approach would be to write a code optimizer and run the optimized code.
## Day22 - Sporifica Virus
This is a cellular automata problem.  You are presented with an infinite grid of networks nodes, some infected and some clean.  There is a virus carrier that travels the grid infecting or cleaning nodes according to some rules.  To solve the problem, determine the state of the grid after a given number of moves by the virus carrier.  I implemented the grid using a sufficiently large array.  It would be interesting to use a dictionary for the grid instead.
## Day23 - Coprocessor Conflagration
Another problem with strange assembly code that is too slow if interpretted.  I reverse engineered the code to get the answers but creating a code optimizer might be a nice challenge.
## Day25 - The Halting Problem
Wow.  I got to simulate a Turing machine.  Sadly it runs too slowly and I would like to speed it up.