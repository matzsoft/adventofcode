//
//         FILE: main.swift
//  DESCRIPTION: day17 - Spinlock
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/22/21 19:24:01
//

import Foundation


func part1( input: AOCinput ) -> String {
    let step = Int( input.line )!
    var buffer = [ 0 ]
    var current = 0

    for value in 1 ... 2017 {
        current = ( current + step ) % buffer.count + 1
        buffer.insert( value, at: current )
    }

    let desired = ( current + 1 ) % buffer.count

    return "\(buffer[desired])"
}


func part2( input: AOCinput ) -> String {
    let step = Int( input.line )!
    var current = 0
    var value = 1
    var last = 0
    
    while value <= 50000000 {
        current = ( current + step ) % value + 1
        
        if current == 1 {
            last = value
        }
        value += 1
    }

    return "\(last)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
