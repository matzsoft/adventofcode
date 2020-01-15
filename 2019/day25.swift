//
//  main.swift
//  day25
//
//  Created by Mark Johnson on 12/26/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

extension String: Error {}

enum Opcode: Int {
    case add                = 1
    case multiply           = 2
    case input              = 3
    case output             = 4
    case jumpIfTrue         = 5
    case jumpIfFalse        = 6
    case lessThan           = 7
    case equals             = 8
    case relativeBaseOffset = 9
    case halt               = 99
}

enum ParameterMode: Int {
    case position  = 0
    case immediate = 1
    case relative  = 2
}

struct Instruction {
    let opcode: Opcode
    let modes: [ParameterMode]

    init( instruction: Int ) {
        opcode = Opcode( rawValue: instruction % 100 )!
        modes = [
            ParameterMode( rawValue: instruction /   100 % 10 )!,
            ParameterMode( rawValue: instruction /  1000 % 10 )!,
            ParameterMode( rawValue: instruction / 10000 % 10 )!,
        ]
    }
    
    func mode( operand: Int ) -> ParameterMode {
        return modes[ operand - 1 ]
    }
}

class IntcodeComputer {
    let name: String
    var memory: [Int]
    var inputs: [Int]
    var pc = 0
    var relativeBase = 0
    var halted = true
    var debug = false
    
    var nextInstruction: Instruction {
        return Instruction( instruction: memory[pc] )
    }
    
    init( name: String, memory: [Int], inputs: [Int] ) {
        self.name = name
        self.memory = memory
        self.inputs = inputs
    }

    func fetch( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            return location
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory fetch (\(location)) at address \(pc)"
        } else if location >= memory.count {
            return 0
        }
        return memory[location]
    }
    
    func store( _ instruction: Instruction, operand: Int, value: Int ) throws -> Void {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw "Immediate mode invalid for address \(pc)"
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory store (\(location)) at address \(pc)"
        } else if location >= memory.count {
            memory.append( contentsOf: Array( repeating: 0, count: location - memory.count + 1 ) )
        }
        memory[location] = value
    }
    
    func step() -> Int? {
        let instruction = nextInstruction
        
        halted = false
        switch instruction.opcode {
        case .add:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )
            
            try! store( instruction, operand: 3, value: operand1 + operand2 )
            pc += 4
        case .multiply:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            try! store( instruction, operand: 3, value: operand1 * operand2 )
            pc += 4
        case .input:
            if debug { print( "\(name): inputs \(inputs.first!)" ) }
            try! store( instruction, operand: 1, value: inputs.removeFirst() )
            pc += 2
        case .output:
            let operand1 = try! fetch( instruction, operand: 1 )

            pc += 2
            if debug { print( "\(name): outputs \(operand1)" ) }
            return operand1
        case .jumpIfTrue:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 != 0 {
                pc = operand2
            } else {
                pc += 3
            }
        case .jumpIfFalse:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 == 0 {
                pc = operand2
            } else {
                pc += 3
            }
        case .lessThan:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 < operand2 {
                try! store( instruction, operand: 3, value: 1 )
            } else {
                try! store( instruction, operand: 3, value: 0 )
            }
            pc += 4
        case .equals:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 == operand2 {
                try! store( instruction, operand: 3, value: 1 )
            } else {
                try! store( instruction, operand: 3, value: 0 )
            }
            pc += 4
        case .relativeBaseOffset:
            let operand1 = try! fetch( instruction, operand: 1 )

            relativeBase += operand1
            pc += 2
        case .halt:
            if debug { print( "\(name): halts" ) }
            halted = true
        }

        return nil
    }

    func grind() -> Int? {
        while true {
            if let output = step() {
                return output
            }
            
            if halted {
                return nil
            }
        }
    }
}

struct Game {
    let computer: IntcodeComputer
    var inputQueue: [String] = []
    var outputQueue = ""
    
    init( memory: [Int] ) {
        computer = IntcodeComputer( name: "AOC-Advent", memory: memory, inputs: [] )
    }

    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    mutating func trial() -> Void {
        var outputQueue = ""
        
        while true {
            if computer.nextInstruction.opcode == .input {
                if computer.inputs.isEmpty {
                    if inputQueue.isEmpty {
                        let line = readLine( strippingNewline: true ) ?? ""
                        
                        command( value: line )
                    } else {
                        let line = inputQueue.removeFirst()
                        
                        command( value: line )
                        print( line )
                    }
                }
            }

            if let output = computer.step() {
                if let code = UnicodeScalar( output ) {
                    let char = Character( code )
                    
                    if char.isASCII {
                        if char != "\n" {
                            outputQueue.append( char )
                        } else {
                            print( outputQueue )
                            outputQueue = ""
                        }
                    }
                }
            }
            
            if computer.halted {
                break
            }
        }
        
        print( outputQueue )
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let initialCommands = """
south
take mouse
north
west
north
north
west
take semiconductor
east
south
west
south
take hypercube
north
east
south
west
take antenna
west
south
south
south
"""
let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var game = Game( memory: initialMemory )

game.inputQueue = initialCommands.split( separator: "\n" ).map { String( $0 ) }
game.trial()

//print( "Part 1: \(trial())" )
