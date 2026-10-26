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
            let tracked = try shell( "git", "ls-files", "." )
            let packages = glob( pattern: "day*.swift" ).filter { tracked.contains( $0 ) }.map { String( $0.dropLast( 6 ) ) }
            let startPackage = getString( prompt: "Start package for solution tests", preferred: "day01" )
            var testSolutions = false
            for package in packages {
                if package == startPackage { testSolutions = true }
                if fileManager.fileExists( atPath: package ) {
                    try fileManager.removeItem( atPath: package )
                }
                
                // openCreateFiles does a cd to the package directory and testSolution requires it
                _ = try openCreateFiles( package: package, display: false )
                if testSolutions { try testSolution( package: package ) }
                
                guard fileManager.changeCurrentDirectoryPath( ".." ) else {
                    throw RuntimeError( "Can't change directory to .." )
                }
            }
            
            if askYN( prompt: "Run the git commands", expected: true ) { try gitChanges( packages: packages ) }
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
        let log = try String( contentsOfFile: buildLog, encoding: .utf8 )
        print( log )
        throw RuntimeError( "Failed to build solution for \(package)." )
    }
    
    if try shell( runAargs ) != 0 {
        throw RuntimeError( "Failed to run solution for \(package)." )
    }

    if askYN( prompt: "Did \(package) succeed", expected: true ) { return }
    throw RuntimeError( "Solution for \(package) failed." )
}


struct Content {
    let name: String
    let year: Int
    let content: String
    let move: [String]
    let add: [String]
}


func gitChanges( packages: [String] ) throws -> Void {
    let fileManager = FileManager.default
    let packagesFolder = "packages"
    let contents = try packages.map { package in
        let ( year, _, _ ) = try determinePackage( package: package )
        let result = try String( contentsOfFile: "\(package)/Sources/main.swift", encoding: .utf8 )
        return Content(
            name: package, year: year, content: result,
            move: [ "git", "mv", "-f", "\(package).swift", "\(package)/Sources/main.swift" ],
            add: [ "git", "add", "\(package)/Package.swift" ]
        )
    }
    let commitMove = [ "git", "commit", "-a", "-m", "Moved all \(contents[0].year) *.swift files." ]
    let commitFinal = [ "git", "commit", "-a", "-m", "Conversion of \(contents[0].year)." ]
    let removePackages = [ "git", "rm", "-r", "\(packagesFolder)/" ]

    for package in contents {
        try performGit( args: package.move )
    }
    
    guard askYN( prompt: "Commit the moves to main.swift", expected: true ) else {
        throw RuntimeError( "Commiting the moves aborted." )
    }
    try performGit( args: commitMove )
    
    for package in contents {
        try package.content.write( toFile: "\(package.name)/Sources/main.swift", atomically: true, encoding: .utf8 )
    }

    if fileManager.fileExists( atPath: packagesFolder ) {
        try performGit( args: removePackages )
//        try? fileManager.removeItem( atPath: packages )
    }
    
    for package in contents {
        try performGit( args: package.add )
    }
    
    guard askYN( prompt: "Perform the final commit", expected: true ) else {
        throw RuntimeError( "Final commit aborted." )
    }
    try performGit( args: commitFinal )
}


func performGit( args: [String] ) throws -> Void {
    if try shell( args ) != 0 {
        throw RuntimeError( "Failed git command - \(displayGit(args: args))")
    }
}


func displayGit( args: [String] ) -> String {
    return args.map { $0.contains( " " ) ? "'\($0)'" : $0 }.joined( separator: " " )
}
