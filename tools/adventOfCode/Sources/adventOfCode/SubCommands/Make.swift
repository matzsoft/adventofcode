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
        static let configuration = CommandConfiguration(
            abstract: "Create a new problem solution."
        )
        
        @Argument( help: "Name of the solution package to create." )
        var package: String
        
        @Flag( name: .shortAndLong, help: "When specified, prompts for input file header values." )
        var answers = false
        
        var baseURL: String { "https://adventofcode.com" }
        var year = 0
        var day  = 0
        
        mutating func validate() throws {
            let ( year, day, package ) = try determinePackage( package: package )
            
            self.year    = year
            self.day     = day
            self.package = package
        }
        
        func run() throws -> Void {
            let fileManager = FileManager.default
            let packageFile = "\(package)/Package.swift"
            let swiftFile   = "\(package)/Sources/main.swift"
            let inputFile   = try createDirectories()
            
            if !fileManager.fileExists(atPath: packageFile ) {
                let packageContents = try createPackageSwift( directory: package, package: package )
                try packageContents.write( toFile: packageFile, atomically: true, encoding: .utf8 )
            }
            
            try waitUntilAvailable()
            try findTab( urlPrefix: baseURL )
            let jsLink = "location.href='\(baseURL)/\(year)/day/\(day)'"
            if let error = try doJavaScript( javascript: jsLink ) {
                throw AppleScriptError.cantLinkToURL( error.description )
            }

            if !fileManager.fileExists( atPath: swiftFile ) {
                let swiftFileSource = try createSwiftSource( swiftFile: swiftFile )
                try swiftFileSource.write( toFile: swiftFile, atomically: true, encoding: .utf8 )
            }

            if !fileManager.fileExists( atPath: inputFile ) {
                try createInput( inputFile: inputFile )
            }
            
            guard try shell( stdout: nil, "open", packageFile ) == 0 else {
                throw RuntimeError( "Can't open \(packageFile)." )
            }
        }

        func waitUntilAvailable() throws -> Void {
            let targetTimeZone  = TimeZone( identifier: "America/New_York" )
            var components      = DateComponents()
            components.timeZone = targetTimeZone
            components.year     = year
            components.month    = 12
            components.day      = day
            components.hour     = 0
            components.minute   = 0
            components.second   = 1

            var calendar = Calendar( identifier: .gregorian )
            calendar.timeZone = targetTimeZone ?? .current

            guard let availableDate = calendar.date( from: components ) else {
                throw RuntimeError( "Failed to create date for \(year) and \(package)" )
            }
            
            if Date() < availableDate {
                print( "Waiting for input file to be available..." )
                waitUntil( availableDate )
            }
        }
                
        func createDirectories() throws -> String {
            let fileManager   = FileManager.default
            let sourcesFolder = "\(package)/Sources"
            let inputFolder   = "input"
            let testsFolder   = "testfiles"
            
            if !fileManager.fileExists( atPath: sourcesFolder ) {
                try fileManager.createDirectory( atPath: sourcesFolder, withIntermediateDirectories: true, attributes: nil )
            }
            
            if !fileManager.fileExists( atPath: inputFolder ) {
                try fileManager.createDirectory( atPath: inputFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            if !fileManager.fileExists( atPath: testsFolder ) {
                try fileManager.createDirectory( atPath: testsFolder, withIntermediateDirectories: false, attributes: nil )
            }
            
            return "\(inputFolder)/\(package.prefix( 5 )).txt"
        }
        
        func createSwiftSource( swiftFile: String ) throws -> String {
            let title     = try getTitleCurl()
            let bundleURL = Bundle.module.url( forResource: "mainswift", withExtension: "mustache" )
            guard let templateURL = bundleURL else {
                throw RuntimeError( "Can't find template for \(swiftFile)" )
            }
            let template          = try Template( URL: templateURL )
            let dateFormatterFull = DateFormatter()
            let dateFormatterYear = DateFormatter()
            
            dateFormatterFull.dateFormat = "MM/dd/yy HH:mm:ss"
            dateFormatterYear.dateFormat = "yyyy"

            let templateData: [String: Any] = [
                "package": package,
                "title":   title,
                "date":    dateFormatterFull.string( from: Date() ),
                "year":    dateFormatterYear.string( from: Date() )
            ]
            
            return try template.render( templateData )
        }

        func getTitleCurl() throws -> String {
            let fileManager = FileManager.default
            let htmlFile    = "\(package).html"
            let sessionFile = ".session"
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return getTitleUser()
            }
            
            let session = try String( contentsOfFile: sessionFile, encoding: .utf8 )
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
            
            let html       = try String( contentsOfFile: htmlFile, encoding: .utf8 )
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
            let part1     = !answers  ? "" : getString( prompt: "Enter part1 solution", preferred: "" )
            let part2     = !answers  ? "" : getString( prompt: "Enter part2 solution", preferred: "" )
            let extras    = !answers ? [] : getLines( prompt: "Enter extra header lines", blanksOK: true )
            let dataLines = try {
                if try getDataCurl( inputFile: inputFile ) {
                    return try String( contentsOfFile: inputFile, encoding: .utf8 ).components( separatedBy: "\n" )
                } else {
                    return getLines( prompt: "Enter the input data" )
                }
            }()
            let input = AOCinput( part1: part1, part2: part2, extras: extras, lines: dataLines, filename: inputFile )
            
            try input.write()
        }

        func getDataCurl( inputFile: String ) throws -> Bool {
            let fileManager = FileManager.default
            let sessionFile = ".session"
            
            guard fileManager.fileExists( atPath: sessionFile ) else {
                print( "\(sessionFile) doesn't exist." )
                return false
            }
            
            let session = try String( contentsOfFile: sessionFile, encoding: .utf8 )
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


func waitUntil( _ targetDate: Date ) -> Void {
    while Date() < targetDate {
        let timeDiff = targetDate.timeIntervalSince( Date() )
        print( "\r\(countDownFormat( timeDiff ))", terminator: "\u{001B}[K" )
        fflush( stdout )
        sleep( UInt32( sleepTime( timeDiff ) ) )
    }
    print( "\r", terminator: "\u{001B}[K" )
    fflush( stdout )
}


func countDownFormat( _ interval: TimeInterval ) -> String {
    let start      = Date()
    let end        = start.addingTimeInterval( interval )
    let components = Calendar.current.dateComponents(
        [ .day, .hour, .minute, .second ], from: start, to: end
    )
    let days    = components.day ?? 0
    let hours   = components.hour ?? 0
    let minutes = components.minute ?? 0
    let seconds = components.second ?? 0
    
    if days > 0 { return "\(days.string( unit: "day" )), \(hours.string( unit: "hour" ))" }
    if hours > 0 { return "\(hours.string( unit: "hour" )), \(minutes.string( unit: "minute" ))" }
    if minutes > 0 { return "\(minutes.string( unit: "minute" )), \(seconds.string( unit: "second" ))" }
    return "\(seconds.string( unit: "second" ))"
}


func sleepTime( _ interval: TimeInterval ) -> Int {
    let start      = Date()
    let end        = start.addingTimeInterval( interval )
    let components = Calendar.current.dateComponents( [ .day, .hour, .minute, .second ], from: start, to: end )
    if let days    = components.day, days > 0 { return 1800 }
    if let hours   = components.hour, hours > 0 { return 30 }
    if let minutes = components.minute, minutes > 0 { return 10 }

    return ( components.second ?? 0 ) > 10 ? 5 : 1
}
