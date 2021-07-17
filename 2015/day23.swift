//
//         FILE: main.swift
//  DESCRIPTION: day23 - Opening the Turing Lock
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/17/21 15:03:20
//

import Foundation

class Computer {
    struct Instruction {
        enum Opcode: String { case hlf, tpl, inc, jmp, jie, jio }
        
        let opcode: Opcode
        let register: String
        let offset: Int
        
        init( line: String ) throws {
            let words = line.split( whereSeparator: { " ,+".contains( $0 ) } )
            
            guard let opcode = Opcode( rawValue: String( words[0] ) ) else {
                throw RuntimeError( "Invalid opcode \(words[0])." )
            }
            
            self.opcode = opcode
            switch opcode {
            case .hlf:
                register = String( words[1] )
                offset = 0
            case .tpl:
                register = String( words[1] )
                offset = 0
            case .inc:
                register = String( words[1] )
                offset = 0
            case .jmp:
                register = ""
                offset = Int( words[1] )!
            case .jie:
                register = String( words[1] )
                offset = Int( words[2] )!
            case .jio:
                register = String( words[1] )
                offset = Int( words[2] )!
            }
        }
    }
    
    let memory: [Instruction]
    var pc = 0
    var registers = [ "a": 0, "b": 0 ]
    
    init( lines: [String] ) throws {
        memory = try lines.map { try Instruction( line: $0 ) }
    }
    
    func run() -> Void {
        while 0 <= pc && pc < memory.count {
            let instruction = memory[pc]
            
            switch instruction.opcode {
            case .hlf:
                registers[ instruction.register, default: 0 ] /= 2
            case .tpl:
                registers[ instruction.register, default: 0 ] *= 3
            case .inc:
                registers[ instruction.register, default: 0 ] += 1
            case .jmp:
                pc += instruction.offset - 1
            case .jie:
                if registers[ instruction.register, default: 0 ] % 2 == 0 { pc += instruction.offset - 1 }
            case .jio:
                if registers[ instruction.register, default: 0 ] == 1 { pc += instruction.offset - 1 }
            }
            
            pc += 1
        }
    }
}


func parse( input: AOCinput ) -> Computer {
    return try! Computer( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.run()
    return "\( computer.registers["b"]! )"
}


func part2( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.registers["a"] = 1
    computer.run()
    return "\( computer.registers["b"]! )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
