//
//         FILE: main.swift
//  DESCRIPTION: day01 - Chronal Calibration
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/26/21 16:31:19
//

import Foundation


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let changes = parse( input: input )
    return "\(changes.reduce( 0, + ))"
}


func part2( input: AOCinput ) -> String {
    let changes = parse( input: input )
    var frequency = 0
    var seen: Set<Int> = [ frequency ]

    while true {
        for change in changes {
            frequency += change
            if seen.contains( frequency ) {
                return "\(frequency)"
            }
            seen.insert(frequency)
        }
    }
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
