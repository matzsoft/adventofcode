//
//         FILE: day22.swift
//  DESCRIPTION: Advent of Code 2024 Day 22: Monkey Market
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/21/24 21:00:28
//

import Foundation
import Library

func nextSecret( secret: Int ) -> Int {
    let step1 = ( ( secret << 6 ) ^ secret ) % 16777216
    let step2 = ( ( step1 >> 5 ) ^ step1 ) % 16777216
    let step3 = ( ( step2 * 2048 ) ^ step2 ) % 16777216
    
    return step3
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let finals = input.lines.map { Int( $0 )! }.map { initial in
        ( 1 ... 2000 ).reduce( into: initial ) { previous, _ in
            previous = nextSecret( secret: previous )
        }
    }
    return "\( finals.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
