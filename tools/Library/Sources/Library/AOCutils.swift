//
//  AOCutils.swift
//  
//
//  Created by Mark Johnson on 2/23/21.
//

import Foundation

public enum AOCPart { case part1, part2 }

/// Used for throwing generalized exceptions.
///
/// The init takes one parameter, message: any string describing the error condition.
public struct RuntimeError: Error {
    let message: String

    public init( _ message: String ) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}


/// Parses an AOC input or test file for easy access.
///
/// Available properties are:
///
/// - part1 - the expected answer for part1. A value of nil means unknown for input files or
///  irrelevant for test files.
/// - part2 - the expected answer for part2, like part1.
/// - line  - the first line of the input data. Useful when a problem only has one line of data.
/// - lines - an array of all the lines of the input.
/// - paragraphs - the input for some problems is organized in paragraphs.  This property is an
///  array of paragraphs, each paragraph an array of lines.
/// - extras - some problems require different info for the tests and the real data.  This info is
///  provided as extra lines in the header.
public struct AOCinput {
    let header: [String]
    public let filename: String
    public let lines:  [String]

    public var part1:  String?  { header[0] != "" ? header[0] : nil }
    public var part2:  String?  { header[1] != "" ? header[1] : nil }
    public var extras: [String] { Array( header[2...] ) }
    public var line:   String   { lines[0] }
    public var paragraphs: [[String]] {
        lines.split( separator: "", omittingEmptySubsequences: false ).map { $0.map { String( $0 ) } }
    }
    
