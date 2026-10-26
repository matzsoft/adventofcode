//
//         FILE: main.swift
//  DESCRIPTION: day08 - Handheld Halting
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/24/21 19:07:01
//

import Foundation
import Library

struct Console {
    enum Opcode: String {
        case acc, jmp, nop
    }
    
    struct Instruction {
        let opcode: Opcode
        let operand: Int
        
        init( opcode: Opcode, operand: Int ) {
            self.opcode = opcode
            self.operand = operand
        }
        
        init( input: String ) {
            let words = input.components( separatedBy: " " )
            
            self.opcode = Opcode( rawValue: words[0] )!
            self.operand = Int( words[1] )!
        }
    }
    
    let memory: [Instruction]
    var pc: Int
    var accumulator: Int
    
    init( lines: [String] ) {
        memory = lines.map { Instruction( input: $0 ) }
        pc = 0
        accumulator = 0
    }
    
    init( memory: [Instruction] ) {
        self.memory = memory
        self.pc = 0
        self.accumulator = 0
    }
    
    mutating func reset() -> Void {
        pc = 0
        accumulator = 0
    }
    
    mutating func runUntilLoop() -> Int? {
        var visited = Set<Int>()
        
        reset()
        while !visited.contains( pc ) && pc < memory.count {
            visited.insert( pc )
            switch memory[pc].opcode {
            case .acc:
                accumulator += memory[pc].operand
                pc += 1
            case .jmp:
                pc += memory[pc].operand
            case .nop:
                pc += 1
            }
        }
        
        guard pc < memory.count else {
            return nil
        }
        return accumulator
    }
    
    func fixed( address: Int ) -> Console? {
        var memory = self.memory
        
        switch memory[address].opcode {
        case .acc:
            return nil
        case .jmp:
            memory[address] = Instruction( opcode: .nop, operand: memory[address].operand )
        case .nop:
            memory[address] = Instruction( opcode: .jmp, operand: memory[address].operand )
        }
        
        return Console( memory: memory )
    }
}


func parse( input: AOCinput ) -> Console {
    return Console( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var console = parse( input: input )
    return "\( console.runUntilLoop()! )"
}


func part2( input: AOCinput ) -> String {
    let console = parse( input: input )
    
    for address in 0 ..< console.memory.count {
        if var newConsole = console.fixed( address: address ) {
            if newConsole.runUntilLoop() == nil {
                return "\( newConsole.accumulator )"
            }
        }
    }
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
