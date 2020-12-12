//
//  main.swift
//  day12
//
//  Created by Mark Johnson on 12/11/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

enum Direction: Position {
    case north, east, south, west
    
    var north: Int { return rawValue.north }
    var east: Int { return rawValue.east }
    
    func turn( instruction: Instruction ) -> Direction {
        if instruction.action == .left {
            switch instruction.value {
            case 90:
                return Direction( rawValue: Position( north: rawValue.east, east: -rawValue.north ) )!
            case 180:
                return Direction( rawValue: Position( north: -rawValue.north, east: -rawValue.east ) )!
            case 270:
                return Direction(rawValue: Position( north: -rawValue.east, east: rawValue.north ) )!
            default:
                print( "Unexpected turn \(instruction.value)" )
                exit(0)
            }
        }
        if instruction.action == .right {
            switch instruction.value {
            case 90:
                return Direction(rawValue: Position( north: -rawValue.east, east: rawValue.north ) )!
            case 180:
                return Direction( rawValue: Position( north: -rawValue.north, east: -rawValue.east ) )!
            case 270:
                return Direction( rawValue: Position( north: rawValue.east, east: -rawValue.north ) )!
            default:
                print( "Unexpected turn \(instruction.value)" )
                exit(0)
            }
        }
        return self
    }
}

struct Position: Equatable, ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    
    let north: Int
    let east: Int
    
    init( north: Int, east: Int ) {
        self.north = north
        self.east = east
    }
    
    init( stringLiteral value: String ) {
        switch value {
        case "north":
            self.init( north: 1, east: 0 )
        case "east":
            self.init( north: 0, east: 1 )
        case "south":
            self.init( north: -1, east: 0 )
        case "west":
            self.init( north: 0, east: -1 )
        default:
            self.init( north: 0, east: 0 )
        }
    }
    
    func move( towards: Direction, by: Int ) -> Position {
        return Position( north: north + by * towards.north, east: east + by * towards.east )
    }
    
    func move( towards: Position, by: Int ) -> Position {
        return Position( north: north + by * towards.north, east: east + by * towards.east )
    }

    func offset( by: Direction ) -> Position {
        return Position( north: north + by.north, east: east + by.east )
    }
    
    func rotate( instruction: Instruction ) -> Position {
        if instruction.action == .left {
            switch instruction.value {
            case 90:
                return Position( north: east, east: -north )
            case 180:
                return Position( north: -north, east: -east )
            case 270:
                return Position( north: -east, east: north )
            default:
                print( "Unexpected turn \(instruction.value)" )
                exit(0)
            }
        }
        if instruction.action == .right {
            switch instruction.value {
            case 90:
                return Position( north: -east, east: north )
            case 180:
                return Position( north: -north, east: -east )
            case 270:
                return Position( north: east, east: -north )
            default:
                print( "Unexpected turn \(instruction.value)" )
                exit(0)
            }
        }
        return self
    }
}

enum Action: String {
    case north = "N", south = "S", east = "E", west = "W", left = "L", right = "R", forward = "F"
}

struct Instruction {
    let action: Action
    let value: Int
    
    init( input: Substring) {
        action = Action( rawValue: String( input.first! ) )!
        value = Int( String( input.dropFirst() ) )!
    }
}

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day12.txt"
let instructions = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map {
    Instruction( input: $0 )
}
var ship1 = Position( north: 0, east: 0 )
var ship2 = Position( north: 0, east: 0 )
var waypoint = Position( north: 1, east: 10 )
var direction = Direction.east

for instruction in instructions {
    switch instruction.action {
    case .north:
        ship1 = ship1.move( towards: .north, by: instruction.value )
        waypoint = waypoint.move( towards: .north, by: instruction.value )
    case .south:
        ship1 = ship1.move( towards: .south, by: instruction.value )
        waypoint = waypoint.move( towards: .south, by: instruction.value )
    case .east:
        ship1 = ship1.move( towards: .east, by: instruction.value )
        waypoint = waypoint.move( towards: .east, by: instruction.value )
    case .west:
        ship1 = ship1.move( towards: .west, by: instruction.value )
        waypoint = waypoint.move( towards: .west, by: instruction.value )
    case .left, .right:
        direction = direction.turn( instruction: instruction )
        waypoint = waypoint.rotate( instruction: instruction )
    case .forward:
        ship1 = ship1.move( towards: direction, by: instruction.value )
        ship2 = ship2.move( towards: waypoint, by: instruction.value )
    }
}

print( "Part 1: \(abs( ship1.north ) + abs( ship1.east ))" )
print( "Part 2: \(abs( ship2.north ) + abs( ship2.east ))" )
