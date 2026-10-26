//
//         FILE: day04.swift
//  DESCRIPTION: Advent of Code 2023 Day 4: Scratchcards
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/03/23 21:00:01
//

import Foundation
import Library

struct Card {
    let winners: Set<Int>
    let mine: Set<Int>
    var copies = 1
    
    init( line: String ) {
        let sections = line.split( whereSeparator: { ":|".contains( $0 ) } )
        
        winners = Set( sections[1].split( separator: " " ).map { Int( $0 )! } )
        mine = Set( sections[2].split( separator: " " ).map { Int( $0 )! } )
    }
    
    var matches: Int { winners.intersection( mine ).count }
    var points: Int { Int( pow( 2, Double( matches - 1 ) ) ) }
}


func parse( input: AOCinput ) -> [Card] {
    return input.lines.map { Card( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    return "\( parse( input: input ).reduce( 0, { $0 + $1.points } ) )"
}


func part2( input: AOCinput ) -> String {
    let original = parse( input: input )
    let revised  = original.indices.reduce( into: original ) { revised, index in
        for index2 in ( index + 1 ) ..< ( index + revised[index].matches + 1 ) {
            revised[index2].copies += revised[index].copies
        }
    }

    return "\( revised.reduce( 0, { $0 + $1.copies } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
