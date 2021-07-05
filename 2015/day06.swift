//
//         FILE: main.swift
//  DESCRIPTION: day06 - Probably a Fire Hazard
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 11:47:42
//

import Foundation

struct Instruction {
    enum Action { case turnOn, turnOff, toggle }
    
    let action: Action
    let upperLeft: Point2D
    let lowerRight: Point2D
    
    init( input: String ) throws {
        let words = input.split( whereSeparator: { " ,".contains( $0 ) } )
        
        switch words[0] {
        case "toggle":
            action = .toggle
            upperLeft = Point2D(x: Int( words[1] )!, y: Int( words[2] )! )
            lowerRight = Point2D(x: Int( words[4] )!, y: Int( words[5] )! )
        case "turn":
            upperLeft = Point2D(x: Int( words[2] )!, y: Int( words[3] )! )
            lowerRight = Point2D(x: Int( words[5] )!, y: Int( words[6] )! )
            switch words[1] {
            case "on":
                action = .turnOn
            case "off":
                action = .turnOff
            default:
                throw RuntimeError( "Invalid modifier '\(words[1])' for turn." )
            }
        default:
            throw RuntimeError( "Invalid action '\(words[0])'." )
        }
    }
}


struct Image {
    var image = Array( repeating: Array( repeating: 0, count: 1000 ), count: 1000 )
    var count: Int { image.flatMap { $0 }.reduce( 0, + ) }
    
    mutating func basic( action: Instruction ) -> Void {
        for y in action.upperLeft.y ... action.lowerRight.y {
            for x in action.upperLeft.x ... action.lowerRight.x {
                switch action.action {
                case .turnOn:
                    image[y][x] = 1
                case .turnOff:
                    image[y][x] = 0
                case .toggle:
                    image[y][x] = image[y][x] == 0 ? 1 : 0
               }
            }
        }
    }
    
    mutating func advanced( action: Instruction ) -> Void {
        for y in action.upperLeft.y ... action.lowerRight.y {
            for x in action.upperLeft.x ... action.lowerRight.x {
                switch action.action {
                case .turnOn:
                    image[y][x] += 1
                case .turnOff:
                    image[y][x] -= image[y][x] == 0 ? 0 : 1
                case .toggle:
                    image[y][x] += 2
               }
            }
        }
    }
}


func parse( input: AOCinput ) -> [Instruction] {
    return input.lines.map { try! Instruction( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var image = Image()
    
    for instruction in instructions {
        image.basic( action: instruction )
    }
    
    return "\( image.count )"
}


func part2( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var image = Image()
    
    for instruction in instructions {
        image.advanced( action: instruction )
    }
    
    //print( image.image.flatMap { $0 }.max()! )        // 54
    return "\( image.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
