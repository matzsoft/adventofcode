//
//  Intcode.swift
//  day05
//
//  Created by Mark Johnson on 5/31/21.
//

import Foundation

class Intcode {
    struct Instruction {
        enum Mode: Int { case  position = 0, immediate = 1, relative = 2 }
        enum Opcode: Int {
            case add = 1, multiply = 2, input = 3, output = 4
            case jumpIfTrue = 5, jumpIfFalse = 6, lessThan = 7, equals = 8
            case relativeBaseOffset = 9, halt = 99
        }
        
        let opcode: Opcode
        let modes: [Mode]

        init( instruction: Int ) {
            opcode = Opcode( rawValue: instruction % 100 )!
            modes = [
                Mode( rawValue: instruction /   100 % 10 )!,
                Mode( rawValue: instruction /  1000 % 10 )!,
                Mode( rawValue: instruction / 10000 % 10 )!,
            ]
        }
        
        func mode( operand: Int ) -> Mode {
            return modes[ operand - 1 ]
        }
    }

    let name: String
    var ip: Int
    var relativeBase: Int
    var memory: [Int]
    var inputs: [Int]
    var debug = false
    
    var nextInstruction: Instruction {
        return Instruction( instruction: memory[ip] )
    }

    init( name: String, memory: [Int] ) {
        self.name = name
        ip = 0
        relativeBase = 0
        self.memory = memory
        self.inputs = []
    }

    func fetch( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            return location
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw RuntimeError( "Negative memory fetch (\(location)) at address \(ip)" )
        } else if location >= memory.count {
            return 0
        }
        return memory[location]
    }
    
    func store( _ instruction: Instruction, operand: Int, value: Int ) throws -> Void {
        var location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw RuntimeError( "Immediate mode invalid for address \(ip)" )
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw RuntimeError( "Negative memory store (\(location)) at address \(ip)" )
        } else if location >= memory.count {
            memory.append( contentsOf: Array( repeating: 0, count: location - memory.count + 1 ) )
        }
        memory[location] = value
    }

    func step() throws -> Int? {
        let instruction = Instruction( instruction: memory[ip] )
        
        switch instruction.opcode {
        case .add:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 + operand2 )
            ip += 4
        case .multiply:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 * operand2 )
            ip += 4
        case .input:
            if debug { print( "\(name): inputs \(inputs.first!)" ) }
            try store( instruction, operand: 1, value: inputs.removeFirst() )
            ip += 2
        case .output:
            let operand1 = try fetch( instruction, operand: 1 )
            
            ip += 2
            if debug { print( "\(name): outputs \(operand1)" ) }
            return operand1
        case .jumpIfTrue:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            ip = operand1 != 0 ? operand2 : ip + 3
        case .jumpIfFalse:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            ip = operand1 == 0 ? operand2 : ip + 3
        case .lessThan:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 < operand2 ? 1 : 0 )
            ip += 4
        case .equals:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 == operand2 ? 1 : 0 )
            ip += 4
        case .relativeBaseOffset:
            let operand1 = try fetch( instruction, operand: 1 )
            
            relativeBase += operand1
            ip += 2
        case .halt:
            if debug { print( "\(name): halts" ) }
        }

        return nil
    }
    
    func execute() throws -> Int? {
        while true {
            if let output = try step() { return output }
            if nextInstruction.opcode == .halt { return nil }
        }
    }
}
