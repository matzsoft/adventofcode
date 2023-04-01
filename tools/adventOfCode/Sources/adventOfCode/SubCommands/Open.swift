//
//  Open.swift
//  Implements the open subcommand
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser

extension AdventOfCode {
    struct Open: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Swift Package Manager structure for a solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        mutating func validate() throws {
            if let determined = determinePackage( package: package ) {
                package = determined
                return
            }

            var stderr = FileHandlerOutputStream( FileHandle.standardError )
            print( "Cannot determine package from \(package)", to: &stderr )
            throw ExitCode.failure
        }

        func run() throws -> Void {
            try performOpen( package: package )
        }
    }
}


func performOpen( package: String ) throws -> Void {
    let fileManager = FileManager.default
    let swiftFile = package + ".swift"
    let sourcesFolder = "Sources"
    let mainSwift = "\(sourcesFolder)/main.swift"
    let libraryFolder = try findDirectory( name: "Library" )
    let pattern = "\(libraryFolder)/*.swift"
    let libraryFiles = glob( pattern: pattern )

    guard fileManager.fileExists( atPath: swiftFile ) else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "\(swiftFile) does not exist", to: &stderr )
        throw ExitCode.failure
    }
    
    if fileManager.fileExists( atPath: package ) {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "\(package) already exists", to: &stderr )
        throw ExitCode.failure
    }
    
    try fileManager.createDirectory( atPath: package, withIntermediateDirectories: false, attributes: nil )
    guard fileManager.changeCurrentDirectoryPath( package ) else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Can't change directory to \(package).", to: &stderr )
        throw ExitCode.failure
    }
    
    guard shell( "swift", "package", "init", "--type", "executable" ) == 0 else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Can't create swift package.", to: &stderr )
        throw ExitCode.failure
    }

    try fileManager.removeItem( atPath: mainSwift )
    try fileManager.copyItem( atPath: "../\(swiftFile)", toPath: mainSwift )
    try fileManager.copyItem( atPath: "Package.swift", toPath: "stock-Package.swift" )
    for file in libraryFiles {
        let filename = URL( fileURLWithPath: file ).lastPathComponent
        
        try fileManager.copyItem( atPath: file, toPath: "\(sourcesFolder)/\(filename)" )
    }
    if fileManager.fileExists( atPath: "../\(package).patch" ) {
        guard shell( "patch", "-d", "..", "-p0", "-i", "\(package).patch" ) == 0 else {
            var stderr = FileHandlerOutputStream( FileHandle.standardError )
            print( "Can't create Xcode project.", to: &stderr )
            throw ExitCode.failure
        }
        usleep( 5000 )      // 5 millisecond wait for Pacakage.swift to close.
    }
    guard shell( "open", "Package.swift" ) == 0 else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Can't open Package.swift.", to: &stderr )
        throw ExitCode.failure
    }
    print( "Waiting for 5 seconds..." )
    sleep( 5 )
    
    guard shell( "open", mainSwift ) == 0 else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Can't open \(mainSwift).", to: &stderr )
        throw ExitCode.failure
    }
}
