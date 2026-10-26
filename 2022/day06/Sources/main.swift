//
//         FILE: main.swift
//  DESCRIPTION: day06 - Tuning Trouble
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/05/22 21:06:04
//

import Foundation
import Library

func solution( input: AOCinput, length: Int ) -> String {
    let characters = Array( input.line )
    
    for index in 0 ..< characters.count - length + 1 {
        let set = Set( characters[ index ... index + length - 1 ] )
        if set.count == length { return "\( index + length )" }
    }
    
    return "No solution"
}


func part1( input: AOCinput ) -> String {
    return "\( solution( input: input, length: 4 ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( solution( input: input, length: 14 ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
