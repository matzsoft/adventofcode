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
import Mustache

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
    let importStatement      = "import Library"
    let projectInfoStatement = "try print( projectInfo() )"
    
    if !code.contains( importStatement ) {
        let target = "import Foundation"
        code = code.replacingOccurrences( of: target, with: "\(target)\n\(importStatement)" )
    }
    if !code.contains( projectInfoStatement ) {
        let target = "try runTests( part1:"
        code = code.replacingOccurrences( of: target, with: "\(projectInfoStatement)\n\(target)" )
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

    let bundleURL = Bundle.module.url( forResource: "PackageSwift", withExtension: "mustache" )
    guard let templateURL = bundleURL else {
        var stderr = FileHandlerOutputStream( FileHandle.standardError )
        print( "Can't find template for Package.swift", to: &stderr )
        throw ExitCode.failure
    }
    let template = try Template( URL: templateURL )
    let templateData: [String: Any] = [
        "package": package,
        "libraryPath": libraryPath
    ]
    let stock = try template.render( templateData )

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
