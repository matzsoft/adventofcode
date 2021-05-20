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
    let header: [String]
    let lines:  [String]

    var part1:  String?  { header[0] != "" ? header[0] : nil }
    var part2:  String?  { header[1] != "" ? header[1] : nil }
    var extras: [String] { Array( header[2...] ) }
    var line:   String   { lines[0] }
    var paragraphs: [[String]] {
        lines.split( separator: "", omittingEmptySubsequences: false ).map { $0.map { String( $0 ) } }
    }
    
    init( filename: String ) throws {
        let contents = try String( contentsOfFile: filename )
        
        // The following is to accomodate Visual Studio Code.  It treats the LF character as a line
        // separator unlike most programs which treat LF as a line terminator.
        let rawLines = contents.last! == "\n"
            ? contents.dropLast().components( separatedBy: "\n" )
            : contents.components( separatedBy: "\n" )

        let parts = rawLines.split( maxSplits: 1 ) { !$0.isEmpty && $0.allSatisfy { $0 == "-" } }
        
        guard parts.count == 2 else { throw RuntimeError( "No header seperator in \(filename)." ) }
        
        header = Array( parts[0] )
        lines = Array( parts[1] )
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


func formatElapsed( startTime: CFAbsoluteTime ) -> String {
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    
    if timeElapsed < 1 {
        return String( Int( timeElapsed * 1000 ) ) + "ms"
    }
    
    let seconds = String( Int( timeElapsed ) ) + "s"
    let milliSeconds = String( Int( 1000 * ( timeElapsed - CFAbsoluteTime( Int( timeElapsed ) ) ) ) ) + "ms"
    
    return seconds + milliSeconds
}


// MARK: - functions for getting puzzle and test input.

func getAOCinput() throws -> AOCinput {
    let inputDirectory = try findDirectory( name: "input" )
    let project = URL( fileURLWithPath: #file ).deletingLastPathComponent().lastPathComponent
    let filename = "\(inputDirectory)/\(project).txt"
    
    return try AOCinput( filename: filename )
}


func getTests() throws -> [AOCinput] {
    let inputDirectory = try findDirectory( name: "testfiles" )
    let project = URL( fileURLWithPath: #file ).deletingLastPathComponent().lastPathComponent
    let pattern = "\(inputDirectory)/\(project)*.txt"
    
    return try glob( pattern: pattern ).map { try AOCinput( filename: $0 ) }
}

// MARK: - functions for running solutions and tests.

func runPart1( part1: ( ( AOCinput ) -> String ), label: String = "" ) throws -> Void {
    let input = try getAOCinput()
    let label = label == "" ? "Part1" : "Part1 \(label)"
    
    runSolution( label: label, function: part1, input: input, expected: input.part1 )
}


func runPart2( part2: ( ( AOCinput ) -> String ), label: String = "" ) throws -> Void {
    let input = try getAOCinput()
    let label = label == "" ? "Part2" : "Part2 \(label)"
    
    runSolution( label: label, function: part2, input: input, expected: input.part2 )
}


func runSolution( label: String, function: ( AOCinput ) -> String, input: AOCinput, expected: String? ) {
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


func runTestsPart1( part1: ( ( AOCinput ) -> String ), label: String = "" ) throws -> Void {
    let tests = try getTests()
    let label = label == "" ? "Part1" : "Part1 \(label)"
    var successes = 0
    
    for ( index, test ) in tests.enumerated() {
        if let expected = test.part1 {
            let result = part1( test )
            
            if result == expected {
                successes += 1
            } else {
                print( "Test \(index) \(label): \(result), should be \(expected)" )
            }
        }
    }
    
    print( "\(successes) \(label) tests ran successfully" )
}


func runTestsPart2( part2: ( ( AOCinput ) -> String ), label: String = "" ) throws -> Void {
    let tests = try getTests()
    let label = label == "" ? "Part2" : "Part2 \(label)"
    var successes = 0
    
    for ( index, test ) in tests.enumerated() {
        if let expected = test.part2 {
            let result = part2( test )
            
            if result == expected {
                successes += 1
            } else {
                print( "Test \(index) \(label): \(result), should be \(expected)" )
            }
        }
    }
    
    print( "\(successes) \(label) tests ran successfully" )
}


// MARK: - deprecated functions for running solutions and tests.

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


func runSolutions( part1: ( ( AOCinput ) -> String )?, part2: ( ( AOCinput ) -> String )? ) throws -> Void {
    let input = try getAOCinput()
    
    if let part1 = part1 {
        runSolution( label: "Part1", function: part1, input: input, expected: input.part1 )
    }
    
    if let part2 = part2 {
        runSolution( label: "Part2", function: part2, input: input, expected: input.part2 )
    }
}
