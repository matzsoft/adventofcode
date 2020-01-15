//
//  main.swift
//  day13
//
//  Created by Mark Johnson on 12/12/19.
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

struct Point: Hashable {
    let x: Int
    let y: Int
    
    static func +( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
    }
    
    static func -( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x - rhs.x, y: lhs.y - rhs.y )
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

enum TileID: Int {
    case empty = 0, wall = 1, block = 2, paddle = 3, ball = 4
    
    func asString() -> String {
        switch self {
        case .empty:
            return " "
        case .wall:
            return "█"
        case .block:
            return "▒"
        case .paddle:
            return "▁"
        case .ball:
            return "●"
        }
    }
}

enum Joystick: Int {
    case left = -1, neutral = 0, right = 1
}

struct ArcadeCabinet {
    let computer: IntcodeComputer
    var map: [[TileID]] = []
    var score = 0
    var paddlePos = Point( x: 0, y: 0 )
    var ballPos = Point( x: 0, y: 0 )
    
    var width: Int { return map.count == 0 ? 0 : map[0].count }
    var height: Int { return map.count }
    var asString: String { return map.map { $0.map { $0.asString() }.joined() }.joined( separator: "\n" ) }

    init( initialMemory: [Int] ) {
        var tiles: [ Point : TileID ] = [:]
        
        computer = IntcodeComputer( name: "BreakOut", memory: initialMemory, inputs: [] )
        
        computer.memory[0] = 2
        while let ( position, type ) = move() {
            tiles[ position ] = type
        }
        
        let pMax = tiles.keys.reduce( Point( x: 0, y: 0 ), { $0.max( other: $1 ) } )
        let width = pMax.x + 1
        let height = pMax.y + 1
        
        map = Array( repeating: Array( repeating: TileID.empty, count: width ), count: height )
        for ( position, type ) in tiles {
            map[position.y][position.x] = type
        }
    }
    
    mutating func move() -> ( Point, TileID )? {
        guard let x = computer.grind() else { return nil }
        guard let y = computer.grind() else { return nil }
        guard let value = computer.grind() else { return nil }
        
        if x == -1 {
            print( "Got score \(value)" )
            score = value
            return nil
        }
        
        let position = Point( x: x, y: y )

        guard let type = TileID( rawValue: value ) else { return nil }
        
        switch type {
        case .paddle:
            paddlePos = position
        case .ball:
            ballPos = position
        default:
            break
        }
        
        return ( position, type )
    }
    
    func countOf( type: TileID ) -> Int {
        return map.reduce( 0, { $0 + $1.filter( { $0 == type } ).count } )
    }
    
    mutating func play() -> Int {
        computer.inputs = [ ( ballPos.x - paddlePos.x ).signum() ]
        while !computer.halted {
            while let ( position, type ) = move() {
                map[position.y][position.x] = type
                switch type {
                case .ball:
                    print( "Ball at \(position)" )
                    print( asString )
                    
                    computer.inputs = [ ( ballPos.x - paddlePos.x ).signum() ]
                case .paddle:
                    print( "Paddle at \(position)" )
                case .empty:
                    print( "Tile erased at \(position)" )
                default:
                    print( "Unexpected \(type) at \(position)" )
                }
            }
        }
        
        return score
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var cabinet = ArcadeCabinet( initialMemory: initialMemory )

print( "Part 1: \( cabinet.countOf( type: .block ) )" )
print( cabinet.asString )

print("Part 2: \( cabinet.play() )")
