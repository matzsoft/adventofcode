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
            
            if !fileManager.fileExists( atPath: inputFolder ) {
                try fileManager.createDirectory( atPath: inputFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if fileManager.fileExists( atPath: inputFile ) {
                if !askYN( prompt: "\(inputFile) already exists, add header", expected: true ) {
                    throw ExitCode.failure
                }
            }
            
            if fileManager.fileExists( atPath: swiftFile ) {
                let oldFile = "old-\(swiftFile)"
                
                print( "\(swiftFile) already exists, moving it to \(oldFile)" )
                try fileManager.moveItem( atPath: swiftFile, toPath: oldFile )
            }

            let title = getString( prompt: "Enter puzzle title", preferred: nil )
            let bundleURL = Bundle.module.url( forResource: "mainswift", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                print( "Can't find template for \(swiftFile)" )
                throw ExitCode.failure
            }
            let template = try Template( URL: templateURL )
            let dateFormatterFull = DateFormatter()
            let dateFormatterYear = DateFormatter()
            
            dateFormatterFull.dateFormat = "MM/dd/yy HH:mm:ss"
            dateFormatterYear.dateFormat = "yyyy"

            let templateData: [String: Any] = [
                "package": package,
                "title": title,
                "date": dateFormatterFull.string( from: Date() ),
                "year": dateFormatterYear.string( from: Date() )
            ]
            let rendering = try template.render( templateData )

            try createInput( path: inputFile )
            try rendering.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            try performOpen( swiftFile: swiftFile )
        }
    }
}


func createInput( path: String ) throws -> Void {
    let fileManager = FileManager.default
    let part1 = getString( prompt: "Enter part1 solution", preferred: "" )
    let part2 = getString( prompt: "Enter part2 solution", preferred: "" )
    var extras = [String]()
    
    print( "Enter extra header lines -" )
    while let line = readLine( strippingNewline: true ) {
        if line == "" { break }
        extras.append( line )
    }
    
    var inputLines = [ part1, part2 ] + extras + [ "--------------------" ]
    
    if fileManager.fileExists( atPath: path ) {
        inputLines.append( contentsOf: try String( contentsOfFile: path ).components( separatedBy: "\n" ) )
    } else {
        print( "Enter the input data -" )
        while let line = readLine( strippingNewline: true ) {
            inputLines.append( line )
        }
    }
    
    let inputText = inputLines.joined( separator: "\n" )
    try inputText.write( toFile: path, atomically: true, encoding: .utf8 )
}


func getString( prompt: String, preferred: String? ) -> String {
    let defaultPrompt = preferred == nil ? ": " : " [\(preferred!)]: "
    
    while true {
        print( "\(prompt)\(defaultPrompt)", terminator: "" )
        
        let answer = readLine( strippingNewline: true )
        
        if answer != nil && answer! != "" { return answer! }
        if preferred != nil { return preferred! }
    }
}
