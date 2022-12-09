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

struct Motion {
    let magnitude: Int
    let direction: Point2D
}


extension Point2D {
    func isAdjacent( _ other: Point2D ) -> Bool {
        abs( x - other.x ) < 2 && abs( y - other.y ) < 2
    }
}


func parse( input: AOCinput ) -> [Motion] {
    return input.lines.map {
        let words = $0.split( separator: " " ).map { String( $0 ) }
        return Motion( magnitude: Int( words[1] )!, direction: DirectionUDLR( rawValue: words[0] )!.vector )
    }
}


func part1( input: AOCinput ) -> String {
    let motions = parse( input: input )
    var head =  Point2D( x: 0, y: 0 )
    var tail =  head
    var visited = Set<Point2D>( [ tail ] )
    
    for motion in motions {
        for _ in 0 ..< motion.magnitude {
            head = head + motion.direction
            if !tail.isAdjacent( head ) {
                let vector = head - tail
                tail = tail + Point2D( x: vector.x.signum(), y: vector.y.signum() )
                visited.insert( tail )
            }
        }
    }
    return "\(visited.count)"
}


func part2( input: AOCinput ) -> String {
    let motions = parse( input: input )
    var knots = Array( repeating: Point2D( x: 0, y: 0 ), count: 10 )
    var visited = Set<Point2D>( [ knots[0] ] )
    
    for motion in motions {
        for _ in 0 ..< motion.magnitude {
            knots[0] = knots[0] + motion.direction
            for knotNumber in 1 ..< knots.count {
                if !knots[knotNumber].isAdjacent( knots[ knotNumber - 1 ] ) {
                    let vector = knots[ knotNumber - 1 ] - knots[knotNumber]
                    knots[knotNumber] = knots[knotNumber] + Point2D( x: vector.x.signum(), y: vector.y.signum() )
                }
            }
            visited.insert( knots.last! )
        }
    }
    return "\(visited.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
