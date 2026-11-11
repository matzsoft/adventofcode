//         FILE: Gather.swift
//  DESCRIPTION: adventOfCode - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/5/26 2:39 PM

import Foundation
import ArgumentParser
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Gather: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create results.json from the results of the solutions in a year directory."
        )
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let year = URL( fileURLWithPath: fileManager.currentDirectoryPath ).lastPathComponent
            let currentYear = Calendar.current.component( .year, from: .now )
            guard let year = Int( year ), 2015 <= year && year <= currentYear else {
                throw ValidationError( "Must be run from a valid year directory." )
            }
            
            let resultsURL = URL( fileURLWithPath: "result.json" )
            let tracked  = try shell( "git", "ls-files", "." )
            let mainSwift = "Sources/main.swift"
            let packages = glob( pattern: "day*/\(mainSwift)" )
                .filter { tracked.contains( $0 ) }
                .map { String( $0.prefix( while: { $0 != "/" } ) ) }
            
            if !fileManager.fileExists( atPath: resultsURL.path() ) {
                
                let results = try packages.map { Result( solution: try getSolution( package: $0 ) ) }
                let jsonData = try JSONEncoder().encode( results )
                try jsonData.write( to: resultsURL )

            } else {
                
                let oldJson = try Data( contentsOf: resultsURL )
                let oldDate = try getModificationDate( atPath: resultsURL.path() )
                let oldResults = try JSONDecoder().decode( [Result].self, from: oldJson )
                let newResults = try packages.map { package in
                    let mainDate = try getModificationDate( atPath: "\(package)/\(mainSwift)" )
                    
                    if oldDate < mainDate {
                        return Result( solution: try getSolution( package: package ) )
                    } else {
                        if let oldResult = oldResults.first( where: { $0.name == package } ) {
                            print( "\(package) - Already up to date." )
                            return oldResult
                        }
                        return Result( solution: try getSolution( package: package ) )
                    }
                }
                if newResults != oldResults {
                    let jsonData = try JSONEncoder().encode( newResults )
                    try jsonData.write( to: resultsURL )
                }

            }
        }
    }
}


func getSolution( package: String ) throws -> String {
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
    
    let solution = try shell( runAargs )
    
    guard fileManager.changeCurrentDirectoryPath( ".." ) else {
        throw RuntimeError( "Can't change directory to .." )
    }
    
    print( "\(package) - Updated." )
    return solution
}
