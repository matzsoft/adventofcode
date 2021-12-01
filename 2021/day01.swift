//
//         FILE: main.swift
//  DESCRIPTION: day01 - Sonar Sweep
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/30/21 21:00:17
//

import Foundation

extension Array {
    var pairs: [ ( Element, Element ) ] {
        return ( 0 ..< count - 1 ).map { ( self[$0], self[$0+1] ) }
    }
}

func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let depths = parse( input: input )
    return "\( depths.pairs.filter { $1 > $0 }.count )"
}


func part2( input: AOCinput ) -> String {
    let depths = parse( input: input )
    let windows = ( 0 ... depths.count - 3 ).map { depths[$0...$0+2].reduce( 0, + ) }

    return "\( windows.pairs.filter { $1 > $0 }.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
