//
//         FILE: day02.swift
//  DESCRIPTION: Advent of Code 2024 Day 2: Red-Nosed Reports
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/24 21:01:51
//

import Foundation
import Library

extension Array {
    func drop( at: Index ) -> Array {
        var copy = self
        copy.remove( at: at )
        return copy
    }
}


func isSafe( levels: [Int] ) -> Bool {
    let deltas = levels.indices.dropFirst().map { levels[$0] - levels[ $0 - 1 ] }
    if deltas[0] == 0 { return false }
    
    let direction = deltas[0].signum()
    return deltas.allSatisfy { $0.signum() == direction && -3 <= $0 && $0 <= 3 }
}


// The following version, while not as pretty, runs about 20% faster than the one above.
//func isSafe( levels: [Int] ) -> Bool {
//    var direction: Bool? = nil
//    for index in levels.indices.dropFirst( 1 ) {
//        if levels[ index ] > levels[ index - 1 ] {
//            if direction == false {
//                return false
//            }
//            if levels[ index ] - levels[ index - 1 ] > 3 {
//                return false
//            }
//            direction = true
//        } else if levels[ index ] < levels[ index - 1 ] {
//            if direction == true {
//                return false
//            }
//            if levels[ index - 1 ] - levels[ index ] > 3 {
//                return false
//            }
//            direction = false
//        } else {
//            return false
//        }
//    }
//    return direction != nil
//}


func isSafeEnough( levels: [Int] ) -> Bool {
    return levels.indices.contains { isSafe( levels: levels.drop( at: $0 ) ) }
}


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { $0.split( separator: " " ).map { Int( $0 )! } }
}


func part1( input: AOCinput ) -> String {
    return "\( parse( input: input ).filter { isSafe( levels: $0 ) }.count )"
}


func part2( input: AOCinput ) -> String {
    return "\( parse( input: input ).filter { isSafeEnough( levels: $0 ) }.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
