//
//         FILE: day01.swift
//  DESCRIPTION: Advent of Code 2023 Day 1: Trebuchet?!
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/30/23 21:00:08
//

import Foundation
import Library

extension String {
    // This is a crude replacement for a function natively available
    // in macOS 13+.
    func ranges( of pattern: String ) -> [Range<String.Index>] {
        let guess1 = String( repeating: " ", count: pattern.count )
        let guess2 = String( repeating: "_", count: pattern.count )
        let notPattern = pattern == guess1 ? guess2 : guess1
        var copy = self
        var ranges = [Range<String.Index>]()
        
        while let range = copy.range( of: pattern ) {
            ranges.append( range )
            copy.replaceSubrange( range, with: notPattern )
        }
        
        return ranges
    }
}

struct DigitWords {
    let range: Range<String.Index>
    let value: String
    
    func union( with other: DigitWords ) -> DigitWords {
        if range.lowerBound < other.range.lowerBound {
            return DigitWords(
                range: range.lowerBound ..< other.range.upperBound, value: value + other.value
            )
        } else {
            return DigitWords(
                range: other.range.lowerBound ..< range.upperBound, value: other.value + value
            )
        }
    }
}

let names = [
    "one"   : "1", "two"   : "2", "three" : "3",
    "four"  : "4", "five"  : "5", "six"   : "6",
    "seven" : "7", "eight" : "8", "nine"  : "9"
]

func extractValue( line: String ) -> Int {
    let digits = Array( line ).filter { $0.isNumber }.map { String( $0 ) }
    return Int( digits.first! + digits.last! )!
}



func part1( input: AOCinput ) -> String {
    String( input.lines.map { extractValue( line: $0 ) }.reduce( 0, + ) )
}


func combineRanges( ranges: [DigitWords] ) -> [DigitWords] {
    if ranges.isEmpty { return ranges }
    guard let index = ( 0 ..< ranges.count - 1 ).first( where: {
        ranges[$0].range.overlaps( ranges[$0+1].range )
    } ) else { return ranges }
    
    return ranges[0..<index] + [ ranges[index].union( with: ranges[index+1] ) ] + ranges[(index+2)...]
}


func replaceDigitWords( line: String ) -> String {
    let allRanges = names.reduce( into: [DigitWords]() ) { list, name in
        let ranges = line.ranges( of: name.key ).map { DigitWords( range: $0, value: name.value ) }
        list.append( contentsOf: ranges )
    }.sorted( by: { $0.range.lowerBound > $1.range.lowerBound } )
    let combinedRanges = combineRanges( ranges: allRanges )
    
    return combinedRanges.reduce( into: line ) { line, range in
        line.replaceSubrange( range.range, with: range.value )
    }
}


func part2( input: AOCinput ) -> String {
    String(
        input.lines
            .map { replaceDigitWords( line: $0 ) }
            .map { extractValue( line: $0 ) }
            .reduce( 0, + )
    )
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
