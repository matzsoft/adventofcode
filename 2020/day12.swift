//
//         FILE: main.swift
//  DESCRIPTION: day12 - Rain Risk
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/25/21 19:38:32
//

import Foundation
import Library

struct Instruction {
    enum Action: String {
        case north = "N", south = "S", east = "E", west = "W", left = "L", right = "R", forward = "F"
    }

    let action: Action
    let value: Int
    
    init( input: String) {
        action = Action( rawValue: String( input.first! ) )!
        value = Int( String( input.dropFirst() ) )!
    }
    
    func perform( position: Point2D, direction: Direction4 ) throws -> ( Point2D, Direction4 ) {
        switch action {
        case .north:
            return ( position + value * Direction4.north.vector, direction )
        case .south:
            return ( position + value * Direction4.south.vector, direction )
        case .east:
            return ( position + value * Direction4.east.vector, direction )
        case .west:
            return ( position + value * Direction4.west.vector, direction )
        case .left:
            switch value {
            case 90:
                return ( position, direction.turn( direction: .left ) )
            case 180:
                return ( position, direction.turn( direction: .back ) )
            case 270:
                return ( position, direction.turn( direction: .right ) )
            default:
                throw RuntimeError( "Invalid turn value \(value)" )
            }
        case .right:
            switch value {
            case 90:
                return ( position, direction.turn( direction: .right ) )
            case 180:
                return ( position, direction.turn( direction: .back ) )
            case 270:
                return ( position, direction.turn( direction: .left ) )
            default:
                throw RuntimeError( "Invalid turn value \(value)" )
            }
        case .forward:
            return ( position + value * direction.vector, direction )
        }
    }
    
    func perform( position: Point2D, waypoint: Point2D ) throws -> ( Point2D, Point2D ) {
        switch action {
        case .north:
            return ( position, waypoint + value * Direction4.north.vector )
        case .south:
            return ( position, waypoint + value * Direction4.south.vector )
        case .east:
            return ( position, waypoint + value * Direction4.east.vector )
        case .west:
            return ( position, waypoint + value * Direction4.west.vector )
        case .left:
            switch value {
            case 90:
                return ( position, Point2D( x: -waypoint.y, y: waypoint.x ) )
            case 180:
                return ( position, Point2D( x: -waypoint.x, y: -waypoint.y ) )
            case 270:
                return ( position, Point2D( x: waypoint.y, y: -waypoint.x ) )
            default:
                throw RuntimeError( "Invalid turn value \(value)" )
            }
        case .right:
            switch value {
            case 90:
                return ( position, Point2D( x: waypoint.y, y: -waypoint.x ) )
            case 180:
                return ( position, Point2D( x: -waypoint.x, y: -waypoint.y ) )
            case 270:
                return ( position, Point2D( x: -waypoint.y, y: waypoint.x ) )
            default:
                throw RuntimeError( "Invalid turn value \(value)" )
            }
        case .forward:
            return ( position + value * waypoint, waypoint )
        }
    }
}


func parse( input: AOCinput ) -> [Instruction] {
    return input.lines.map { Instruction( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var position = Point2D( x: 0, y: 0 )
    var direction = Direction4.east
    
    for instruction in instructions {
        ( position, direction ) = try! instruction.perform( position: position, direction: direction )
    }

    return "\( position.magnitude )"
}


func part2( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var position = Point2D( x: 0, y: 0 )
    var waypoint = Point2D( x: 10, y: 1 )

    for instruction in instructions {
        ( position, waypoint ) = try! instruction.perform( position: position, waypoint: waypoint )
    }
    
    return "\( position.magnitude )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
