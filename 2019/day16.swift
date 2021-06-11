//
//         FILE: main.swift
//  DESCRIPTION: day16 - Flawed Frequency Transmission
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/05/21 12:57:29
//

import Foundation

let basePattern = [ 0, 1, 0, -1 ]

func signature( signal: [Int] ) -> String {
   return signal[ ..<8 ].map { String( $0 ) }.joined()
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.map { Int( String( $0 ) )! }
}


func part1( input: AOCinput ) -> String {
    var signal = parse( input: input )
    
    for _ in 0 ..< 100 {
        signal = signal.indices.map { index in
            return abs( signal.enumerated().map { digit in
                let pattern = basePattern[ ( ( digit.offset + 1 ) / ( index + 1 ) ) % basePattern.count ]
                return digit.element * pattern
            }.reduce( 0, + ) ) % 10
        }
    }
    
    return signature( signal: signal )
}


func part2( input: AOCinput ) -> String {
    var signal = parse( input: input )
    let msgOffset = signal[ ..<7 ].reduce( 0 ) { 10 * $0 + $1 }
    let modOffset = msgOffset % signal.count
    let fullLength = 10000 * signal.count
    let repeats = ( fullLength - msgOffset ) / signal.count

    signal = ( signal[modOffset...] + ( 0 ..< repeats ).flatMap { _ in signal } ).reversed()
    for _ in 0 ..< 100 {
        var sum = 0
        signal = signal.map { sum += $0; return sum % 10 }
    }
    
    return signature( signal: signal.reversed() )
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
