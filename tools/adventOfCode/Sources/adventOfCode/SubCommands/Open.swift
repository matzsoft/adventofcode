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
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create the Swift Package Manager structure for a solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        mutating func validate() throws {
            let ( _, _, package ) = try determinePackage( package: package )
            self.package = package
        }

        func run() throws -> Void {
            try performOpen( package: package )
        }
    }
}


func performOpen( package: String ) throws -> Void {
    let mainSwift = try openCreateFiles( package: package )
    try openXcode( mainSwift: mainSwift )
}

func openCreateFiles( package: String, display: Bool = true ) throws -> String {
    let fileManager = FileManager.default
    let swiftFile = package + ".swift"
    let sourcesFolder = "Sources"
    let mainSwift = "\(sourcesFolder)/main.swift"

    guard fileManager.fileExists( atPath: swiftFile ) else {
        throw RuntimeError( "\(swiftFile) does not exist" )
    }
    
    if fileManager.fileExists( atPath: package ) {
        guard fileManager.changeCurrentDirectoryPath( package ) else {
            throw RuntimeError( "Can't change directory to \(package)." )
        }
    } else {
        let sourcesPath = "\(package)/\(sourcesFolder)"
        
        try fileManager.createDirectory( atPath: sourcesPath, withIntermediateDirectories: true, attributes: nil )
        guard fileManager.changeCurrentDirectoryPath( package ) else {
            throw RuntimeError( "Can't change directory to \(package)." )
        }
        
        try createMainSwift( swiftFile: "../\(swiftFile)", mainSwift: mainSwift )
        try fixPackageSwift( package: package )
    }
    
    return mainSwift
}

func openXcode( mainSwift: String ) throws -> Void {
    guard try shell( stdout: nil, "open", "Package.swift" ) == 0 else {
        throw RuntimeError( "Can't open Package.swift." )
    }
//    print( "Waiting for 5 seconds..." )
//    sleep( 5 )
//    
//    guard try shell( stdout: nil, "open", mainSwift ) == 0 else {
//        throw RuntimeError( "Can't open \(mainSwift)." )
//    }
}

func createMainSwift( swiftFile: String, mainSwift: String ) throws -> Void {
    var code = try String( contentsOfFile: swiftFile, encoding: .utf8 )
    let importLibrary        = "import Library"
    let importMATZLibrary    = "import MATZMiscSwiftLibrary"
    let projectInfoStatement = "try print( projectInfo() )"
    
    if !code.contains( importLibrary ) {
        let target = "import Foundation"
        code = code.replacingOccurrences( of: target, with: "\(target)\n\(importLibrary)" )
    }
    if !code.contains( importMATZLibrary ) {
        code = code.replacingOccurrences( of: importLibrary, with: "\(importLibrary)\n\(importMATZLibrary)" )
    }
    if !code.contains( projectInfoStatement ) {
        let target = "try runTests( part1:"
        code = code.replacingOccurrences( of: target, with: "\(projectInfoStatement)\n\(target)" )
    }
    try code.write( toFile: mainSwift, atomically: true, encoding: .utf8 )
}


func fixPackageSwift( package: String ) throws -> Void {
    let fileManager = FileManager.default
    let stock = try createPackageSwift( directory: ".", package: package )
    let customPackage = "../packages/\(package).swift"
    
    guard fileManager.fileExists( atPath: customPackage ) else {
        try stock.write( toFile: "Package.swift", atomically: true, encoding: .utf8 )
        return
    }
 
    let custom = try String( contentsOfFile: customPackage, encoding: .utf8 )
    let stockLines = stock.split( separator: "\n", omittingEmptySubsequences: false )
    var customLines = custom.split( separator: "\n", omittingEmptySubsequences: false )
    
    guard let stockVersion = stockLines.first( where: { $0.contains( "swift-tools-version:" ) } ) else {
        throw RuntimeError( "Can't find 'swift-tools-version:' in stock Package.swift." )
    }
    
    guard let customVersionIndex = customLines.firstIndex( where: { $0.contains( "swift-tools-version:" ) } ) else {
        throw RuntimeError( "Can't find 'swift-tools-version:' in custom Package.swift." )
    }
    
    customLines[customVersionIndex] = stockVersion
    
    guard let stockPlatforms = stockLines.first( where: { $0.contains( "platforms:" ) } ) else {
        throw RuntimeError( "Can't find 'platforms:' in stock Package.swift." )
    }

    if let customPlatformsIndex = customLines.firstIndex( where: { $0.contains( "platforms:" ) } ) {
        customLines[customPlatformsIndex] = stockPlatforms
    } else {
        guard let customNameIndex = customLines.firstIndex( where: { $0.contains( "name:" ) } ) else {
            throw RuntimeError( "Can't find 'name:' in custom Package.swift." )
        }
        customLines.insert( stockPlatforms, at: customNameIndex + 1 )
    }
    
    let result = customLines.joined( separator: "\n" )
    try result.write( toFile: "Package.swift", atomically: true, encoding: .utf8 )
}


func createPackageSwift( directory: String, package: String ) throws -> String {
    let libraryURL = URL( filePath: try findDirectory( name: "Library" ) )
    guard let libraryPath = libraryURL.relativePath( from: URL( filePath: directory ) ) else {
        throw RuntimeError( "Unable to find relative path to Library." )
    }

    let bundleURL = Bundle.module.url( forResource: "PackageSwift", withExtension: "mustache" )
    guard let templateURL = bundleURL else {
        throw RuntimeError( "Can't find template for Package.swift" )
    }
    let template = try Template( URL: templateURL )
    let templateData: [String: Any] = [
        "package": package,
        "libraryPath": libraryPath
    ]
    
    return try template.render( templateData )
}
