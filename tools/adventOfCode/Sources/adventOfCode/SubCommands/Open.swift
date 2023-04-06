//
//  Open.swift
//  Implements the open subcommand
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import Library
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

//    try fileManager.removeItem( atPath: mainSwift )
//    try fileManager.copyItem( atPath: "../\(swiftFile)", toPath: mainSwift )
    try createMainSwift( swiftFile: "../\(swiftFile)", mainSwift: mainSwift )
    try fixPackageSwift( package: package )
        
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

func createMainSwift( swiftFile: String, mainSwift: String ) throws -> Void {
    var code = try String( contentsOfFile: swiftFile )
    
    if !code.contains( "import Library" ) {
        let target = "import Foundation"
        let replacement = "import Library"
        code = code.replacingOccurrences( of: target, with: "\(target)\n\(replacement)" )
    }
    if !code.contains( "projectInfo()" ) {
        let target = "try runTests( part1:"
        let replacement = "try print( projectInfo() )"
        code = code.replacingOccurrences( of: target, with: "\(replacement)\n\(target)" )
    }
    try code.write( toFile: mainSwift, atomically: true, encoding: .utf8 )
}


func fixPackageSwift( package: String ) throws -> Void {
    let fileManager = FileManager.default
    let libraryURL = URL( filePath: try findDirectory( name: "Library" ) )
    let cwdURL = URL( filePath: fileManager.currentDirectoryPath )
    guard let libraryPath = libraryURL.relativePath( from: cwdURL ) else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Unable to find relative path to Library.", to: &stderr )
        throw ExitCode.failure
    }

    // Read generated file
    let original = try String( contentsOfFile: "Package.swift" )
    // fix dependencies
    let nameArgument = "name: \"\(package)\","
    let ranges = original.ranges( of: nameArgument )
    
    guard ranges.count == 2 else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Unrecognized format in Package.swift.", to: &stderr )
        throw ExitCode.failure
    }
    
    let productDependency = "    dependencies: [ .package( path: \"\(libraryPath)\" ) ],"
    let targetDependency = "        dependencies: [ \"Library\" ],"
    var stock = original

    stock.replaceSubrange( ranges[1], with: "\(nameArgument)\n\(targetDependency)" )
    stock.replaceSubrange( ranges[0], with: "\(nameArgument)\n\(productDependency)" )

    // write to stock
    try stock.write( toFile: "stock-Package.swift", atomically: true, encoding: .utf8 )

    // do the patch
    if fileManager.fileExists( atPath: "../\(package).patch" ) {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "patch file for Package.swift not implemented yet.", to: &stderr )
        throw ExitCode.failure

        // read the patched file
        // fix dependencies
        // write to real
//        guard shell( "patch", "-d", "..", "-p0", "-i", "\(package).patch" ) == 0 else {
//            var stderr = FileHandlerOutputStream( FileHandle.standardError )
//            print( "Can't create Xcode project.", to: &stderr )
//            throw ExitCode.failure
//        }
//        usleep( 5000 )      // 5 millisecond wait for Pacakage.swift to close.
    }

    // write to real
    try stock.write( toFile: "Package.swift", atomically: true, encoding: .utf8 )
}
