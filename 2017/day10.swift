//
//         FILE: main.swift
//  DESCRIPTION: day10 - Knot Hash
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/18/21 20:44:19
//

import Foundation


func part1( input: AOCinput ) -> String {
    let knot = KnotHash( lengths: input.line.split( separator: "," ).map { Int( $0 )! } )

    knot.oneRound()
    return "\(knot.list[0] * knot.list[1])"
}


func part2( input: AOCinput ) -> String {
    let knothash = KnotHash( input: input.line )
    
    return "\(knothash.generate())"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
