//
//  main.swift
//  day11
//
//  Created by Mark Johnson on 12/11/19.
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
    var pc: Int
    var relativeBase: Int
    var memory: [Int]
    var inputs: [Int]
    var debug = false
    
    init( name: String, memory: [Int], inputs: [Int] ) {
        self.name = name
        pc = 0
        relativeBase = 0
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
                return nil
            }
        }
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    static func +( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( x )
        hasher.combine( y )
    }
    
    func min( other: Point ) -> Point {
        return Point( x: Swift.min( x, other.x ), y: Swift.min( y, other.y ) )
    }
    
    func max( other: Point ) -> Point {
        return Point( x: Swift.max( x, other.x ), y: Swift.max( y, other.y ) )
    }
}

enum Turn: Int { case left = 0, right = 1 }
enum Color: Int {
    case black = 0, white = 1
    
    func asString() -> String {
        switch self {
        case .black:
            return "█"
        case .white:
            return " "
        }
    }
}

struct Robot {
    let computer: IntcodeComputer
    var position: Point
    var direction: Point
    var map: [ Point : Color ]
    
    init( initialMemory: [Int] ) {
        computer = IntcodeComputer( name: "MrRoboto", memory: initialMemory, inputs: [] )
        position = Point( x: 0, y: 0 )
        direction = Point( x: 0, y: -1 )
        map = [:]
    }
    
    mutating func paint() -> Void {
        while true {
            if let color = map[position] {
                computer.inputs = [ color.rawValue ]
            } else {
                computer.inputs = [ Color.black.rawValue ]
            }
            
            guard let color = computer.grind() else { break }
            guard let turn = computer.grind() else { break }
            
            if let color = Color( rawValue: color ) {
                map[position] = color
            }
            
            if let turn = Turn( rawValue: turn ) {
                switch turn {
                case .left:
                    if direction.x == 0 {
                        direction = Point( x: direction.y, y: direction.x )
                    } else {
                        direction = Point( x: direction.y, y: -direction.x )
                    }
                case .right:
                    if direction.x == 0 {
                        direction = Point( x: -direction.y, y: direction.x )
                    } else {
                        direction = Point( x: direction.y, y: direction.x )
                    }
                }
            }
            position = position + direction
        }
    }
    
    func paintedCount() -> Int {
        return map.keys.count
    }
    
    mutating func paintIt( color: Color ) -> Void {
        map[position] = color
    }
    
    func results() -> String {
        var pMin = Point( x: Int.max, y: Int.max )
        var pMax = Point( x: Int.min, y: Int.min )
        
        for location in map.keys {
            pMin = pMin.min( other: location )
            pMax = pMax.max( other: location )
        }
        
        let width = pMax.x - pMin.x + 3
        let height = pMax.y - pMin.y + 3
        var grid = Array( repeating: Array( repeating: Color.black, count: width ), count: height )
        
        for ( location, color ) in map {
            grid[ location.y - pMin.y + 1 ][ location.x - pMin.x + 1  ] = color
        }
        
        return grid.map { $0.map { $0.asString() }.joined() }.joined( separator: "\n" )
    }
}

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var robot1 = Robot( initialMemory: initialMemory )
var robot2 = Robot( initialMemory: initialMemory )

robot1.paint()
print( "Part 1: \(robot1.paintedCount())" )

robot2.paintIt( color: .white )
robot2.paint()
print(" Part 2:" )
print( robot2.results() )
