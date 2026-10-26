//
//         FILE: main.swift
//  DESCRIPTION: day25 - Clock Signal
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/10/21 17:14:12
//

import Foundation
import Library


func parse( input: AOCinput ) -> Assembunny {
    return Assembunny( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let program = parse( input: input )
    let minimum = Int( program.memory[1].x )! * Int( program.memory[2].x )!
    var current = 1
    var count = 1
    
    while current < minimum || count % 2 == 1 {
        current *= 2
        count += 1
        if count % 2 == 1 { current += 1 }
    }
    
    return "\(current - minimum)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
