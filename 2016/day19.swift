//
//         FILE: main.swift
//  DESCRIPTION: day19 - An Elephant Named Joseph
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/08/21 19:44:02
//

import Foundation

func reduceLeft( list: [Int] ) -> Int {
    guard list.count > 2 else { return list[0] }
    guard list.count > 3 else { return list[2] }
    
    let start = 2 * ( list.count & 1 )
    
    return reduceLeft( list: stride( from: start, to: list.count, by: 2 ).map { list[$0] } )
}

func fastCenter( count: Int ) -> Int {
    guard count > 2 else { return 1 }
    guard count > 3 else { return 3 }
    
    var powerOf3 = 1
    
    while powerOf3 * 3 < count { powerOf3 *= 3 }
    
    if count <= 2 * powerOf3 { return count - powerOf3 }
    
    return powerOf3 + 2 * ( count - 2 * powerOf3 )
}


func parse( input: AOCinput ) -> Int {
    return Int( input.line )!
}


func part1( input: AOCinput ) -> String {
    let count = parse( input: input )
    return "\(reduceLeft( list: ( 1 ... count ).map { $0 } ))"
}


func part2( input: AOCinput ) -> String {
    let count = parse( input: input )
    return "\(fastCenter( count: count ))"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
