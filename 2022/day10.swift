//
//         FILE: main.swift
//  DESCRIPTION: day10 - Cathode-Ray Tube
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/22 21:00:17
//

import Foundation
import Library

enum Opcode: String {
    case addx, noop
    var cycles: Int {
        switch self {
        case .addx: return 2
        case .noop: return 1
        }
    }
}

struct Instruction {
    let opcode: Opcode
    let value:  Int
    
    init( line: String ) {
        let words = line.split( separator: " " ).map { String( $0 ) }
        opcode = Opcode( rawValue: words[0] )!
        value = words.count == 2 ? Int( words[1] )! : 0
    }
}

struct CPU {
    var ip = 0
    var cycle = 0
    var register = 1
    let memory: [Instruction]
    
    init( lines: [String] ) {
        memory = lines.map { Instruction( line: $0 ) }
    }
    
    mutating func advance( to cycle: Int ) -> Int {
        while self.cycle + memory[ip].opcode.cycles < cycle {
            register += memory[ip].value
            self.cycle += memory[ip].opcode.cycles
            ip += 1
        }
        return register
    }
}


func part1( input: AOCinput ) -> String {
    var cpu = CPU( lines: input.lines )
    let sum = stride( from: 20, through: 220, by: 40 ).reduce( 0 ) { sum, cycle in
        return sum + cycle * cpu.advance( to: cycle )
    }

    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let rows = 6
    let cols = 40
    var cpu = CPU( lines: input.lines )
    var pixels = Array( repeating: Array( repeating: false, count: cols ), count: rows )
    let bld = try! BlockLetterDictionary( from: "L5x6+0.txt" )

    for cycle in 1 ... 240 {
        let register = cpu.advance( to: cycle )
        let position = ( cycle - 1 ) % cols
        
        if ( register - 1 ... register + 1 ).contains( position ) {
            pixels[ cycle / cols ][ cycle % cols ] = true
        }
    }
    
    return "\( bld.makeString( screen: pixels ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
