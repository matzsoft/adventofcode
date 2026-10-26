//
//         FILE: main.swift
//  DESCRIPTION: day09 - Rope Bridge
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/08/22 21:00:12
//

import Foundation
import Library

struct Motion {
    let magnitude: Int
    let direction: Point2D
}


extension Point2D {
    func isAdjacent( _ other: Point2D ) -> Bool {
        abs( x - other.x ) < 2 && abs( y - other.y ) < 2
    }
    
    func moveToward( _ other: Point2D ) -> Point2D {
        let vector = other - self
        return self + Point2D( x: vector.x.signum(), y: vector.y.signum() )
    }
}


func trackTail( input: AOCinput, knotCount: Int ) -> Int {
    let motions = parse( input: input )
    var knots = Array( repeating: Point2D( x: 0, y: 0 ), count: knotCount )
    var visited = Set<Point2D>( [ knots[0] ] )
    
    for motion in motions {
        for _ in 0 ..< motion.magnitude {
            knots[0] = knots[0] + motion.direction
            for knotNumber in 1 ..< knots.count {
                if !knots[knotNumber].isAdjacent( knots[ knotNumber - 1 ] ) {
                    knots[knotNumber] = knots[knotNumber].moveToward( knots[ knotNumber - 1 ] )
                }
            }
            visited.insert( knots.last! )
        }
    }
    return visited.count
}


func parse( input: AOCinput ) -> [Motion] {
    return input.lines.map {
        let words = $0.split( separator: " " ).map { String( $0 ) }
        return Motion( magnitude: Int( words[1] )!, direction: DirectionUDLR( rawValue: words[0] )!.vector )
    }
}


func part1( input: AOCinput ) -> String {
    return "\( trackTail( input: input, knotCount: 2 ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( trackTail( input: input, knotCount: 10 ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
