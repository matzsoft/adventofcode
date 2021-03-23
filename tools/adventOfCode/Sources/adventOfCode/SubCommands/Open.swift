//
//  Open.swift
//  Implements the open subcommand
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser

func shell( _ args: String... ) -> Int32 {
    let task = Process()
    
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}


extension adventOfCode {
    struct Open: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Swift Package Manager structure for a solution."
        )
        
        @Argument( help: "Name of the Swift file to create the package for." )
        var swiftFile: String
        
        func validate() throws {
            guard swiftFile.hasSuffix( ".swift" ) else {
                throw RuntimeError( "Must specify a .swift file" )
            }
        }
        
        func run() throws -> Void {
            try performOpen( swiftFile: swiftFile )
        }
    }
}


func performOpen( swiftFile: String ) throws -> Void {
    let fileManager = FileManager.default
    let package = String( swiftFile.dropLast( 6 ) )
    let sourcesFolder = "Sources/\(package)"
    let mainSwift = "\(sourcesFolder)/main.swift"
    let libraryFolder = try findDirectory( name: "Library" )
    let pattern = "\(libraryFolder)/*.swift"
    let libraryFiles = glob( pattern: pattern )

    guard fileManager.fileExists( atPath: swiftFile ) else {
        print( "\(swiftFile) does not exist" )
        throw ExitCode.failure
    }
    
    if fileManager.fileExists( atPath: package ) {
        print( "\(package) already exists" )
        throw ExitCode.failure
    }
    
    try fileManager.createDirectory( atPath: package, withIntermediateDirectories: false, attributes: nil )
    
    guard fileManager.changeCurrentDirectoryPath( package ) else {
        throw RuntimeError( "Can't change directory to \(package)." )
    }
    
    guard shell( "swift", "package", "init", "--type", "executable" ) == 0 else {
        throw RuntimeError( "Can't create swift package." )
    }

    try fileManager.removeItem( atPath: mainSwift )
    try fileManager.copyItem( atPath: "../\(swiftFile)", toPath: mainSwift )
    for file in libraryFiles {
        let filename = URL( fileURLWithPath: file ).lastPathComponent
        
        try fileManager.copyItem( atPath: file, toPath: "\(sourcesFolder)/\(filename)" )
    }
    print( "Waiting for 5 seconds..." )
    sleep( 5 )
    
    guard shell( "open", "Package.swift" ) == 0 else {
        throw RuntimeError( "Can't open Xcode." )
    }
    print( "Waiting for 5 seconds..." )
    sleep( 5 )
    
    guard shell( "open", mainSwift ) == 0 else {
        throw RuntimeError( "Can't open \(mainSwift)." )
    }
}
