//
//         FILE: main.swift
//  DESCRIPTION: day10 - Adapter Array
//        NOTES: Per the problem definition there can be no deltas with a value of zero.  However deltas
//               with a value of two are not explicitly prohibited.  This is not a problem for Part 1, but
//               my method for solving Part 2 will not work if there are any deltas with a value of 2.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/25/21 12:35:48
//

import Foundation
import Library

func getFactor( count: Int ) -> Int {
    guard count > 1 else { return 1 }
    
    let power = 1 << ( count - 1 )
    
    guard count > 3 else { return power }
    
    return power - ( count - 3 ) * ( count - 2 ) / 2
}


func parse( input: AOCinput ) -> [Int] {
    var last = 0
    let adapters = input.lines.map { Int($0)! }.sorted()

    return adapters.map { (jolts) -> Int in let r = jolts - last; last = jolts; return r }
}


func part1( input: AOCinput ) -> String {
    let deltas = parse( input: input )
    let onesCount = deltas.filter { $0 == 1 }.count
    let threesCount = deltas.filter { $0 == 3 }.count

    return "\( onesCount * ( threesCount + 1 ) )"
}


func part2( input: AOCinput ) -> String {
    let deltas = parse( input: input )
    let twosCount = deltas.filter { $0 == 2 }.count
    
    guard twosCount == 0 else { return "Unexpected delta(s) of 2 in input.  Unable to solve Part2." }

    let runs = deltas.split( separator: 3 )

    return "\( runs.reduce( 1 ) { $0 * getFactor( count: $1.count ) } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
