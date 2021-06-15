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


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
