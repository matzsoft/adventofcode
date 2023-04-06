//
//  AOCutils.swift
//  
//
//  Created by Mark Johnson on 2/23/21.
//

import Foundation

public enum AOCPart { case part1, part2 }

public struct RuntimeError: Error {
    let message: String

    public init( _ message: String ) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}


public struct AOCinput {
    let header: [String]
    public let lines:  [String]
    let filename: String

    var part1:  String?  { header[0] != "" ? header[0] : nil }
    var part2:  String?  { header[1] != "" ? header[1] : nil }
    public var extras: [String] { Array( header[2...] ) }
    public var line:   String   { lines[0] }
    public var paragraphs: [[String]] {
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
        self.filename = URL( fileURLWithPath: filename ).deletingPathExtension().lastPathComponent
    }
}


func getProjectName( base: String = #file ) -> String {
    URL( fileURLWithPath: base ).deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
}


public func projectInfo( sourceFile: String = #file ) throws -> String {
    let input = try URL( fileURLWithPath: findDirectory( name: "input", base: sourceFile ) )
    let year = input.deletingLastPathComponent().lastPathComponent
    let project = getProjectName( base: sourceFile )
    
    #if DEBUG
    return "Advent of Code \(year) \(project), Debug Build"
    #else
    return "Advent of Code \(year) \(project), Release Build"
    #endif
}


public func findDirectory( name: String, base: String = #file ) throws -> String {
    let fileManager = FileManager.default
    var directory = URL( fileURLWithPath: base ).deletingLastPathComponent().path
    
    while directory != "/" {
        var isDir : ObjCBool = false
        
        if fileManager.fileExists( atPath: "\(directory)/\(name)", isDirectory:&isDir ) {
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

func getAOCinput( base: String = #file ) throws -> AOCinput {
    let inputDirectory = try findDirectory( name: "input", base: base )
    let project = getProjectName( base: base )
    let filename = "\(inputDirectory)/\(project.prefix( 5 )).txt"
    
    return try AOCinput( filename: filename )
}


func getTests( base: String = #file ) throws -> [AOCinput] {
    let inputDirectory = try findDirectory( name: "testfiles", base: base )
    let project = getProjectName( base: base )
    let pattern = "\(inputDirectory)/\(project.prefix( 5 ))*.txt"
    
    return try glob( pattern: pattern ).map { try AOCinput( filename: $0 ) }
}

// MARK: - functions for running solutions and tests.

public func solve( part1: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let input = try getAOCinput( base: base )
    let label = label == "" ? "Part1" : "Part1 \(label)"
    
    runSolution( label: label, function: part1, input: input, expected: input.part1 )
}


public func solve( part2: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let input = try getAOCinput( base: base )
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


public func runTests( part1: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let tests = try getTests( base: base ).filter { $0.part1 != nil }.map { ( $0, $0.part1! ) }
    let label = label == "" ? "Part1" : "Part1 \(label)"
    
    runTests( part: part1, tests: tests, label: label )
}


public func runTests( part2: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let tests = try getTests( base: base ).filter { $0.part2 != nil }.map { ( $0, $0.part2! ) }
    let label = label == "" ? "Part2" : "Part2 \(label)"
    
    runTests( part: part2, tests: tests, label: label )
}

func runTests( part: ( ( AOCinput ) -> String ), tests: [ ( AOCinput, String ) ], label: String ) -> Void {
    var successes = 0
    let startTime = CFAbsoluteTimeGetCurrent()

    for ( test, expected ) in tests {
        let result = part( test )
        
        if result == expected {
            successes += 1
        } else {
            print( "Test \(test.filename) \(label): \(result), should be \(expected)" )
        }
    }
    
    let timeElapsed = formatElapsed( startTime: startTime )

    print( "\(successes) of \(tests.count) \(label) tests ran successfully (\(timeElapsed))" )
}
