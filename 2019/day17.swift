//
//  main.swift
//  day17
//
//  Created by Mark Johnson on 12/17/19.
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
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
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

enum Turn: Character {
    case left = "L", right = "R"
}

enum Direction: Character {
    case up = "^", down = "v", left = "<", right = ">"
    
    var vector: Point {
        switch self {
        case .up:
            return Point( x: 0, y: -1 )
        case .down:
            return Point( x: 0, y: 1 )
        case .left:
            return Point( x: -1, y: 0 )
        case .right:
            return Point( x: 1, y: 0 )
        }
    }
    
    var reverse: Direction {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        }
    }
    
    func turn( turn: Turn ) -> Direction {
        switch turn {
        case .left:
            switch self {
            case .up:
                return .left
            case .down:
                return .right
            case .left:
                return .down
            case .right:
                return .up
            }
        case .right:
            switch self {
            case .up:
                return .right
            case .down:
                return .left
            case .left:
                return .up
            case .right:
                return .down
            }
        }
    }
}

struct Mapping {
    let computer: IntcodeComputer
    let grid: [[Character]]
    let rigging: Set<Point>
    let width: Int
    let height: Int
    
    init( initialMemory: [Int] ) {
        var tempGrid: [[Character]] = []
        var mapChars: [Character] = []
        var tempRigging = Set<Point>()

        computer = IntcodeComputer( name: "Duey", memory: initialMemory, inputs: [] )
        while let output = computer.grind() {
            let char = Character( UnicodeScalar( output)! )
            
            if char != "\n" {
                mapChars.append( char )
            } else {
                if !mapChars.isEmpty {
                    tempGrid.append( mapChars )
                    mapChars = []
                }
            }
        }
        
        grid = tempGrid
        width = grid[0].count
        height = grid.count
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                if grid[y][x] == "#" {
                    tempRigging.insert( Point( x: x, y: y ) )
                }
            }
        }
        rigging = tempRigging
    }
    
    var asString: String {
        return grid.map { String( $0 ) }.joined( separator: "\n" )
    }
    
    func alignmentParameter( x: Int, y: Int ) -> Int {
        guard grid[y][x] == "#" else { return 0 }
        guard 0 < y && y < height - 1 else { return 0 }
        guard 0 < x && x < width - 1 else { return 0 }
        guard grid[y-1][x] == "#" else { return 0 }
        guard grid[y+1][x] == "#" else { return 0 }
        guard grid[y][x-1] == "#" else { return 0 }
        guard grid[y][x+1] == "#" else { return 0 }

        return x * y
    }
    
    var calibration: Int {
        var sum = 0
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                sum += alignmentParameter( x: x, y: y )
            }
        }
        
        return sum
    }
    
    var robotPos: Point {
        for y in 0 ..< height {
            for x in 0 ..< width {
                if Direction( rawValue: grid[y][x] ) != nil {
                    return Point( x: x, y: y )
                }
            }
        }
        
        print( "Robot is missing" )
        exit(1)
    }
    
    var robotDirection: Direction {
        let position = robotPos

        guard let direction = Direction( rawValue: grid[position.y][position.x] ) else {
            print( "Robot is confused" )
            exit(1)
        }
        return direction
    }
    
    func getPath() -> [String] {
        var startPos = robotPos
        var endPos = startPos
        var direction = robotDirection
        var path: [String] = []
        
        if rigging.contains( startPos + direction.reverse.vector ) {
            direction = direction.reverse
            path.append( contentsOf: [ "L", "L" ] )
        }
        
        func checkDirection() -> Bool {
            if rigging.contains( endPos + direction.vector ) { return true }
            for turn in [ Turn.left, Turn.right ] {
                if rigging.contains( endPos + direction.turn( turn: turn ).vector ) {
                    path.append( String( turn.rawValue ) )
                    direction = direction.turn( turn: turn )
                    return true
                }
            }
            
            return false
        }
        
        while checkDirection() {
            while rigging.contains( endPos + direction.vector ) {
                endPos = endPos + direction.vector
            }
            path.append( String( startPos.distance( other: endPos ) ) )
            startPos = endPos
        }
        
        return path
    }
}

struct Cleaning {
    let computer: IntcodeComputer
    
    init( initialMemory: [Int] ) {
        computer = IntcodeComputer( name: "Luey", memory: initialMemory, inputs: [] )
        computer.memory[0] = 2
    }
    
    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    func vacuum( path: String ) -> Int {
        let main = "A,A,B,C,B,C,B,C,C,A"
        let aDef = "L,10,R,8,R,8"
        let bDef = "L,10,L,12,R,8,R,10"
        let cDef = "R,10,L,12,R,10"
        let feed = "n"
        var garbage = ""
        var final = 0
        
        command( value: main )
        command( value: aDef )
        command( value: bDef )
        command( value: cDef )
        command( value: feed )
        
        while let output = computer.grind() {
            let char = Character( UnicodeScalar( output )! )
            
            if char.isASCII { garbage.append( char ) }
            final = output
        }
        
        print(garbage)
        return final
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
let scaffolds = Mapping( initialMemory: initialMemory )

print( scaffolds.asString )
print( "Part 1: \( scaffolds.calibration )" )
print( scaffolds.getPath().joined( separator: "," ) )

let cleaner = Cleaning( initialMemory: initialMemory )

print( "Part 2: \( cleaner.vacuum( path: scaffolds.getPath().joined( separator: "," ) ) )" )
