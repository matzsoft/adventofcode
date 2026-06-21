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
import Library
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Make: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create a new problem solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        @Flag( name: .shortAndLong, help: "When specified, prompts for input file header values." )
        var answers = false
        
        var baseURL: String { "https://adventofcode.com" }
        var year = 0
        var day = 0
        
        mutating func validate() throws {
            let ( year, day, package ) = try determinePackage( package: package )
            
            self.year = year
            self.day = day
            self.package = package
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let currentDirectory = fileManager.currentDirectoryPath
            let swiftFile = "\(package).swift"
            let oldFile = "old-\(swiftFile)"
            let inputFile = try setupInput()
            
            try waitUntilAvailable()
            try findTab( urlPrefix: baseURL )
            let jsLink = "location.href='\(baseURL)/\(year)/day/\(day)'"
            if let error = try doJavaScript( javascript: jsLink ) {
                throw AppleScriptError.cantLinkToURL( error.description )
            }

            if fileManager.fileExists( atPath: swiftFile ) {
                print( "\(swiftFile) already exists, moving it to \(oldFile)" )
                try fileManager.moveItem( atPath: swiftFile, toPath: oldFile )
            }

            let swiftFileSource = try createSwiftSource( swiftFile: swiftFile )

            try createInput( inputFile: inputFile )
            try swiftFileSource.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            try performOpen( package: package )
            
            guard fileManager.changeCurrentDirectoryPath( currentDirectory ) else {
                throw RuntimeError( "Can't change back to initial directory." )
            }
            
            if fileManager.fileExists( atPath: oldFile ) {
                print( "Moving \(oldFile) back to \(swiftFile)" )
                try fileManager.removeItem( atPath: swiftFile )
                try fileManager.moveItem( atPath: oldFile, toPath: swiftFile )
            }
        }

        func waitUntilAvailable() throws -> Void {
            let targetTimeZone = TimeZone( identifier: "America/New_York" )
            var components = DateComponents()
            components.timeZone = targetTimeZone
            components.year = year
            components.month = 12
            components.day = day
            components.hour = 0
            components.minute = 0
            components.second = 1

            var calendar = Calendar( identifier: .gregorian )
            calendar.timeZone = targetTimeZone ?? .current

            guard let availableDate = calendar.date( from: components ) else {
                throw RuntimeError( "Failed to create date for \(year) and \(package)" )
            }
            
            if Date() < availableDate {
                print( "Waiting for input file to be available..." )
                while Date() < availableDate {
                    let ( label, sleepTime ) = formatAndWait( availableDate: availableDate )
                    print( "\r\(label)", terminator: "\u{001B}[K" )
                    fflush( stdout )
                    sleep( UInt32( sleepTime ) )
                }
                print( "\r", terminator: "\u{001B}[K" )
                fflush( stdout )
            }
        }
        
        func formatAndWait( availableDate: Date ) -> ( String, Int ) {
            let timeDiff = availableDate.timeIntervalSince( Date() )
            let days = Int( timeDiff / 86400 )
            if days > 0 {
                let hours = Int( timeDiff ) % 86400 / 3600
                return ( "\(days) days, \(hours) hours", 1800 )
            }
            
            let hours = Int( timeDiff / 3600 )
            if hours > 0 {
                let minutes = Int( timeDiff ) % 3600 / 60
                return ( "\(hours) hours, \(minutes) minutes", 30 )
            }
            
            let minutes = Int( timeDiff / 60 )
            if minutes > 0 {
                let seconds = Int( timeDiff ) % 60
                return ( "\(minutes) minutes, \(seconds) seconds", 10 )
            }
            
            let seconds = Int( timeDiff )
            return ( "\(seconds) seconds", seconds > 10 ? 5 : 1 )
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
                throw RuntimeError( "Can't find template for \(swiftFile)" )
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
            let sessionFile = ".session"
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return getTitleUser()
            }
            
            let session = try String( contentsOfFile: sessionFile )
                .trimmingCharacters( in: CharacterSet( charactersIn: " \n" ) )
            let status = try shell( stdout: nil,
                "curl", "--silent", "--fail", "--cookie", "session=\(session)", "-o", htmlFile, "\(baseURL)/\(year)/day/\(day)"
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
            
            let part1 = !answers  ? "" : getString( prompt: "Enter part1 solution", preferred: "" )
            let part2 = !answers  ? "" : getString( prompt: "Enter part2 solution", preferred: "" )
            let extras = !answers ? [] : getLines( prompt: "Enter extra header lines", blanksOK: true )
            let dataLines = try {
                if try getDataCurl( inputFile: inputFile ) {
                    return try String( contentsOfFile: inputFile ).components( separatedBy: "\n" )
                } else {
                    return getLines( prompt: "Enter the input data" )
                }
            }()
            let input = AOCinput(
                part1: part1, part2: part2, extras: extras, lines: dataLines, filename: inputFile )
            
            try input.write()
        }

        func getDataCurl( inputFile: String ) throws -> Bool {
            let fileManager = FileManager.default
            let sessionFile = ".session"
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return false
            }
            
            let session = try String( contentsOfFile: sessionFile )
                .trimmingCharacters( in: CharacterSet( charactersIn: " \n" ) )
            let status = try shell( stdout: nil,
                "curl", "--silent", "--fail", "--cookie", "session=\(session)", "-o", inputFile, "\(baseURL)/\(year)/day/\(day)/input"
            )
            
            guard status == 0 else {
                print( "Can't retrieve data from adventofcode.com." )
                return false
            }
            
            return true
        }
    }
}
