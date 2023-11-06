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

            throw reportFailure( "Cannot determine package from \(package)" )
        }

        func run() throws -> Void {
            let fileManager = FileManager.default
            let swiftFile = "\(package).swift"
            let sourcesFolder = "\(package)/Sources"
            let mainSwift = "\(sourcesFolder)/main.swift"
            let packageSwift = "\(package)/Package.swift"
            let customFolder = "packages"
            let customPackage = "\(customFolder)/\(swiftFile)"
            var isDir: ObjCBool = false

            guard fileManager.fileExists( atPath: package, isDirectory: &isDir ) else {
                throw reportFailure( "File \(package) doesn't exist" )
            }
            
            guard isDir.boolValue else {
                throw reportFailure( "File \(package) is not a directory" )
            }
            
            guard fileManager.fileExists( atPath: mainSwift ) else {
                throw reportFailure( "Can't find main.swift in the \(package) directory" )
            }

            if !fileManager.fileExists( atPath: swiftFile ) {
                try copyFile( atPath: mainSwift, toPath: swiftFile )
            } else if !fileManager.contentsEqual( atPath: mainSwift, andPath: swiftFile ) {
                try fileManager.removeItem( atPath: swiftFile )
                try copyFile( atPath: mainSwift, toPath: swiftFile )
            }
            
            let stock = try createPackageSwift( directory: "./\(package)", package: package )
            let actual = try String( contentsOfFile: packageSwift )
            
            if stock != actual {
                var isDir: ObjCBool = false
                
                if !fileManager.fileExists( atPath: customFolder, isDirectory: &isDir ) {
                    try fileManager.createDirectory(
                        atPath: customFolder, withIntermediateDirectories: false, attributes: nil
                    )
                    try copyFile( atPath: packageSwift, toPath: customPackage )
                } else {
                    guard isDir.boolValue else {
                        throw reportFailure( "File \(customFolder) is not a directory" )
                    }
                    
                    if !fileManager.fileExists( atPath: customPackage ) {
                        try copyFile( atPath: packageSwift, toPath: customPackage )
                    } else if !fileManager.contentsEqual( atPath: packageSwift, andPath: customPackage ) {
                        try fileManager.removeItem( atPath: customPackage )
                        try copyFile( atPath: packageSwift, toPath: customPackage )
                    }
                }
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
