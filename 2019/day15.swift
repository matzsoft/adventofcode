//
//  main.swift
//  day15
//
//  Created by Mark Johnson on 12/14/19.
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

enum Movement: Int, CaseIterable {
    case north = 1, south = 2, west = 3, east = 4
    
    var vector: Point {
        switch self {
        case .north:
            return Point( x: 0, y: -1 )
        case .south:
            return Point( x: 0, y: 1 )
        case .west:
            return Point( x: -1, y: 0 )
        case .east:
            return Point( x: 1, y: 0 )
        }
    }
    
    var reverse: Movement {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .west:
            return .east
        case .east:
            return .west
        }
    }
}

enum Status: Int {
    case wall = 0, open = 1, oxygen = 2
    
    var asString: String {
        switch self {
        case .wall:
            return "█"
        case .open:
            return " "
        case .oxygen:
            return "⌼"
        }
    }
}

struct Cell {
    let status: Status
    let unchecked: Set<Movement>
    
    init( status: Status ) {
        self.status = status
        switch status {
        case .open, .oxygen:
            unchecked = Set<Movement>( Movement.allCases )
        case .wall:
            unchecked = Set<Movement>()
        }
    }
    
    init( status: Status, unchecked: Set<Movement> ) {
        self.status = status
        self.unchecked = unchecked
    }

    var asString: String { return status.asString }
    
    func checked( move: Movement ) -> Cell {
        return Cell( status: status, unchecked: unchecked.subtracting( [ move ] ) )
    }
}

struct Path {
    let start: Point
    let end: Point
    let path: [ Movement ]
}

struct Droid {
    var computer: IntcodeComputer
    var position = Point( x: 0, y: 0 )
    var map: [ Point : Cell ] = [ Point( x: 0, y: 0 ) : Cell( status: .open ) ]
    
    init( initialMemory: [Int] ) {
        computer = IntcodeComputer(name: "Huey", memory: initialMemory, inputs: [] )
    }
    
    var isMapComplete: Bool {
        return map.allSatisfy { $1.unchecked.isEmpty }
    }
    
    var isOxygenFull: Bool {
        return map.allSatisfy { $1.status != .open }
    }
    
    mutating func check( cell: Cell, for move: Movement ) -> Void {
        let newPos = position + move.vector
        let updatedCell = cell.checked( move: move )

        map[position] = updatedCell
        if let newCell = map[newPos] {
            let updatedCell = newCell.checked( move: move.reverse )
            
            map[newPos] = updatedCell
        } else {
            computer.inputs = [ move.rawValue ]
            let status = Status( rawValue: computer.grind()! )!
            let newCell = Cell( status: status )
            let updatedCell = newCell.checked( move: move.reverse )

            map[newPos] = updatedCell
            switch status {
            case .wall:
                break
            case .open, .oxygen:
                position = newPos
            }
//            print( asString )
//            print()
        }
    }
    
    func findPath( start: Point, until: (Cell) -> Bool ) -> Path {
        let startPath = Path( start: start, end: start, path: [] )
        var queue = [ startPath ]
        var seen = Set<Point>( [ start ] )
        
        while !queue.isEmpty {
            let thisPath = queue.removeFirst()
            
            if until( map[thisPath.end]! ) {
                return thisPath
            }
            
            for move in Movement.allCases {
                let nextPos = thisPath.end + move.vector
                
                if !seen.contains( nextPos ) {
                    if let cell = map[nextPos] {
                        switch cell.status {
                        case .wall:
                            break
                        case .open, .oxygen:
                            let newPath = thisPath.path + [ move ]
                            
                            seen.insert( nextPos )
                            queue.append( Path( start: thisPath.start, end: nextPos, path: newPath ) )
                        }
                    }
                }
            }
        }
        
        return startPath
    }

    mutating func move( along path: Path ) -> Status {
        var lastStatus = map[position]!.status
        
        for move in path.path {
            computer.inputs = [ move.rawValue ]
            lastStatus = Status( rawValue: computer.grind()! )!
            if lastStatus != .wall {
                position = position + move.vector
            }
        }
        
        return lastStatus
    }
    
    mutating func createMap() -> Void {
        while !isMapComplete {
            guard let cell = map[position] else {
                print( "Droid position compromised" )
                exit(1)
            }
            
            if let move = cell.unchecked.first {
                check( cell: cell, for: move )
            } else {
                let path = findPath( start: position, until: { !$0.unchecked.isEmpty } )
                
                if move( along: path ) == .wall {
                    print( "Path movement failed" )
                    exit(1)
                }
            }
        }
    }
    
    func isAdjacent( location: Point, status: Status ) -> Bool {
        for move in Movement.allCases {
            if let check = map[ location + move.vector ] {
                if check.status == status {
                    return true
                }
            }
        }
        return false
    }
    
    mutating func oxygenFill() -> Int {
        var time = 0
        
        while !isOxygenFull {
            let nextFills = map.filter {
                $0.value.status == .open && isAdjacent( location: $0.key, status: .oxygen )
            }
            
            time += 1
            nextFills.forEach { map[$0.key] = Cell( status: .oxygen, unchecked: $0.value.unchecked ) }
        }
        
        return time
    }
    
    var asString: String {
        var pMin = Point( x: Int.max, y: Int.max )
        var pMax = Point( x: Int.min, y: Int.min )
        
        for location in map.keys {
            pMin = pMin.min( other: location )
            pMax = pMax.max( other: location )
        }
        
        let width = pMax.x - pMin.x + 3
        let height = pMax.y - pMin.y + 3
        var grid = Array( repeating: Array( repeating: ".", count: width ), count: height )
        
        for ( location, cell ) in map {
            let y = location.y - pMin.y + 1
            let x = location.x - pMin.x + 1
            
            if location == position {
                grid[y][x] = "○"
            } else if location == Point(x: 0, y: 0 ) {
                grid[y][x] = "^"
            } else {
                grid[y][x] = cell.asString
            }
        }
        
        return grid.map { $0.joined() }.joined( separator: "\n" )
    }
}

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var droid = Droid( initialMemory: initialMemory )

droid.createMap()
print( droid.asString )

let path = droid.findPath( start: Point( x: 0, y: 0 ), until: { $0.status == .oxygen } )
print( "Part 1: \( path.path.count )" )
print( "Part 2: \( droid.oxygenFill() )" )
