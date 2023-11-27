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

extension AdventOfCode {
    struct Make: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create a new problem solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        @Flag( name: .shortAndLong, help: "When specified, prompts for input file header values." )
        var answers = false
        
        mutating func validate() throws {
            if let determined = determinePackage( package: package ) {
                package = determined
                return
            }

            throw reportFailure( "Cannot determine package from \(package)" )
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
                throw reportFailure( "Can't change back to initial directory." )
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
            let base        = package.prefix( 5 )
            let inputFile = "\(inputFolder)/\(base).txt"
            
            if !fileManager.fileExists( atPath: inputFolder ) {
                try fileManager.createDirectory( atPath: inputFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if !fileManager.fileExists( atPath: testsFolder ) {
                try fileManager.createDirectory( atPath: testsFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            return inputFile
        }
        
        func createSwiftSource( swiftFile: String ) throws -> String {
            let title = try getTitleCurl()
            let bundleURL = Bundle.module.url( forResource: "mainswift", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                throw reportFailure( "Can't find template for \(swiftFile)" )
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

        func getTitleCurl() throws -> String {
            let fileManager = FileManager.default
            let htmlFile = "\(package).html"
            let year = URL( fileURLWithPath: fileManager.currentDirectoryPath ).lastPathComponent
            let sessionFile = ".session"
            
            guard package.hasPrefix( "day" ) else {
                print( "Can't get day number from '\(package)'" )
                return getTitleUser()
            }
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return getTitleUser()
            }
            
            let day = Int( package.prefix( 5 ).dropFirst( 3 ) )!
            let session = try String( contentsOfFile: sessionFile )
                .trimmingCharacters( in: CharacterSet( charactersIn: " \n" ) )
            let status = shell(
                "curl", "--silent", "--fail", "--cookie", "session=\(session)", "-o", htmlFile, "https://adventofcode.com/\(year)/day/\(day)"
                )
            defer {
                do {
                    try fileManager.removeItem( atPath: htmlFile )
                } catch {
                    print( "Unable to delete \(htmlFile)")
                }
            }

            guard status == 0 else {
                print( "Can't retrieve data from adventofcode.com." )
                return getTitleUser()
            }
            
            let html = try String( contentsOfFile: htmlFile )
            let titleRegex = try Regex( "<title>Day \\d+ - (.+)</title>", as: ( Substring, Substring ).self )
            guard let titleMatch = try titleRegex.firstMatch( in: html ) else {
                print( "testMatch fail" )
                return getTitleUser()
            }

            let descriptionRegex = try Regex( "<h2>[^ ]+ (.+) [^ ]+</h2>", as: ( Substring, Substring ).self )
            guard let descriptionMatch = try descriptionRegex.firstMatch( in: html ) else {
                print( "Can't find description in html." )
                return getTitleUser()
            }

            return "\(titleMatch.1) \(descriptionMatch.1)"
        }

        func getTitleUser() -> String {
            getString( prompt: "Enter puzzle title", preferred: nil )
        }
        
        func createInput( inputFile: String ) throws -> Void {
            let fileManager = FileManager.default

            if fileManager.fileExists( atPath: inputFile ) {
                let prompt = "\(inputFile) already exist, do you want to recreate"
                if !askYN( prompt: prompt, expected: false ) { return }
                
                let oldFile = "old-\(inputFile)"
                print( "Moving \(inputFile) to \(oldFile)" )
                try fileManager.moveItem( atPath: inputFile, toPath: oldFile )
            }
            
            let part1 = !answers ? "" : getString( prompt: "Enter part1 solution", preferred: "" )
            let part2 = !answers ? "" : getString( prompt: "Enter part2 solution", preferred: "" )
            var extras = [String]()
            
            if answers {
                print( "Enter extra header lines -" )
                while let line = readLine( strippingNewline: true ) {
                    if line == "" { break }
                    extras.append( line )
                }
            }
            
            var inputLines = [ part1, part2 ] + extras + [ "--------------------" ]
            
            if try getDataCurl( inputFile: inputFile ) {
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
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return false
            }
            
            let day = Int( package.prefix( 5 ).dropFirst( 3 ) )!
            let session = try String( contentsOfFile: sessionFile )
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
