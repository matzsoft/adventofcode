//
//         FILE: main.swift
//  DESCRIPTION: day02 - Rock Paper Scissors
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/22 21:00:17
//

import Foundation
import Library

func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map {
        let chars = Array( $0 )
        return [
            Int( chars[0].asciiValue! - Character( "A" ).asciiValue! ),
            Int( chars[2].asciiValue! - Character( "X" ).asciiValue! )
        ]
    }
}


func funkyMod( _ dividend: Int, _ divisor: Int) -> Int {
    let remainder = dividend % divisor
    return remainder == 0 ? divisor : remainder
}


func scoreIt( elf: Int, me: Int ) -> Int {
    if elf == me { return me + 4 }
    if ( elf + 1 ) % 3 == me { return me + 7 }
    return me + 1
}


func cheatIt( elf: Int, result: Int ) -> Int {
    return funkyMod( elf + result, 3 ) + result * 3
}


func part1( input: AOCinput ) -> String {
    let game = parse( input: input )
    let score = game.reduce( 0 ) { $0 + scoreIt( elf: $1[0], me: $1[1] ) }
    return "\(score)"
}


func part2( input: AOCinput ) -> String {
    let game = parse( input: input )
    let score = game.reduce( 0 ) { $0 + cheatIt( elf: $1[0], result: $1[1] ) }
    return "\(score)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
