# adventofcode
These are my solutions to the [Advent of Code](http://adventofcode.com/) problems.  There is a directory for each year and a tools directory.

I solved the 2015 problems in Perl, but decided to switch to Swift for 2016.  For 2021 I have created a new structure, see `tools/adventOfCode/README.md` for details.  I have now converted all the 2020 and earlier files to Swift and the library structure.

Each year directory contains a `README.md` file. At the start of that file is a table showing the results for the problem solutions for that year. The table format is fairly simple but some explanation will be useful.

The first column is the solution name, usually something like **day07**.

Columns 2 and 3 are the run times for Part 1 and Part 2. The background of the column indicates status.
- An empty column indicates no correct solution for that part of that problem.
- A green background indicates a correct solution that runs in under a second.
- A yellow background is for a correct solution that takes more than 1 second but less than 10 seconds to run.
- A red background shows a correct solution that takes more than 10 seconds to run.

The 4th and 5th columns show the overall status of the tests for Part 1 and Part 2. Then symbols in the columns mean:
- ✅ = All tests passed.
- ❌ = Some tests failed.
- ⚠️ = There are no tests for this part of this problem.