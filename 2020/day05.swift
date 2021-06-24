//
//         FILE: main.swift
//  DESCRIPTION: day05 - Binary Boarding
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/24/21 12:06:30
//

import Foundation

func seatID<T>( input: T ) -> Int where T: StringProtocol {
    let binary = input
        .replacingOccurrences( of: "F", with: "0" )
        .replacingOccurrences( of: "B", with: "1" )
        .replacingOccurrences( of: "L", with: "0" )
        .replacingOccurrences( of: "R", with: "1" )
    
    return Int( binary, radix: 2 )!
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { seatID( input: $0 ) }.sorted()
}


func part1( input: AOCinput ) -> String {
    let seats = parse( input: input )
    return "\( seats.last! )"
}


func part2( input: AOCinput ) -> String {
    let seats = parse( input: input )
    let myIndex = seats.indices.first { seats[$0] + 1 != seats[$0+1] }!
    
    return "\( seats[myIndex] + 1 )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
