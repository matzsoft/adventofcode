## Day 05 - How About a Nice Game of Chess?
In this one you must find a password by repeated application of MD5.  My brute force solution is too slow.  I should investigate ways to speed it up.
## Day 13 - A Maze of Twisty Little Cubicles
In this one you have to navigate a maze.  My approach fills in an array with the maze data, making sure it is large enough to solve the problem.  It might be interesting to generate the maze as needed to compare the run times.
## Day 14 - One-Time Pad
In this one you have to generate keys for a one-time pad using MD5.  My part2 takes almost 25 minutes to run.  There must be some way to speed it up.
## Day 16 - Dragon Checksum
In this one you have to fill some disks with non-suspicious data.  The answers are the checksum of that data.  My part2 takes 16 hours to run.  This is despite considerable reduction in the amount of computation required.  I need to find a way to get this down to a reasonable running time.