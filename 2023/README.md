## TODO

### Day 12

Part 2 needs to be sped up. One potential way is to recognize that if all the arrangements in the first fold end the same way, there is no need to calculate the other folds.

### Day 17

My attempts to use Dijksta's algorithm and A* both failed in the same way. They produced non-deterministic results. I had to resort to the subreddit to solve this one. Perhaps I should revisit.

### Day 19

I would like to speed up part 2. I believe one possible way is to replace the use of Set with a new type that behaves the same externally but uses a list of Ranges internally.

### Day 21

Part 2 is now a general solution for any "real" data. It does not work on the examples and still takes over 2 seconds to run.

### Day 23

Reducing the data to a network of significant nodes gave a massive speed up. But part 2 still takes 11 seconds. Making it a directed graph reduces the run time to 2.5 seconds.

### Day 25

Solution uses Monte Carlo and runs acceptably fast. It might be worth finding a deterministic solution.