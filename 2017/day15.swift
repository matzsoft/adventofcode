//
//         FILE: main.swift
//  DESCRIPTION: day15 - Dueling Generators
//        NOTES: Using a class as a generator is nicer code but takes more than 2.5 times longer to run.
//               Also (and scary) using a for loop instead of while takes 25 times longer to run.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/20/21 17:33:44
//

import Foundation

let ( factorA, maskA ) = ( 16807, 3 )
let ( factorB, maskB ) = ( 48271, 7 )
let modulo = 2147483647
let lowOrder16 = 0xFFFF


func parse( input: AOCinput ) -> ( Int, Int ) {
    let wordsA = input.lines[0].split( separator: " " )
    let wordsB = input.lines[1].split( separator: " " )
    return ( Int( wordsA[4] )!, Int( wordsB[4] )! )
}


func part1( input: AOCinput ) -> String {
    var ( valueA, valueB ) = parse( input: input )
    var judge = 0
    var count = 0

    while count < 40000000 {
        count += 1
        valueA = ( valueA * factorA ) % modulo
        valueB = ( valueB * factorB ) % modulo
        if valueA & lowOrder16 == valueB & lowOrder16 {
            judge += 1
        }
    }

    return "\(judge)"
}


func part2( input: AOCinput ) -> String {
    var ( valueA, valueB ) = parse( input: input )
    var judge = 0
    var count = 0

    while count < 5000000 {
        count += 1
        repeat {
            valueA = ( valueA * factorA ) % modulo
        } while valueA & maskA != 0
        repeat {
            valueB = ( valueB * factorB ) % modulo
        } while valueB & maskB != 0
        if valueA & lowOrder16 == valueB & lowOrder16 {
            judge += 1
        }
    }

    return "\(judge)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
