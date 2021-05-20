# adventOfCode

**adventOfCode** is a tool for helping with the developtment of solutions to [Advent of Code](https://adventofcode.com) problems using the [Swift Package Manager](https://swift.org/package-manager).  It facilitates the creation of new problem solutions, working with them in Xcode, and maintaining code that is common to many solutions in a "library".

## Overall Directory Structure

I have a directory for my Advent of Code solutions called adventofcode.  It contains a subdirectory for each year of problems and a tools directory.

### Tools Directory

The tools directory which currently has one tool **adventOfCode** and a support directory **figlet**.  **adventOfCode** contains a Swift package for a command line tool to work with puzzle solutions.  **figlet** contains "font" files that aid with problems that generate ASCII art block letters as their output.

### Year Subdirectories

The year subdirectories should ultimately contain one file for each problem (day01.swift through day25.swift), a directory named input, and a directory named tests.  The input directory contains the problem data for each problem.  For example the problem data for day07.swift is in input/day07.txt.  The tests directory contains any test data for each problem.  For example any test data for day07.swift would be in tests/day07*.txt.

The format of the problem and test data is the same.  They consist of a header, a separator, and the problem data from the Advent of Code website.

The first line of the header is the expected result for Part 1 of the problem.  The second line of the header is the expected result for Part 2 of the problem.  Either or both of these first two lines can be blank.  This indicates that the expected value is either not yet known or irrelevant (some tests are only valid for one part of the problem).

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

The **adventOfCode** tool has a subcommand for each of its 3 primary tasks.  They are make, open, and close.

### Make subcommand

The make subcommand is used to create a new problem solution skeleton.  It takes a single argument, the name of the solution.  The command `adventOfCode make day12` performs the following actions:

1. Creates the day12.swift file.
1. Creates the input/day12.txt file.
1. Simulates an `adventOfCode open day12.swift` command.

### Open subcommand

The open subcommand takes a problem solution Swift file and creates a Swift Package Manager setup for it.  Then Xcode is opened for that package.  To continue the example from above, the command `adventOfCode open day12.swift` performs the following actions:

1. Creates a subdirectory called day12.
1. Creates a Swift Package Manager structure within the day12 directory.
1. Copies day12.swift into the correct part of the Sources directory as main.swift.
1. Copies all the library files into place beside main.swift.
1. Opens the package in Xcode.

### Close subcommand

I use the close subcommand when I have finished working on a solution, or perhaps want to make a preliminary commit.  It pulls the changed files from the Swift Package Manager setup and then deletes it.  For example, the command `adventOfCode close day12` performs the following actions:

1. If the main.swift file is different than day12.swift in the year directory, then main.swift is copied over day12.swift.
1. For all other files in the Sources of the package do the following:
    - If the corresponding file does not exist in the library, copy it to the library.
    - If the corresponding file in the library is different, copy the package file to the library.
1. Delete the day12 directory.

## The Library

The source code for the **adventOfCode** tool contains a Library folder.  This folder contains all the code that is used by multiple problem solutions.  An `adventOfCode open` command copies all files from this Library folder into the newly created package.  An `adventOfCode close` command copies and changes to those files back into the Library folder.
