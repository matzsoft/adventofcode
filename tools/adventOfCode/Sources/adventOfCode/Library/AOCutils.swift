//
//  AOCutils.swift
//  
//
//  Created by Mark Johnson on 2/23/21.
//

import Foundation

enum AOCPart { case part1, part2 }

struct RuntimeError: Error {
    let message: String

    init( _ message: String ) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}


struct AOCinput {
    let content: [Substring]

    var part1: String? { return content[0] != "" ? String( content[0] ) : nil }
    var part2: String? { return content[1] != "" ? String( content[1] ) : nil }
    var line: String { return String( content[2] ) }
    var lines: [String] { return content[2...].map { String( $0 ) } }
    var paragraphs: [[String]] {
        return content[2...].split( separator: "" ).map { $0.map { String( $0 ) } }
    }
    
    init( filename: String ) throws {
        let contents = try String( contentsOfFile: filename )
        
        if contents.last! == "\n" {
            content = contents.dropLast().split( separator: "\n", omittingEmptySubsequences: false )
        } else {
            content = contents.split( separator: "\n", omittingEmptySubsequences: false )
        }
    }
}


func findDirectory( name: String ) throws -> String {
    let fileManager = FileManager.default
    var directory = URL( fileURLWithPath: #file ).deletingLastPathComponent().path
    
    while directory != "/" {
        var isDir : ObjCBool = false
        
        if fileManager.fileExists(atPath: "\(directory)/\(name)", isDirectory:&isDir) {
            if isDir.boolValue {
                return "\(directory)/\(name)"
            }
        }
        
        directory = URL( fileURLWithPath: directory ).deletingLastPathComponent().path
    }
    
    throw RuntimeError( "Can't find \(name) directory!" )
}


func getTests() throws -> [AOCinput] {
    let inputDirectory = try findDirectory( name: "input" )
    let project = URL( fileURLWithPath: #file ).deletingLastPathComponent().lastPathComponent
    let pattern = "\(inputDirectory)/\(project)T*.txt"
    
    return try glob( pattern: pattern ).map { try AOCinput( filename: $0 ) }
}


func runTests( part1: ( ( AOCinput ) -> String )?, part2: ( ( AOCinput ) -> String )? ) throws -> Void {
    let tests = try getTests()
    var successes = 0
    
    for ( index, test ) in tests.enumerated() {
        if let part1 = part1, let expected = test.part1 {
            let result = part1( test )
            
            if result == expected {
                successes += 1
            } else {
                print( "Test \(index) Part 1: \(result), should be \(expected)" )
            }
        }
        
        if let part2 = part2, let expected = test.part2 {
            let result = part2( test )
            
            if result == expected {
                successes += 1
            } else {
                print( "Test \(index) Part 2: \(result), should be \(expected)" )
            }
        }
    }
    
    print( "\(successes) tests ran successfully" )
}


func getAOCinput() throws -> AOCinput {
    let inputDirectory = try findDirectory( name: "input" )
    let project = URL( fileURLWithPath: #file ).deletingLastPathComponent().lastPathComponent
    let filename = "\(inputDirectory)/\(project).txt"
    
    return try AOCinput( filename: filename )
}


func formatElapsed( startTime: CFAbsoluteTime ) -> String {
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    
    if timeElapsed < 1 {
        return String( Int( timeElapsed * 1000 ) ) + "ms"
    }
    
    let seconds = String( Int( timeElapsed ) ) + "s"
    let milliSeconds = String( Int( 1000 * ( timeElapsed - CFAbsoluteTime( Int( timeElapsed ) ) ) ) ) + "ms"
    
    return seconds + milliSeconds
}


func runSolution( label: String, function: ( AOCinput ) -> String, input: AOCinput, expected: String? ) -> Void {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = function( input )
    let timeElapsed = formatElapsed( startTime: startTime )
    
    guard let expected = expected else {
        print( "\(label): \(result), (\(timeElapsed))" )
        return
    }
    
    if result == expected {
        print( "\(label): \(result), Correct! (\(timeElapsed))" )
    } else {
        print( "\(label): \(result), should be \(expected) (\(timeElapsed))" )
    }
}


func runSolutions( part1: ( ( AOCinput ) -> String )?, part2: ( ( AOCinput ) -> String )? ) throws -> Void {
    let input = try getAOCinput()
    
    if let part1 = part1 {
        runSolution( label: "Part1", function: part1, input: input, expected: input.part1 )
    }
    
    if let part2 = part2 {
        runSolution( label: "Part2", function: part2, input: input, expected: input.part2 )
    }
}
