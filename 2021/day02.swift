//
//         FILE: main.swift
//  DESCRIPTION: day02 - Dive!
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/21 22:10:19
//

import Foundation
import Library

struct Command {
    let action: String
    let units: Int
    
    init( line: String ) {
        let words = line.split( separator: " " )
        
        action = String( words[0] )
        units = Int( words[1] )!
    }
}

struct Status {
    let position: Point2D
    let aim: Int
}

func parse( input: AOCinput ) -> [ Command ] {
    return input.lines.map { Command(line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let commands = parse( input: input )
    let position = commands.reduce( Point2D( x: 0, y: 0 ) ) { position, command -> Point2D in
        switch command.action {
        case "forward":
            return position + Point2D( x: command.units, y: 0 )
        case "down":
            return position + Point2D( x: 0, y: command.units )
        case "up":
            return position + Point2D( x: 0, y: -command.units )
        default:
            return position
        }
    }
    return "\( position.x * position.y )"
}


func part2( input: AOCinput ) -> String {
    let commands = parse( input: input )
    let final = commands.reduce( Status( position: Point2D( x: 0, y: 0 ), aim: 0 ) ) {
        status, command -> Status in
        
        switch command.action {
        case "forward":
            return Status( position: status.position + Point2D( x: command.units, y: status.aim * command.units ), aim: status.aim )
        case "down":
            return Status( position: status.position, aim: status.aim + command.units )
        case "up":
            return Status( position: status.position, aim: status.aim - command.units )
        default:
            return status
        }
    }
    return "\( final.position.x * final.position.y )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
