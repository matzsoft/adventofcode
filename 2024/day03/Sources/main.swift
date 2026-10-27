//
//         FILE: day03.swift
//  DESCRIPTION: Advent of Code 2024 Day 3: Mull It Over
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/24 21:20:56
//

import Foundation
import Library

func process( matches: [Regex<Substring>.Match] ) -> Int {
    var enabled = true
    let regex = #/mul\((\d+),(\d+)\)/#

    return matches.reduce( 0 ) { sum, match -> Int in
        if match.0.hasPrefix( "mul" ) && enabled {
            if let first = try! regex.firstMatch( in: match.0 ) {
                return sum + Int( first.1 )! * Int( first.2 )!
            }
        } else if match.0 == "do()" {
            enabled = true
        } else if match.0 == "don't()" {
            enabled = false
        }
        return sum
    }
}


func part1( input: AOCinput ) -> String {
    let regex = #/mul\(\d+,\d+\)/#
    let matches = input.lines.joined().matches( of: regex )
    return "\(process( matches: matches ))"
}


func part2( input: AOCinput ) -> String {
    let regex = #/mul\(\d+,\d+\)|do\(\)|don't\(\)/#
    let matches = input.lines.joined().matches( of: regex )
    return "\(process( matches: matches ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
