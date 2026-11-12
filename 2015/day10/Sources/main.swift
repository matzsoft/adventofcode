//
//         FILE: main.swift
//  DESCRIPTION: day10 - Elves Look, Elves Say
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 22:45:24
//

import Foundation
import Library
import MATZMiscSwiftLibrary

func rounds( initial: String, rounds: Int ) -> String {
    var current = initial
    
    for _ in 1 ... rounds {
        var last: Character = "1"
        var count = 0

        current = current.map { character -> String in
            if character == last {
                count += 1
                return ""
            }
            
            let retval = count == 0 ? "" : "\(count)\(last)"
            last = character
            count = 1
            return retval
        }.joined()
        if count > 0 {
            current += "\(count)\(last)"
        }
    }
    
    return current
}


func parse( input: AOCinput ) -> ( Int, Int ) {
    let words = input.extras[0].split( separator: "," ).map { Int( $0 )! }
    return ( words[0], words[1] )
}


func part1( input: AOCinput ) -> String {
    let ( roundsCount, _ ) = parse( input: input )
    let result = rounds( initial: input.line, rounds: roundsCount )
    return "\( result.count )"
}


func part2( input: AOCinput ) -> String {
    let ( _, roundsCount ) = parse( input: input )
    let result = rounds( initial: input.line, rounds: roundsCount )
    return "\( result.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
