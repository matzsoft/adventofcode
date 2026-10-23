//         FILE: Convert.swift
//  DESCRIPTION: adventOfCode - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 10/22/26 5:22 PM

import Foundation
import ArgumentParser
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Convert: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Convert an adventOfCode year directory to the new structure."
        )
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let swiftFiles = glob( pattern: "*.swift" )
            guard swiftFiles.count == 12 || swiftFiles.count == 25 else {
                throw RuntimeError( "Directory must contain 12 or 25 *.swift files." )
            }
            for number in 1 ... swiftFiles.count {
                let ( _, _, package ) = try determinePackage( package: String( number ) )
                
                try fileManager.removeItem( atPath: package )
                _ = try openCreateFiles( package: package, display: false )
                try testSolution( package: package )
                
                guard fileManager.changeCurrentDirectoryPath( ".." ) else {
                    throw RuntimeError( "Can't change directory to .." )
                }
                
                print( "Converted \(package)" )
            }
        }
    }
}


func testSolution( package: String ) throws -> Void {
    let fileManager = FileManager.default
    let buildAargs = [ "swift", "build" ]
    let runAargs = [ "swift", "run", "--skip-build" ]
    let buildLog = ".build.log"

    if !fileManager.fileExists( atPath: buildLog ) {
        fileManager.createFile( atPath: buildLog, contents: nil, attributes: nil )
    }

    let fileHandle = try FileHandle( forWritingTo: URL( fileURLWithPath: buildLog ) )
    defer { try? fileManager.removeItem( atPath: buildLog ) }

    let buildStatus = try shell( stdout: fileHandle, stderr: fileHandle, buildAargs )
    try? fileHandle.close()
    if buildStatus != 0 {
        _ = try shell( "cat", buildLog )
        throw RuntimeError( "Failed to build solution for \(package)." )
    }
    
    if try shell( runAargs ) != 0 {
        throw RuntimeError( "Failed to run solution for \(package)." )
    }

    if askYN( prompt: "Did the solution succeed", expected: true ) { return }
    throw RuntimeError( "Solution for \(package) failed." )
}
