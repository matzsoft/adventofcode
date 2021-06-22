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
            if package.hasSuffix( ".swift" )  {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Must specify package name not a .swift file", to: &stderr )
                throw ExitCode.failure
            }
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let currentDirectory = fileManager.currentDirectoryPath
            let swiftFile = "\(package).swift"
            let oldFile = "old-\(swiftFile)"
            let inputFile = try setupInput()
            
            if fileManager.fileExists( atPath: swiftFile ) {
                print( "\(swiftFile) already exists, moving it to \(oldFile)" )
                try fileManager.moveItem( atPath: swiftFile, toPath: oldFile )
            }

            let swiftFileSource = try createSwiftSource( swiftFile: swiftFile )

            try createInput( inputFile: inputFile )
            try swiftFileSource.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            try performOpen( package: package )
            
            guard fileManager.changeCurrentDirectoryPath( currentDirectory ) else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't change back to initial directory.", to: &stderr )
                throw ExitCode.failure
            }
            
            if fileManager.fileExists( atPath: oldFile ) {
                print( "Moving \(oldFile) back to \(swiftFile)" )
                try fileManager.removeItem( atPath: swiftFile )
                try fileManager.moveItem( atPath: oldFile, toPath: swiftFile )
            }
        }

        func setupInput() throws -> String {
            let fileManager = FileManager.default
            let inputFolder = "input"
            let testsFolder = "testfiles"
            let inputFile = "\(inputFolder)/\(package).txt"
            
            if !fileManager.fileExists( atPath: inputFolder ) {
                try fileManager.createDirectory( atPath: inputFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if !fileManager.fileExists( atPath: testsFolder ) {
                try fileManager.createDirectory( atPath: testsFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if fileManager.fileExists( atPath: inputFile ) {
                if !askYN( prompt: "\(inputFile) already exists, add header", expected: true ) {
                    var stderr = FileHandlerOutputStream( FileHandle.standardError )
                    print( "Unable to proceed.", to: &stderr )
                    throw ExitCode.failure
                }
            }
            
            return inputFile
        }
        
        func createSwiftSource( swiftFile: String ) throws -> String {
            let title = getString( prompt: "Enter puzzle title", preferred: nil )
            let bundleURL = Bundle.module.url( forResource: "mainswift", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                var stderr = FileHandlerOutputStream( FileHandle.standardError )
                print( "Can't find template for \(swiftFile)", to: &stderr )
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
            
            return try template.render( templateData )
        }

        func createInput( inputFile: String ) throws -> Void {
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
            
            if try fileManager.fileExists( atPath: inputFile ) || getDataCurl( inputFile: inputFile ) {
                inputLines.append(
                    contentsOf: try String( contentsOfFile: inputFile ).components( separatedBy: "\n" ) )
            } else {
                print( "Enter the input data -" )
                while let line = readLine( strippingNewline: true ) {
                    inputLines.append( line )
                }
            }
            
            let inputText = inputLines.joined( separator: "\n" )
            try inputText.write( toFile: inputFile, atomically: true, encoding: .utf8 )
        }

        func getDataCurl( inputFile: String ) throws -> Bool {
            let fileManager = FileManager.default
            let year = URL( fileURLWithPath: fileManager.currentDirectoryPath ).lastPathComponent
            let sessionFile = ".session"
            
            guard package.hasPrefix( "day" ) else {
                print( "Can't get day number from '\(package)'" )
                return false
            }
            
            guard fileManager.fileExists(atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return false
            }
            
            let day = package.dropFirst( 3 )
            let session = try String( contentsOfFile: ".session" )
                .trimmingCharacters( in: CharacterSet( charactersIn: " \n" ) )
            let status = shell(
                "curl", "--silent", "--fail", "--cookie", "session=\(session)", "-o", inputFile, "https://adventofcode.com/\(year)/day/\(day)/input"
                )
            
            guard status == 0 else {
                print( "Can't retrieve data from adventofcode.com." )
                return false
            }
            
            return true
        }
    }
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
