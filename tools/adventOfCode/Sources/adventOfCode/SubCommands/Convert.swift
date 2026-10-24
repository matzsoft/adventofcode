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
            let swiftCount = glob( pattern: "*.swift" ).count
            guard swiftCount == 12 || swiftCount == 25 else {
                throw RuntimeError( "Directory must contain 12 or 25 *.swift files." )
            }
            for number in 1 ... swiftCount {
                let ( _, _, package ) = try determinePackage( package: String( number ) )
                
                if fileManager.fileExists( atPath: package ) {
                    try fileManager.removeItem( atPath: package )
                }
                _ = try openCreateFiles( package: package, display: false )
                try testSolution( package: package )
                
                guard fileManager.changeCurrentDirectoryPath( ".." ) else {
                    throw RuntimeError( "Can't change directory to .." )
                }
            }
            
            try gitChanges( swiftCount: swiftCount )
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


func gitChanges( swiftCount: Int ) throws -> Void {
    let fileManager = FileManager.default
    let packages = "packages"
    let contents = try ( 1 ... swiftCount ).map { number in
        let ( year, _, package ) = try determinePackage( package: String( number ) )
        let result = try String( contentsOfFile: "\(package)/Sources/main.swift", encoding: .utf8 )
        return Content(
            name: package, year: year, content: result,
            move: [ "git", "mv", "-f", "\(package).swift", "\(package)/Sources/main.swift" ],
            add: [ "git", "add", "\(package)/Package.swift" ]
        )
    }
    let commitMove = [ "git", "commit", "-a", "-m", "Moved all \(contents[0].year) *.swift files." ]
    let commitFinal = [ "git", "commit", "-a", "-m", "Conversion of \(contents[0].year)." ]
    let removePackages = [ "git", "rm", "-r", "\(packages)/" ]

    for package in contents {
        displayGit( args: package.move )
    }
    
    displayGit( args: commitMove )
    
    for package in contents {
        try package.content.write( toFile: "\(package.name)/Sources/main.swift", atomically: true, encoding: .utf8 )
    }

    if fileManager.fileExists( atPath: packages ) {
        displayGit( args: removePackages )
//        try? fileManager.removeItem( atPath: packages )
    }
    
    for package in contents {
        displayGit( args: package.add )
    }
    
    displayGit( args: commitFinal )
}


func displayGit( args: [String] ) -> Void {
    print( args.map { $0.contains( " " ) ? "'\($0)'" : $0 }.joined( separator: " " ) )
}
