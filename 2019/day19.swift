//
//  main.swift
//  day19
//
//  Created by Mark Johnson on 12/18/19.
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

    func grind() -> Int? {
        halted = false
        while true {
            let instruction = Instruction( instruction: memory[pc] )
            
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
                return nil
            }
        }
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }


func isBeamHit( x: Int, y: Int ) -> Bool {
    let computer = IntcodeComputer( name: "Rosey", memory: initialMemory, inputs: [ x, y ] )

    guard let output = computer.grind() else {
        print( "Unexpected halt" )
        exit(1)
    }
    
    return output == 1
}


var sum = 0

for y in 0 ..< 50 {
    for x in 0 ..< 50 {
        if isBeamHit( x: x, y: y ) {
            sum += 1
        }
    }
}

print( "Part 1: \(sum)" )


// MARK: - Part 2 starts here

let blockSize = 100
let xMultiplier = 10000

func findXmin( y: Int ) -> Int {
    for x in 0 ..< Int.max {
        if isBeamHit( x: x, y: y ) {
            return x
        }
    }
    return Int.max
}

func findXmax( xmin: Int, y: Int ) -> Int {
    for x in xmin ..< Int.max {
        if !isBeamHit( x: x, y: y ) {
            return x - 1
        }
    }
    return Int.max
}


let minFactor = findXmin( y: 1000 )
let maxFactor = findXmax( xmin: minFactor, y: 1000 )
let rangeFacctor = maxFactor - minFactor + 1

func xMin( y: Int ) -> Int {
    var guess = minFactor * y / 1000
    
    if isBeamHit( x: guess, y: y ) {
        while guess > 0 && isBeamHit( x: guess - 1, y: y ) {
            guess -= 1
        }
    } else {
        guess += 1
        while !isBeamHit( x: guess, y: y ) {
            guess += 1
        }
    }
    
    return guess
}

func xMax( y: Int ) -> Int {
    var guess = maxFactor * y / 1000
    
    if isBeamHit( x: guess, y: y ) {
        while isBeamHit( x: guess + 1, y: y ) {
            guess += 1
        }
    } else {
        guess -= 1
        while guess > 0 && !isBeamHit( x: guess, y: y ) {
            guess -= 1
        }
    }
    
    return guess
}

func getSmallest( for range: Int ) -> Int {
    var guess = blockSize * 1000 / rangeFacctor
    
    if xMax( y: guess ) - xMin( y: guess ) + 1 >= range {
        while xMax( y: guess - 1 ) - xMin( y: guess - 1 ) + 1 >= range {
            guess -= 1
        }
    } else {
        while xMax( y: guess + 1 ) - xMin( y: guess + 1 ) + 1 < range {
            guess += 1
        }
    }
    
    return guess
}

func qualifies( y: Int ) -> Bool {
    let xmin1 = xMin( y: y )
    let xmax1 = xMax( y: y )
    let xmin2 = xMin( y: y + blockSize - 1 )
    let xmax2 = xMax( y: y + blockSize - 1)
    let xstart = xmax1 - blockSize + 1
    
    guard xmin1 <= xstart else { return false }
    guard xmin2 <= xstart && xstart <= xmax2 else { return false }
    guard xmin2 <= xmax1 && xmax1 <= xmax2 else { return false }
    
    return true
}

func details( y: Int ) -> Void {
    let xmin = xMin(y: y )
    let xmax = xMax(y: y )
    let range = xmax - xmin + 1
    
    print( "y = \(y), xrange = \(range) ( \(xmin) - \(xmax) )" )
}


var lowerBound = getSmallest( for: blockSize )
var upperBound = xMultiplier - 1

while lowerBound + 1 < upperBound {
    let middle = ( lowerBound + upperBound ) / 2
    
    if qualifies( y: middle ) {
        upperBound = middle
    } else {
        lowerBound = middle
    }
}

print("Part 2: \( xMin( y: upperBound + blockSize - 1 ) * xMultiplier + upperBound  )" )

for y in 0 ... 5 {
    details(y: y)
}
