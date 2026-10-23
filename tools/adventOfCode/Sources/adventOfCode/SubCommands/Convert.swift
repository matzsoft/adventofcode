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
                _ = try openCreateFiles( package: package )
                guard fileManager.changeCurrentDirectoryPath( ".." ) else {
                    throw RuntimeError( "Can't change directory to .." )
                }
                
                print( "Converted \(package)" )
            }
        }
    }
}