    /// Initializes an AOCinput structure from the given filename.
    /// - Parameter filename: The pathname of the file containing the input or test data.
    public init( filename: String ) throws {
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
    
    /// Initializes an AOCinput structure from the specified parameters.
    /// - Parameters
    ///   - part1: The correct answer for part 1 or the empty string for unknown or irrelevant.
    ///   - part2: The correct answer for part 2 or the empty string for unknown or irrelevant.
    ///   - extras: An array of lines of additional info needed for this data.
    ///   - lines: An array of lines containing the actual data.
    ///   - filename: The name of the file that will contain the data.
    public init( part1: String, part2: String, extras: [String], lines: [String], filename: String = "" ) {
        header = [ part1, part2 ] + extras
        self.filename = filename
        self.lines = lines
    }
    
    /// Writes the AOCinput data to its specified filename.
    /// - Throws: Any thrown by writing the file.
    public func write() throws -> Void {
        let contents = ( header + [ "--------------------" ] + self.lines ).joined( separator: "\n" )
        try contents.write( toFile: filename, atomically: true, encoding: .utf8 )
    }
}


/// Finds the name of the project by navigating up the directory tree from main.swift.
/// - Parameter base: The pathname of where to start looking.  Defaults to source file of the caller.
/// - Returns: The name of the current project, e.g. day07.
func getProjectName( base: String = #file ) -> String {
    URL( fileURLWithPath: base ).deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
}


/// Gets the project info for the current project.
/// - Parameter sourceFile: The pathname of main.swift.  Defaults to the source file of the caller.
/// - Throws: Only when a URL can't be created from sourceFile.
/// - Returns: A string with "Advent of Code", the year, the day name, and whether we have a debug
///  or release build.
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


/// Finds the path to a named directory by searching the directory tree.
///
/// Starts the search at given path and proceeds up the directory tree until the named directory is found.
///
/// - Parameters:
///   - name: The name of the desired directory.
///   - base: The path of the place to start the search.
/// - Throws: A RuntimeError if the named directory cannot be found.
/// - Returns: The full path to the desired directory.
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


/// Nicely formats the time elapsed from a given start time.
/// - Parameter startTime: The start time of the interval to format.
/// - Returns: A string formated e.g. 14ms, or 3.034s, etc.
func formatElapsed( startTime: CFAbsoluteTime ) -> String {
    formatElapsed( time: CFAbsoluteTimeGetCurrent() - startTime )
}
public func formatElapsed( time timeElapsed: CFAbsoluteTime ) -> String {
    let seconds = Int( timeElapsed )
    
    return switch timeElapsed {
    case let timeElapsed where timeElapsed < 1:
        String( Int( timeElapsed * 1000 ) ) + "ms"
    case let timeElapsed where timeElapsed < 10:
        String( format: "\(seconds).%03d", Int( 1000 * timeElapsed ) % 1000 ) + "s"
    case let timeElapsed where timeElapsed < 60:
        "\(seconds)s"
    case let timeElapsed where timeElapsed < 3600:
        {
            let minutes = seconds / 60
            let newSeconds = seconds % 60
            return String( format: "\(minutes):%02d", newSeconds ) + "m"
        }()
    case let timeElapsed where timeElapsed < 86400:
        {
            let hours = seconds / 3600
            let minutes = seconds % 3600 / 60
            let newSeconds = seconds % 60
            return String( format: "\(hours):%02d:%02d", minutes, newSeconds ) + "h"
        }()
    default:
        {
            let days = seconds / 86400
            let hours = (seconds % 86400) / 3600
            let minutes = (seconds % 3600) / 60
            let newSeconds = seconds % 60
            return String( format: "\(days):%02d:%02d:%02d", hours, minutes, newSeconds ) + "d"
        }()
    }
}


// MARK: - functions for getting puzzle and test input.

/// Gets the AOCinput structure of the input file for the current project.
/// - Parameter base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the input directory can't be found.
/// - Returns: An AOCinput structure containing the input data.
public func getAOCinput( base: String = #file ) throws -> AOCinput {
    let inputDirectory = try findDirectory( name: "input", base: base )
    let project = getProjectName( base: base )
    let filename = "\(inputDirectory)/\(project.prefix( 5 )).txt"
    
    return try AOCinput( filename: filename )
}


/// Gets an array of AOCinput structures for all the test files for the current project.
/// - Parameter base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the testfiles directory can't be found.
/// - Returns: An array of AOCinput structures containing the data for all the test files.
func getTests( base: String = #file ) throws -> [AOCinput] {
    let inputDirectory = try findDirectory( name: "testfiles", base: base )
    let project = getProjectName( base: base )
    let pattern = "\(inputDirectory)/\(project.prefix( 5 ))*.txt"
    
    return try glob( pattern: pattern ).map { try AOCinput( filename: $0 ) }
}

// MARK: - functions for running solutions and tests.

/// Runs a part 1 solution for the current problem and prints a summary of the result.
/// - Parameters:
///   - part1: A function that actually runs part 1.
///   - label: An optional label to be added to the summary output.
///   - base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the input directory can't be found.
public func solve( part1: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let input = try getAOCinput( base: base )
    let label = label == "" ? "Part1" : "Part1 \(label)"
    
    runSolution( label: label, function: part1, input: input, expected: input.part1 )
}


/// Runs a part 2 solution for the current problem and prints a summary of the result.
/// - Parameters:
///   - part2: A function that actually runs part 2.
///   - label: An optional label to be added to the summary output.
///   - base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the input directory can't be found.
public func solve( part2: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let input = try getAOCinput( base: base )
    let label = label == "" ? "Part2" : "Part2 \(label)"
    
    runSolution( label: label, function: part2, input: input, expected: input.part2 )
}


/// Runs a solution for one part of the current problem and prints a summary of the result.
///
/// The summary contains a label, the actual result produced, a success indicator, and the elapsed time.
///
/// If the expected result is not yet known, the success indicator will not be shown.
///
/// Otherwise the success indicator will either be "Correct!" or the expected result.
///
/// - Parameters:
///   - label: A string indicating the part being run and any additional information.
///   - function: A function that actually runs the desired part.
///   - input: The AOCinput structure containing the data for the run.
///   - expected: The expected result or nil if not yet known.
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


/// Runs all the tests for the part 1 solution to the current problem and prints a summary of the results.
/// - Parameters:
///   - part1: A function that actually runs part 1.
///   - label: An optional label to be added to the summary output.
///   - base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the input directory can't be found.
public func runTests( part1: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let tests = try getTests( base: base ).filter { $0.part1 != nil }.map { ( $0, $0.part1! ) }
    let label = label == "" ? "Part1" : "Part1 \(label)"
    
    runTests( part: part1, tests: tests, label: label )
}


/// Runs all the tests for the part 2 solution to the current problem and prints a summary of the results.
/// - Parameters:
///   - part2: A function that actually runs part 2.
///   - label: An optional label to be added to the summary output.
///   - base: The path to the source file for main.swift.  Defaults to the source file of the caller.
/// - Throws: A RuntimeError if the input directory can't be found.
public func runTests( part2: ( ( AOCinput ) -> String ), label: String = "", base: String = #file ) throws {
    let tests = try getTests( base: base ).filter { $0.part2 != nil }.map { ( $0, $0.part2! ) }
    let label = label == "" ? "Part2" : "Part2 \(label)"
    
    runTests( part: part2, tests: tests, label: label )
}

/// Runs all the tests for one part of the current problem and prints a summary of the results.
///
/// The summary consists of one line for every test that fails and one line showing the overall
///  status of the tests.
///
/// When a test fails its summary line shows the test name, the given label, the actual result,
///  and the expected result.
///
/// After all tests are run the final line shows how many tests passed, how many were run, the label,
///  and the elapsed time to run all tests.
///
/// - Parameters:
///   - part: A function that actually runs the desired part.
///   - tests: An array of tuples.  Each tuple has an AOCinput structure with the test data and
///    a String with the expected result for that data.
///   - label: A string indicating the part being run and any additional information.
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
