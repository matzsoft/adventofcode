//
//         FILE: main.swift
//  DESCRIPTION: day08 - Seven Segment Search
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/07/21 21:00:16
//

import Foundation

let correct = [
    Set( "abcefg" ), Set( "cf" ), Set( "acdeg" ), Set( "acdfg" ), Set( "bcdf" ),
    Set( "abdfg" ), Set( "abdefg" ), Set( "acf" ), Set( "abcdefg" ), Set( "abcdfg" )
]
let uniqueCounts = correct.reduce( into: [ Int : Int ]() ) {
    $0[ $1.count, default: 0 ] += 1
}.filter { $0.value == 1 }.map { $0.key }

struct Note {
    let input: [Set<Character>]
    let output: [Set<Character>]
    
    init( line: String ) {
        let words = line.split(whereSeparator: { " |".contains( $0 ) } )
        
        input = words[..<10].map { Set( $0 ) }
        output = words[10...].map { Set( $0 ) }
    }
}


func signature( digit: Set<Character>, uniques: [Set<Character>] ) -> Int {
    return Int( uniques.map { String( digit.intersection( $0 ).count ) }.joined() )!
}


func parse( input: AOCinput ) -> [Note] {
    return input.lines.map { Note( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let notes = parse( input: input )
    let digits = notes.flatMap { $0.output }.filter { uniqueCounts.contains( $0.count ) }
    return "\(digits.count)"
}


func part2( input: AOCinput ) -> String {
    let notes = parse( input: input )
    let uniqueDigits = uniqueCounts.map { count in correct.first( where: { $0.count == count } )! }
    let signatures = ( 0 ..< correct.count ).reduce( into: [ Int : Int ]() ) {
        $0[ signature( digit: correct[$1], uniques: uniqueDigits ) ] = $1
    }
    var sum = 0
    
    for note in notes {
        let uniqueInputs = uniqueCounts.map { count in note.input.first( where: { $0.count == count } )! }
        let value = note.output.map {
            String( signatures[ signature( digit: $0, uniques: uniqueInputs ) ]! )
        }
        
        sum += Int( value.joined() )!
    }
    return "\(sum)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
