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
import Library


func part1( input: AOCinput ) -> String {
    let knot = KnotHash( lengths: input.line.split( separator: "," ).map { Int( $0 )! } )

    knot.oneRound()
    return "\(knot.list[0] * knot.list[1])"
}


func part2( input: AOCinput ) -> String {
    let knothash = KnotHash( input: input.line )
    
    return "\(knothash.generate())"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
