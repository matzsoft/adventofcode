//
//         FILE: main.swift
//  DESCRIPTION: day25 - Let It Snow
//        NOTES: There is a cycle in the sequence, but it takes longer to find the cycle
//               than just going all the way through.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/18/21 23:37:12
//

import Foundation

let startValue = 20151125
let multiplier = 252533
let divisor    = 33554393


func parse( input: AOCinput ) -> ( Int, Int ) {
    let words = input.line.split( whereSeparator: { " ,.".contains( $0 ) } )
    let indices = words.indices.filter { Int( words[$0] ) != nil }
    let dict = Dictionary( uniqueKeysWithValues: indices.map { ( words[$0-1], Int( words[$0] )! ) } )
    
    return ( dict["row"]! - 1, dict["column"]! - 1 )
}


func part1( input: AOCinput ) -> String {
    let ( targetRow, targetCol ) = parse( input: input )
    let diagonal = targetRow + targetCol
    let repeatCount = diagonal * ( diagonal + 1 ) / 2 + targetCol
    var current = startValue
    
    for _ in 0 ..< repeatCount {
        current = ( current * multiplier ) % divisor
    }
    return "\(current)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
