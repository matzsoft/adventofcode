//
//         FILE: day01.swift
//  DESCRIPTION: Advent of Code 2024 Day 1: Historian Hysteria
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/30/24 21:00:14
//

import Foundation
import Library


func parse( input: AOCinput ) -> ( [Int], [Int] ) {
    let left = input.lines.map { Int( $0.split( separator: " " ).first! )! }
    let right = input.lines.map { Int( $0.split( separator: " " ).last! )! }
    
    return ( left, right )
}


func part1( input: AOCinput ) -> String {
    let ( left_raw, right_raw ) = parse( input: input )
    let left = left_raw.sorted()
    let right = right_raw.sorted()
    
    return "\( left.indices.reduce( 0 ) { $0 + abs( left[ $1 ] - right[ $1 ] ) } )"
}


func part2( input: AOCinput ) -> String {
    let ( left, right ) = parse( input: input )
    let score = left.reduce( 0 ) { sum, value in
        sum + value * right.filter( { $0 == value } ).count
    }
    return "\(score)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
