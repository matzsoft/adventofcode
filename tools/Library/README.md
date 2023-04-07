# Purpose

The `Library` contains all the classes, structs, and functions used by more than one of the packages within this repository.  There is a package for the `adventOfCode` tools and one for each of the daily problem solutions.

# Description of Files

## AOCutils.swift

This file is needed by every single package. It provides the framework for running a daily problem solution including finding input and test files. It also includes `RuntimeError` for throwing errors.

## Assembunny.swift

This is a utility for 2016.  It is used by 3 problems: 12, 23, and 25.

## BlockLetter.swift

Many problems across several of the years essentially generate an image as their output.  The image consists of a message in block letters that must be converted to text to be entered into the `adventofcode.com` website.  This provides the tools to do this, including support for multiple fonts.

## Coordinates.swift

Many of the problems require the use of spatial coordinates and movement through coordinate spaces. This file provides support for points, rectangles, and directions in 2D, 3D, and 4D. Also provided is support for 3d matrix manipulation of coordinate transforms.

## Coprocessor.swift

Two of the problems in 2017, 18 and 23, use the `Coprocessor` computer.

## Crypto.swift

Day 4 in 2015 and days 5, 14, and 17 in 2016 make use of the MD5 hash functions provided here.

## Extensions.swift

This file provides some miscellaneous functions used in a variety of places.

## Glob.swift

This file contains a single function `glob` which is a more friendly interface to the system `glob` function.  This function is used by every package.

## Intcode.swift

In 2019 most of the problems make use of the `Intcode` computer.

## KnotHash.swift

In 2017 two problems, 10 and 14, required a `KnotHash`.

## WristDevice.swift

The year was 2018.  This file provided support for 3 problems: 16, 19, and 21.
