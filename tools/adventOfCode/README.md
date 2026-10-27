# adventOfCode

**adventOfCode** is a tool for helping with the developtment of solutions to [Advent of Code](https://adventofcode.com) problems using the [Swift Package Manager](https://swift.org/package-manager).  It facilitates the creation of new problem solutions, working with them in Xcode, and maintaining code that is common to many solutions in a `Library`.

## Overall Directory Structure

I have a directory for my Advent of Code solutions called adventofcode.  It contains a subdirectory for each year of problems and a tools directory.

### Tools Directory

The tools directory which currently has one tool **adventOfCode**, a **Library** directory, and a support directory **figlet**.  **adventOfCode** contains a Swift package for a command line tool to work with puzzle solutions. **Library** contains a Swift package defining a library of code referenced elsewhere. **figlet** contains "font" files that aid with problems that generate ASCII art block letters as their output.

### Year Subdirectories

The year subdirectories should ultimately contain one folder for each problem (`day01` through `day25`), a directory named **input** and a directory named **testfiles**.

On occasion after solving a prolbem I want to explore alternate solutions. In order to not interfere with the working solution a folder can be created, e.g. `day07-experimental`, to work with. The "-" and the following label are required for the **adventOfCode** tool to work with it.

The **input** directory contains the problem data for each problem.  For example the problem data for day07.swift is in `input/day07.txt`.  The **testfiles** directory contains any test data for each problem.  For example any test data for day07.swift would be in `testfiles/day07*.txt`.

The folder for a problem, e.g. `day01`, will initially contain a Package.swift file and a Sources folder. The Sources folder will contain a main.swift file. These files can be modified to provide the solution to the problem. For example some problems require access to an external library. This will require modifications to Package.swift.

#### Problem and Test Data

The format of the problem and test data is the same.  They consist of a header, a separator, and the problem data from the Advent of Code website.

The first line of the header is the expected result for Part 1 of the problem.  The second line of the header is the expected result for Part 2 of the problem.  Either or both of these first two lines can be blank.  A blank line indicates that the expected value is either not yet known or irrelevant (some tests are only valid for one part of the problem).

The remaining lines of the header are optional.  They are used for extra parameters that relate to the data.  For example some tests use a different limit than the actual problem.

The separator line is just a line containing only one or more minus signs.  It serves to mark the end of the optional part of the header.

## Operation of the Tool

**adventOfCode** should always be run from one of the year directories.  For example:

```
# cd ~/Development/adventofcode
# mkdir 2021
# cd 2021
# adventOfCode make day01
```

The **adventOfCode** tool has a subcommand for each of its tasks.  They are make and test.  These subcommands take as their first argument, the package identifier.  A package identifier may be:

1. A number between 1 and 25.  Leading zeroes are permitted.
1. A package identifier of type (1) preceeded by the string "day".
1. A package identifier of type (1) or (2) followed by a "-" and a label.  The label indicates an alternate solution for that day.
1. A package identifier of any other type followed by a file extension.  The file extension is stripped away and ignored.

### Make subcommand

The make subcommand is used to create a new problem solution skeleton.  It takes a single argument, the name of the solution.  The command `adventOfCode make day12` performs the following actions:

1. Create any needed folders that do not already exist.
1. Create the day12/Package.swift unless it already exists.
1. If the problem is not yet released, wait until it is, presenting a count down.
1. Display the problem's webpage in Safari.
1. Creates the day12/Sources/main.swift file unless it already exists.
1. Creates the input/day12.txt file unless it already exists.
1. Open day12/Package.swift in Xcode.

### Test subcommand

The test subcommand is a rudimentary tool for creating test files. It takes an adiitional, optional argument called suffix. The suffix argument can be any string, but is normally a number or a short descriptive word. The values for the test file are read from stdin, with prompts to stdout. The filename for the test file is derived from the command line arguments.

For example, the command `adventOfCode test 12` will generate a file named testfiles/day12.txt.

Alternatively the command `adventOfCode test 12 7` will generate a file named testfiles/day12-7.txt.