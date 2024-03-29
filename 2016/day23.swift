//
//         FILE: main.swift
//  DESCRIPTION: day23 - Safe Cracking
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/10/21 15:21:56
//

import Foundation
import Library


func parse( input: AOCinput ) -> Assembunny {
    return Assembunny( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let program = parse( input: input )
    
    program.registers["a"] = 7
    program.run()
    return "\(program.registers["a"]!)"
}


func optimized( aValue: Int, program: Assembunny ) -> Int {
    let factorial = ( 2 ..< aValue ).reduce( aValue, * )
    
    return factorial + Int( program.memory[19].x )! * Int( program.memory[20].x )!
}


func part2( input: AOCinput ) -> String {
    let program = parse( input: input )

    return "\(optimized( aValue: 12, program: program ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
