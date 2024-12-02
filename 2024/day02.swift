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


func isSafe( levels: [Int] ) -> Bool {
    var direction: Bool? = nil
    for index in levels.indices.dropFirst( 1 ) {
        if levels[ index ] > levels[ index - 1 ] {
            if direction == false {
                return false
            }
            if levels[ index ] - levels[ index - 1 ] > 3 {
                return false
            }
            direction = true
        } else if levels[ index ] < levels[ index - 1 ] {
            if direction == true {
                return false
            }
            if levels[ index - 1 ] - levels[ index ] > 3 {
                return false
            }
            direction = false
        } else {
            return false
        }
    }
    return direction != nil
}


func isSafeEnough( levels: [Int] ) -> Bool {
    for index in levels.indices {
        var newLevels = levels
        newLevels.remove( at: index )
        if isSafe( levels: newLevels ) { return true }
    }
    return false
}


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { $0.split( separator: " " ).map { Int( $0 )! } }
}


func part1( input: AOCinput ) -> String {
    let reports = parse( input: input )
    let safe = reports.filter { isSafe( levels: $0 ) }
    return "\(safe.count)"
}


func part2( input: AOCinput ) -> String {
    let reports = parse( input: input )
    let safe = reports.filter { isSafe( levels: $0 ) }
    let unsafe = reports.filter { !isSafe( levels: $0 ) }
    let safeEnough = unsafe.filter { isSafeEnough( levels: $0 ) }
    return "\( safe.count + safeEnough.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
