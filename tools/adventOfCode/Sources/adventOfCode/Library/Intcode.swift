//
//  Intcode.swift
//  day05
//
//  Created by Mark Johnson on 5/31/21.
//

import Foundation

class Intcode {
    struct Instruction {
        enum Mode: Int { case  position = 0, immediate = 1 }
        enum Opcode: Int {
            case add = 1, multiply = 2, input = 3, output = 4
            case jumptrue = 5, jumpfalse = 6, less = 7, equals = 8, halt = 99
        }
        
        let opcode: Opcode
        let parameter1Mode: Mode
        let parameter2Mode: Mode
        let parameter3Mode: Mode

        init( instruction: Int ) {
            opcode = Opcode( rawValue: instruction % 100 )!
            parameter1Mode = Mode( rawValue: instruction /   100 % 10 )!
            parameter2Mode = Mode( rawValue: instruction /  1000 % 10 )!
            parameter3Mode = Mode( rawValue: instruction / 10000 % 10 )!
        }
    }

    var ip: Int
    var memory: [Int]
    var inputs: [Int]
    var outputs: [Int]
    
    init( memory: [Int] ) {
        ip = 0
        self.memory = memory
        self.inputs = []
        outputs = []
    }

    func fetchOperand( address: Int, mode: Instruction.Mode ) -> Int {
        let value = memory[address]
        
        switch mode {
        case .position:
            return memory[value]
        case .immediate:
            return value
        }
    }

    func execute() -> Void {
        while true {
            let instruction = Instruction( instruction: memory[ip] )
            
            switch instruction.opcode {
            case .add:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                memory[memory[ip+3]] = operand1 + operand2
                ip += 4
            case .multiply:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                memory[memory[ip+3]] = operand1 * operand2
                ip += 4
            case .input:
                memory[memory[ip+1]] = inputs.removeFirst()
                ip += 2
            case .output:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                
                outputs.append( operand1 )
                ip += 2
            case .jumptrue:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                ip = operand1 != 0 ? operand2 : ip + 3
            case .jumpfalse:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                ip = operand1 == 0 ? operand2 : ip + 3
            case .less:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                memory[memory[ip+3]] = operand1 < operand2 ? 1 : 0
                ip += 4
            case .equals:
                let operand1 = fetchOperand( address: ip + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: ip + 2, mode: instruction.parameter2Mode )
                
                memory[memory[ip+3]] = operand1 == operand2 ? 1 : 0
                ip += 4
            case .halt:
                return
            }
        }
    }
}
