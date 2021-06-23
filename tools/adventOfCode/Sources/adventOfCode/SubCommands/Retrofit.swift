//
//  Retrofit.swift
//  Implements the retrofit subcommand
//
//  Created by Mark Johnson on 6/14/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser
import Mustache

extension adventOfCode {
    struct Retrofit: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Convert all .swift files in a directory to use new Run* method names."
        )
        
        func validate() throws {
        }
        
        func run() throws -> Void {
            for file in glob( pattern: "*.swift" ) {
                try updateSwiftSource( swiftFile: file )
            }
        }

        func updateSwiftSource( swiftFile: String ) throws -> Void {
            var oldSource = try String( contentsOfFile: swiftFile ).components( separatedBy: "\n" )
            var oldLines = [String]()
            var newLines = [String]()

            for ( index, line ) in oldSource.enumerated() {
                func replace( target: String, with replacement: String ) {
                    if let range = line.range( of: target ) {
                        let newLine = line.replacingCharacters( in: range, with: replacement )
                        
                        oldLines.append( line )
                        newLines.append( newLine )
                        oldSource[index] = newLine
                    }
                }
                    
                replace( target: "runTestsPart1", with: "runTests" )
                replace( target: "runTestsPart2", with: "runTests" )
                replace( target: "runPart1", with: "solve" )
                replace( target: "runPart2", with: "solve" )
            }
            
            if oldLines.isEmpty {
                print("\(swiftFile): no change")
            } else {
                let prefix = String( repeating: "-", count: ( 79 - swiftFile.count ) / 2 )
                let suffix = String( repeating: "-", count: ( 78 - swiftFile.count ) / 2 )
                
                print( prefix, swiftFile, suffix )
                oldLines.forEach { print( $0 ) }
                print( String( repeating: "-", count: 40 ) )
                newLines.forEach { print( $0 ) }
                
                if askYN( prompt: "Proceed", expected: true ) {
                    let swiftFileSource = oldSource.joined( separator: "\n" )
                    try swiftFileSource.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
                }
                else {
                    throw ExitCode.failure
                }
            }
        }
    }
}
