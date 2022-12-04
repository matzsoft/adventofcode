//
//         FILE: main.swift
//  DESCRIPTION: day04 - Camp Cleanup
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/03/22 21:00:13
//

import Foundation


func parse( input: AOCinput ) -> [[ClosedRange<Int>]] {
    return input.lines.map { line in
        let numbers = line.split( whereSeparator: { "-,".contains( $0 ) } ).map { Int( $0 )! }
        return [ numbers[0] ... numbers[1], numbers[2] ... numbers[3] ]
    }
}


func part1( input: AOCinput ) -> String {
    let pairs = parse( input: input )
    let fullyContained = pairs.filter { pair in
        pair[0].contains( pair[1].lowerBound ) && pair[0].contains( pair[1].upperBound ) ||
        pair[1].contains( pair[0].lowerBound ) && pair[1].contains( pair[0].upperBound )
    }
    return "\(fullyContained.count)"
}


func part2( input: AOCinput ) -> String {
    let pairs = parse( input: input )
    let overlaps = pairs.filter { pair in pair[0].overlaps( pair[1] ) }
    return "\(overlaps.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
