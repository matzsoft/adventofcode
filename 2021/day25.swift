//
//         FILE: main.swift
//  DESCRIPTION: day25 - Sea Cucumber
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/24/21 22:01:21
//

import Foundation
import Library

struct Herd {
    let direction: DirectionUDLR
    let bounds: Rect2D
    var herd: Set<Point2D>
    
    mutating func move( other: Herd ) -> Int {
        let newPositions = herd.map { oldPosition -> ( Point2D, Point2D ) in
            var newPosition = oldPosition + direction.vector
            if !bounds.contains( point: newPosition ) {
                if direction == .right { newPosition = Point2D( x: 0, y: oldPosition.y ) }
                else { newPosition = Point2D( x: oldPosition.x, y: 0 ) }
            }
            return ( oldPosition, newPosition )
        }
        let possible = newPositions.filter { !herd.contains( $0.1 ) && !other.herd.contains( $0.1 ) }
        
        herd.subtract( possible.map { $0.0 } )
        herd.formUnion( possible.map { $0.1 } )
        return possible.count
    }
}


func parse( input: AOCinput ) -> ( Herd, Herd ) {
    let map = input.lines.map { Array( $0 ) }
    let bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count )!
    var eastHerd = Set<Point2D>()
    var southHerd = Set<Point2D>()
    
    for y in map.indices {
        for x in map[y].indices {
            switch map[y][x] {
            case ">":
                eastHerd.insert( Point2D( x: x, y: y ) )
            case "v":
                southHerd.insert( Point2D( x: x, y: y ) )
            default:
                break
            }
        }
    }
    return (
        Herd( direction: .right, bounds: bounds, herd: eastHerd ),
        Herd( direction: .down, bounds: bounds, herd: southHerd )
    )
}


func part1( input: AOCinput ) -> String {
    var ( eastHerd, southHerd ) = parse( input: input )
    
    for step in 1 ... Int.max {
        var moveCount = eastHerd.move( other: southHerd )
        
        moveCount += southHerd.move( other: eastHerd )

        if moveCount == 0 { return "\(step)" }
    }
    return "No solution"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
