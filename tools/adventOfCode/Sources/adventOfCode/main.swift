//
//  main.swift
//  adventOfCode
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser

struct adventOfCode: ParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for working on Advent of Code problems using Swift Package Manager.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [
            Make.self, Open.self
        ]
        
        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
    )
}

adventOfCode.main()
