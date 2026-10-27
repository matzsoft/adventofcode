//
//         FILE: day05.swift
//  DESCRIPTION: Advent of Code 2025 Day 5: Cafeteria
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/25 21:04:03
//

import Foundation
import Library

func parse( input: AOCinput ) -> ( [ ClosedRange<Int> ], [ Int ] ) {
    let ranges = input.paragraphs[0].map { line in
        let bounds = line.split( separator: "-" ).map { Int( $0 )! }
        return bounds[0] ... bounds[1]
        
    }
    let available = input.paragraphs[1].map { Int( $0 )! }
    return ( ranges, available )
}


func part1( input: AOCinput ) -> String {
    let ( ranges, available ) = parse( input: input )
    let fresh = available.filter { ingredient in
        ranges.contains { $0.contains( ingredient ) }
    }

    return "\(fresh.count)"
}


func part2( input: AOCinput ) -> String {
    let ( ranges, _ ) = parse( input: input )
    let condensed = ranges.condensed

    return "\(condensed.reduce( 0 ) { $0 + $1.count })"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
