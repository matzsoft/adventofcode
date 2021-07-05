//
//         FILE: main.swift
//  DESCRIPTION: day02 - I Was Told There Would Be No Math
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/03/21 18:07:11
//

import Foundation


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { $0.split( separator: "x" ).map { Int( $0 )! } }
}


func part1( input: AOCinput ) -> String {
    let dimensions = parse( input: input )
    let sides = dimensions.map { [ $0[0] * $0[1], $0[0] * $0[2], $0[1] * $0[2] ] }
    let paper = sides.map { 2 * $0.reduce( 0, + ) + $0.min()! }
    
    return "\( paper.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let dimensions = parse( input: input )
    let ribbons = dimensions.map { 2 * ( $0.reduce( 0, + ) - $0.max()! ) }
    let bows = dimensions.map { $0.reduce( 1, * ) }
    
    return "\( zip( ribbons, bows ).map { $0.0 + $0.1 }.reduce( 0, + ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
