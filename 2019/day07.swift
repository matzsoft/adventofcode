//
//  main.swift
//  day07
//
//  Created by Mark Johnson on 12/6/19.
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
    let name: String
    var pc: Int
    var memory: [Int]
    var inputs: [Int]
    var debug = false
    
    init( name: String, memory: [Int], inputs: [Int] ) {
        self.name = name
        pc = 0
        self.memory = memory
        self.inputs = inputs
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

    func grind() -> Int? {
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
                if debug { print( "\(name): inputs \(inputs.first!)" ) }
                memory[memory[pc+1]] = inputs.removeFirst()
                pc += 2
            case 4:
                let operand1 = fetchOperand( address: pc + 1, mode: instruction.parameter1Mode )
                
                pc += 2
                if debug { print( "\(name): outputs \(operand1)" ) }
                return operand1
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
                if debug { print( "\(name): halts" ) }
                return nil
            default:
                print("Invalid opcode \(memory[pc]) at \(pc)")
                exit(1)
            }
        }
    }
}

func permutations( set: Set<Int> ) -> [[Int]] {
    var result: [[Int]] = []
    
    for element in set {
        let newSet = set.filter { $0 != element }
        
        if newSet.isEmpty { return [[element]] }
        
        permutations( set: newSet ).forEach { result.append( [element] + $0 ) }
    }
    
    return result
}



guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var part1 = 0

for permutation in permutations( set: [ 0, 1, 2, 3, 4 ] ) {
    var lastOutput = 0
    
    for phase in permutation {
        let ampflifier = IntcodeComputer( name: "A", memory: initialMemory, inputs: [ phase, lastOutput ] )
        
        if let output = ampflifier.grind() {
            lastOutput = output
        }
    }
    part1 = max( part1, lastOutput )
}

print( "Part 1: \(part1)" )

var part2 = 0

for permutation in permutations( set: [ 5, 6, 7, 8, 9 ] ) {
    var lastOutput = 0
    var done = false
    let amplifiers = [ ( "A", 0 ), ( "B", 1 ), ( "C", 2 ), ( "D", 3 ), ( "E", 4 ) ].map {
        IntcodeComputer( name: $0.0, memory: initialMemory, inputs: [ permutation[$0.1] ] )
    }

//    amplifiers.forEach { $0.debug = true }
    while !done {
        for amplifier in amplifiers {
            amplifier.inputs.append( lastOutput )
            if let output = amplifier.grind() {
                lastOutput = output
            } else {
                done = true
            }
        }
    }
    part2 = max( part2, lastOutput )
}

print( "Part 2: \(part2)" )

