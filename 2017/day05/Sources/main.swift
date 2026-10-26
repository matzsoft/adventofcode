//
//         FILE: main.swift
//  DESCRIPTION: day05 - A Maze of Twisty Trampolines, All Alike
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/15/21 19:16:00
//

import Foundation
import Library

func countSteps( input: AOCinput, modifier: ( Int ) -> Int ) -> Int {
    var ip = 0
    var stepCount = 0
    var memory = parse( input: input )
    
    while 0 <= ip && ip < memory.count {
        let offset = memory[ip]
        
        stepCount += 1
        memory[ip] += modifier( offset )
        ip += offset
    }

    return stepCount
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let stepCount = countSteps( input: input ) { _ in 1 }
    return "\(stepCount)"
}


func part2( input: AOCinput ) -> String {
    let stepCount = countSteps( input: input ) { $0 >= 3 ? -1 : 1 }
    return "\(stepCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
