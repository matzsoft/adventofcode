//
//  Retrofit.swift
//  Implements the retrofit subcommand
//
//  Created by Mark Johnson on 6/14/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser
import Mustache

extension adventOfCode {
    struct Retrofit: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Help with retrofit of new Run* methods into a package."
        )
        
        @Argument( help: "Name of the solution package to retrofit." )
        var package: String
        
        func validate() throws {
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let swiftFile = "\(package).swift"
            
            guard fileManager.fileExists( atPath: swiftFile ) else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "\(swiftFile) does not exist.", to: &stderr )
                throw ExitCode.failure
            }
            
            let swiftFileSource = try updateSwiftSource( swiftFile: swiftFile )

            try swiftFileSource.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            try performOpen( swiftFile: swiftFile )
        }

        func updateSwiftSource( swiftFile: String ) throws -> String {
            let oldSource = try String( contentsOfFile: swiftFile )
            let bundleURL = Bundle.module.url( forResource: "retrofit", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't find template for \(swiftFile)", to: &stderr )
                throw ExitCode.failure
            }
            let template = try Template( URL: templateURL )
            let templateData: [String: Any] = [ "oldSource": oldSource ]
            
            return try template.render( templateData )
        }
    }
}
