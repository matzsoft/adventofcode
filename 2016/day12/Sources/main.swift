//
//         FILE: main.swift
//  DESCRIPTION: day12 - Leonardo's Monorail
//        NOTES: See comments at the end for a description of how I arrived at the solution.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/01/21 19:42:01
//

import Foundation
import Library

func fibonacci( _ n: Int ) -> Int {
    return Int( pow( ( 1 + sqrt( 5 ) ) / 2, Double( n ) ) / sqrt( 5 ) + 0.5 )
}


func parse( input: AOCinput ) -> Assembunny {
    return Assembunny( lines: input.lines )
}


func part1Slow( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.run()
    return "\(computer.registers["a"]!)"
}


func part2Slow( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.registers["c"] = 1
    computer.run()
    return "\(computer.registers["a"]!)"
}


func part1( input: AOCinput ) -> String {
    let computer = parse( input: input )
    let fibNumber = Int( computer.memory[2].x )! + 2
    let product = Int( computer.memory[16].x )! * Int( computer.memory[17].x )!
    
    return "\(fibonacci( fibNumber ) + product)"
}


func part2( input: AOCinput ) -> String {
    let computer = parse( input: input )
    let fibNumber = Int( computer.memory[2].x )! + Int( computer.memory[5].x )! + 2
    let product = Int( computer.memory[16].x )! * Int( computer.memory[17].x )!
    
    return "\(fibonacci( fibNumber ) + product)"
}


try print( projectInfo() )
try runTests( part1: part1Slow )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
//try solve( part1: part1Slow )
//try solve( part2: part2Slow )


/*
 My input produces an Assembunny computer with the following memory contents:
 
 00: cpy 1 a
 01: cpy 1 b
 02: cpy 26 d
 03: jnz c 2
 04: jnz 1 5
 05: cpy 7 c
 06: inc d
 07: dec c
 08: jnz c -2
 09: cpy a c
 10: inc a
 11: dec b
 12: jnz b -2
 13: cpy c b
 14: dec d
 15: jnz d -6
 16: cpy 18 c
 17: cpy 11 d
 18: inc a
 19: dec d
 20: jnz d -2
 21: dec c
 22: jnz c -5

 It was pretty easy to reverse engineer that into the following function.
 
func execute( a:Int, b: Int, c: Int, d: Int ) -> Int {
    var a = a
    var b = b
    var c = c
    var d = d
    
    a = 1
    b = 1
    d = 26
    if c != 0 { d += 7 }
    for _ in 1 ... d {
        c = a
        a += b
        b = c
    }
    a += 198
    
    return a
}

print( "Part1:", execute(a: 0, b: 0, c: 0, d: 0) )
print( "Part2:", execute(a: 0, b: 0, c: 1, d: 0) )
 
 Upon further examination, the for loop really just computes fibonacci( d + 2 ), leading to the code in part1 and part2 above.
 
*/
