//
//         FILE: main.swift
//  DESCRIPTION: day23 - Coprocessor Conflagration
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/24/21 21:09:18
//

import Foundation


func parse( input: AOCinput ) -> Coprocessor {
    return Coprocessor( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let program = parse( input: input )
    var mulCount = 0
    
    func countMuls( program: Coprocessor ) -> Bool {
        mulCount += 1
        return true
    }
    
    ( 0 ..< program.memory.count ).filter { program.memory[$0].mnemonic == .mul }.forEach {
        program.setBreakPoint( address: $0, action: countMuls )
    }

    program.run()
    return "\(mulCount)"
}


func isPrime( _ number: Int ) -> Bool {
    let root = Int( sqrt( Double( number ) ) )
    return number > 1 && !( 2 ... root ).contains { number % $0 == 0 }
}


func part2( input: AOCinput ) -> String {
    let program = parse( input: input )
    let start = Int( program.memory[0].y )! * Int( program.memory[4].y )! - Int( program.memory[5].y )!
    let stop = start - Int( program.memory[7].y )!
    let step = -Int( program.memory[30].y )!
    let h = stride( from: start, through: stop, by: step ).reduce( 0 ) { $0 + ( isPrime( $1 ) ? 0 : 1 ) }
    return "\(h)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
