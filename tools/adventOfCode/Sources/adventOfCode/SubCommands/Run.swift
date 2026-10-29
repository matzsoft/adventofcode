//         FILE: Run.swift
//  DESCRIPTION: adventOfCode - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 10/28/26 5:24 PM

import Foundation
import ArgumentParser
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Run: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Run all (or some) of the solutions in a year directory."
        )
        
        @Argument( help: "Name of the solution package to run." )
        var package: String?

        @Option( name: .short, help: "Name of the solution package to start running." )
        var start: String?
        
        mutating func validate() throws {
            guard package == nil || start == nil else {
                throw ValidationError( "The package argument and the --start option are mutually exclusive." )
            }
            if let package {
                let ( _, _, package ) = try determinePackage( package: package )
                self.package = package
            }
            
            if let start {
                let ( _, _, start ) = try determinePackage( package: start )
                self.start = start
            }
        }

        func run() throws -> Void {
            if let package {
                try runSolution( package: package )
                return
            }
            
            let startPackage = start ?? "day01"
            let tracked      = try shell( "git", "ls-files", "." )
            var runSolutions = false
            let packages     = glob( pattern: "day*/Sources/main.swift" )
                .filter { tracked.contains( $0 ) }
                .map { String( $0.prefix( while: { $0 != "/" } ) ) }

            for package in packages {
                if package == startPackage { runSolutions = true }
                if runSolutions { try runSolution( package: package ) }
            }
        }
    }
}


func runSolution( package: String ) throws -> Void {
    let fileManager = FileManager.default
    let buildAargs  = [ "swift", "build", "-c", "release" ]
    let runAargs    = [ "swift", "run", "-c", "release", "--skip-build" ]
    let buildLog    = "/dev/null"
    let fileHandle  = try FileHandle( forWritingTo: URL( fileURLWithPath: buildLog ) )
    
    guard fileManager.changeCurrentDirectoryPath( package ) else {
        throw RuntimeError( "Can't change directory to \(package)" )
    }
    
    let buildStatus = try shell( stdout: fileHandle, stderr: fileHandle, buildAargs )

    try? fileHandle.close()
    if buildStatus != 0 {
        throw RuntimeError( "Failed to build solution for \(package)." )
    }
    
    if try shell( runAargs ) != 0 {
        throw RuntimeError( "Failed to run solution for \(package)." )
    }
    
    guard fileManager.changeCurrentDirectoryPath( ".." ) else {
        throw RuntimeError( "Can't change directory to .." )
    }
}
