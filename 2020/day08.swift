//
//  main.swift
//  day08
//
//  Created by Mark Johnson on 12/07/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

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
        
        init( input: Substring ) {
            let opcode = input[ input.startIndex ... input.index( input.startIndex, offsetBy: 2 ) ]
            let value = input[ input.index( input.startIndex, offsetBy: 4 ) ..< input.endIndex ]
            
            self.opcode = Opcode( rawValue: String( opcode ) )!
            self.operand = Int( value )!
        }
    }
    
    let memory: [Instruction]
    var pc: Int
    var accumulator: Int
    
    init( input: String ) {
        memory = input.split( separator: "\n" ).map { Instruction( input: $0 ) }
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


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day08.txt"
var console = try Console( input: String( contentsOfFile: inputFile ) )

print( "Part 1: \(console.runUntilLoop()!)" )

for address in 0 ..< console.memory.count {
    if var newConsole = console.fixed( address: address ) {
        if newConsole.runUntilLoop() == nil {
            print( "Part 2: \(newConsole.accumulator)" )
            break
        }
    }
}
