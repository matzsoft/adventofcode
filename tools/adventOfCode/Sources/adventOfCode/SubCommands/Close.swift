//
//  Close.swift
//  Implements the close subcommand
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import Library
import ArgumentParser

extension AdventOfCode {
    struct Close: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Closes a problem solution package to prepare for git commit."
        )
        
        @Argument( help: "Name of the solution package to close." )
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
            let fileManager = FileManager.default
            let swiftFile = "\(package).swift"
            let sourcesFolder = "\(package)/Sources"
            let mainSwift = "\(sourcesFolder)/main.swift"
            let libraryFolder = try "\(findDirectory( name: "Library" ))/Sources"
            let pattern = "\(sourcesFolder)/*.swift"
            let sourcesFiles = glob( pattern: pattern ).filter { $0 != mainSwift }
            var isDir: ObjCBool = false

            guard fileManager.fileExists( atPath: package, isDirectory: &isDir ) else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "File \(package) doesn't exist", to: &stderr )
                throw ExitCode.failure
            }
            
            guard isDir.boolValue else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "File \(package) is not a directory", to: &stderr )
                throw ExitCode.failure
            }
            
            guard fileManager.fileExists( atPath: mainSwift ) else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't find main.swift in the \(package) directory", to: &stderr )
                throw ExitCode.failure
            }

            if !fileManager.fileExists( atPath: swiftFile ) {
                try copyFile( atPath: mainSwift, toPath: swiftFile )
            } else if !fileManager.contentsEqual( atPath: mainSwift, andPath: swiftFile ){
                try fileManager.removeItem( atPath: swiftFile )
                try copyFile( atPath: mainSwift, toPath: swiftFile )
            }
            
            for file in sourcesFiles {
                try updateLibrary( libraryFolder: libraryFolder, sourceFile: file )
            }
            
            fileManager.createFile( atPath: "\(package).patch", contents: nil )
            guard let diffOutput = FileHandle( forWritingAtPath: "\(package).patch" ) else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't write to the patch file.", to: &stderr )
                throw ExitCode.failure
            }
            switch shell(
                stdout: diffOutput, "diff", "-Naur",
                "--label=\(package)/stock-Package.swift", "--label=\(package)/Package.swift",
                "\(package)/stock-Package.swift", "\(package)/Package.swift"
            ) {
            case 0:
                try fileManager.removeItem( atPath: "\(package).patch" )
            case 1:
                break
            default:
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't diff the Package.swift files.", to: &stderr )
                throw ExitCode.failure
            }
            
            try fileManager.removeItem( atPath: package )
        }
    }
}


func copyFile( atPath: String, toPath: String ) throws -> Void {
    let fileManager = FileManager.default

    try fileManager.copyItem( atPath: atPath, toPath: toPath )
    print( "\(atPath) copied to \(toPath)" )
}


func updateLibrary( libraryFolder: String, sourceFile: String ) throws -> Void {
    let fileManager = FileManager.default
    let filename = URL( fileURLWithPath: sourceFile ).lastPathComponent
    let libraryFile = "\(libraryFolder)/\(filename)"
    
    if !fileManager.fileExists( atPath: libraryFile ) {
        if askYN( prompt: "\(sourceFile) is new.  Add to library", expected: true ) {
            try copyFile( atPath: sourceFile, toPath: libraryFile )
        }
    } else {
        if !fileManager.contentsEqual( atPath: sourceFile, andPath: libraryFile ) {
            if askYN( prompt: "\(sourceFile) and \(libraryFile) differ.  Update library", expected: true ) {
                try fileManager.removeItem( atPath: libraryFile )
                try copyFile( atPath: sourceFile, toPath: libraryFile )
            }
        }
    }
}
