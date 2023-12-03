//         FILE: Test.swift
//  DESCRIPTION:  - Implements the test command.
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/2/23 2:31 PM

import Foundation
import ArgumentParser
import Library

extension AdventOfCode {
    struct Test: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create a new problem solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String

        @Argument( help: "Test file suffix." )
        var suffix: String = ""
        
        mutating func validate() throws {
            if let determined = determinePackage( package: package ) {
                package = determined
                return
            }

            throw reportFailure( "Cannot determine package from \(package)" )
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let testfile = "testfiles/\(package)\( suffix == "" ? "" : "-\(suffix)").txt"
            
            if fileManager.fileExists( atPath: testfile ) {
                throw reportFailure( "Test file '\(testfile)' already exists." )
            }
            
            let part1 = getString( prompt: "Enter part1 solution", preferred: "" )
            let part2 = getString( prompt: "Enter part2 solution", preferred: "" )
            let extras = getLines( prompt: "Enter extra header lines", blanksOK: true )
            let dataLines = getLines( prompt: "Enter the input data" )
            let input = AOCinput(
                part1: part1, part2: part2, extras: extras, lines: dataLines, filename: testfile )
            
            try input.write()
        }
    }
}
