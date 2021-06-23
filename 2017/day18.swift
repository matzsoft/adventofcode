//
//         FILE: main.swift
//  DESCRIPTION: day18 - Duet
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/23/21 12:32:07
//

import Foundation

func bubbleSort( numbers: [Int] ) -> Int {
    var results = numbers
    var passes = 0
    var f = false
    
    repeat {
        passes += 1
        f = false
        for index in 0 ..< results.count - 1 {
            if results[index] < results[ index + 1 ] {
                ( results[index], results[ index + 1 ] ) = ( results[ index + 1 ], results[index] )
                f = true
            }
        }
    } while f
    
    return passes
}


func parse( input: AOCinput ) -> [Int] {
    let program = Coprocessor( lines: input.lines )
    let modulus1 = 1 << Int( program.memory[0].y )! - 1
    let multiplier1 = Int( program.memory[10].y )!
    let multiplier2 = Int( program.memory[12].y )!
    let addend = Int( program.memory[13].y )!
    let modulus2 = Int( program.memory[16].y )!
    var current = Int( program.memory[9].y )!

    return ( 1 ... Int( program.memory[8].y )! ).map { _ in
        current = ( ( current * multiplier1 ) % modulus1 * multiplier2 + addend ) % modulus1
        return current % modulus2
    }
}


func part1( input: AOCinput ) -> String {
    let numbers = parse( input: input )
    return "\(numbers.last!)"
}


func part2( input: AOCinput ) -> String {
    let numbers = parse( input: input )
    let passes = bubbleSort( numbers: numbers )

    return "\(( passes + 1 ) / 2 * numbers.count)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
