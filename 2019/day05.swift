//
//  main.swift
//  day05
//
//  Created by Mark Johnson on 12/4/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

struct Instruction {
    let opcode: Int
    let parameter1Mode: Int
    let parameter2Mode: Int
    let parameter3Mode: Int

    init( instruction: Int ) {
        opcode = instruction % 100
        parameter1Mode = instruction /   100 % 10
        parameter2Mode = instruction /  1000 % 10
        parameter3Mode = instruction / 10000 % 10
    }
}

class IntcodeComputer {
    var pc: Int
    var memory: [Int]
    var inputs: [Int]
    var outputs: [Int]
    
    init( memory: [Int], inputs: [Int] ) {
        pc = 0
        self.memory = memory
        self.inputs = inputs
        outputs = []
    }

    func fetchOperand( address: Int, mode: Int ) -> Int {
        let value = memory[address]
        
        switch mode {
        case 0:
            return memory[value]
        case 1:
            return value
        default:
            print("Invalid mode \(mode) for address \(address)")
            exit(1)
        }
    }

    func grind() -> Int {
        while true {
            let instruction = Instruction( instruction: memory[pc] )
            
            switch instruction.opcode {
            case 1:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                memory[memory[pc+3]] = operand1 + operand2
                pc += 4
            case 2:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                memory[memory[pc+3]] = operand1 * operand2
                pc += 4
            case 3:
                memory[memory[pc+1]] = inputs.removeFirst()
                pc += 2
            case 4:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                
                outputs.append( operand1 )
                pc += 2
            case 5:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                if operand1 != 0 {
                    pc = operand2
                } else {
                    pc += 3
                }
            case 6:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                if operand1 == 0 {
                    pc = operand2
                } else {
                    pc += 3
                }
            case 7:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                if operand1 < operand2 {
                    memory[memory[pc+3]] = 1
                } else {
                    memory[memory[pc+3]] = 0
                }
                pc += 4
            case 8:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                let operand2 = fetchOperand( address: pc + 2, mode: instruction.parameter2Mode )
                
                if operand1 == operand2 {
                    memory[memory[pc+3]] = 1
                } else {
                    memory[memory[pc+3]] = 0
                }
                pc += 4
            case 99:
                return outputs.last!
            default:
                print("Invalid opcode \(memory[pc]) at \(pc)")
                exit(1)
            }
        }
    }
}

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day05.txt"
let input = try String( contentsOfFile: inputFile ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
let computer1 = IntcodeComputer( memory: initialMemory, inputs: [ 1 ] )
let computer2 = IntcodeComputer( memory: initialMemory, inputs: [ 5 ] )


print( "Part 1: \(computer1.grind())" )
print( "Part 2: \(computer2.grind())" )
