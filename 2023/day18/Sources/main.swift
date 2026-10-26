//
//         FILE: day18.swift
//  DESCRIPTION: Advent of Code 2023 Day 18: Lavaduct Lagoon
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/23 21:00:00
//

import Foundation
import Library

struct Instruction {
    let direction: DirectionUDLR
    let distance: Int
    
    init( line: String, expanded: Bool = false ) {
        let words = line.split( whereSeparator: { " (#)".contains( $0 ) } ).map { String( $0 ) }
        
        if !expanded {
            direction = DirectionUDLR( rawValue: words[0] )!
            distance = Int( words[1] )!
        } else {
            switch words[2].last {
            case "0":
                direction = .right
            case "1":
                direction = .down
            case "2":
                direction = .left
            case "3":
                direction = .up
            default:
                fatalError( "\(words[2]) has invalid direction." )
            }
            distance = Int( words[2].prefix( 5 ), radix: 16 )!
        }
    }
}


func trenchVolume( input: AOCinput, expanded: Bool ) -> Int {
    let instructions = input.lines.map { Instruction( line: $0, expanded: expanded ) }
    let start = Point2D( x: 0, y: 0 )
    let vertexPoints = instructions.reduce( into: [ start ] ) { vertexPoints, instruction in
        if let last = vertexPoints.last {
            vertexPoints.append( last + instruction.distance * instruction.direction.vector )
        }
    }
    let borderPoints = instructions.reduce( 0 ) { $0 + $1.distance }
    let internalArea = vertexPoints[1...].indices.reduce( 0 ) {
        $0 + vertexPoints[$1-1].x * vertexPoints[$1].y - vertexPoints[$1].x * vertexPoints[$1-1].y
    }
    
    return ( abs( internalArea ) + borderPoints ) / 2 + 1
}


func part1( input: AOCinput ) -> String {
    return "\( trenchVolume( input: input, expanded: false ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( trenchVolume( input: input, expanded: true ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
