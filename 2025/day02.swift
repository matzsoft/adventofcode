//
//         FILE: day02.swift
//  DESCRIPTION: Advent of Code 2025 Day 2: Gift Shop
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/25 21:00:01
//

import Foundation
import Library

func parse( input: AOCinput ) -> [ClosedRange<Int>] {
    let ranges = input.line.split( separator: "," ).map { String( $0 ) }
    let bounds = ranges.map { $0.split( separator: "-" ).map { Int( $0 )! } }

    return bounds.map { $0[0] ... $0[1] }
}


func findMatches( input: AOCinput, regex: Regex<AnyRegexOutput> ) -> Int {
    parse( input: input ).reduce( 0 ) {
        $0 + $1.reduce( 0 ) {
            $0 + ( try! regex.wholeMatch( in: String( $1 ) ) != nil ? $1 : 0 )
        }
    }
}


func part1( input: AOCinput ) -> String {
    return "\(findMatches( input: input, regex: try! Regex( #"^(.+)\1$"# ) ))"
}


func part2( input: AOCinput ) -> String {
    return "\(findMatches( input: input, regex: try! Regex( #"^(.+)\1+$"# ) ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
