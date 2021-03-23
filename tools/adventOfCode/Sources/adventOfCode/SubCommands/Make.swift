//
//  Make.swift
//  Implements the make subcommand
//
//  Created by Mark Johnson on 3/21/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser
import Mustache

extension adventOfCode {
    struct Make: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create a new problem solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        func validate() throws {
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let swiftFile = "\(package).swift"
            let inputFolder = "input"
            let inputFile = "\(inputFolder)/\(package).txt"
            
            if fileManager.fileExists( atPath: swiftFile ) {
                print( "\(swiftFile) already exists" )
                throw ExitCode.failure
            }
            
            if !fileManager.fileExists( atPath: inputFolder ) {
                try fileManager.createDirectory( atPath: inputFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if fileManager.fileExists( atPath: inputFile ) {
                print( "\(inputFile) already exists" )
                throw ExitCode.failure
            }
            
            let bundleURL = Bundle.module.url( forResource: "mainswift", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                print( "Can't find template for \(swiftFile)" )
                throw ExitCode.failure
            }
            let template = try Template( URL: templateURL )
            let dateFormatterFull = DateFormatter()
            let dateFormatterYear = DateFormatter()
            
            dateFormatterFull.dateFormat = "MM/dd/yy"
            dateFormatterYear.dateFormat = "yyyy"

            let templateData: [String: Any] = [
                "package": package,
                "date": dateFormatterFull.string( from: Date() ),
                "year": dateFormatterYear.string( from: Date() )
            ]
            let rendering = try template.render( templateData )

            try rendering.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            
            var inputLines = [ "", "" ]
            
            print( "Enter the input data -" )
            while let line = readLine( strippingNewline: true ) {
                inputLines.append( line )
            }
            let inputText = inputLines.joined( separator: "\n" )
            try inputText.write( toFile: inputFile, atomically: true, encoding: .utf8 )
            
            // Call the function that does the work of the "open" subcommand.
        }
    }
}
