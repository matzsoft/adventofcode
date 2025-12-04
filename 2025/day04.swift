//
//         FILE: day04.swift
//  DESCRIPTION: Advent of Code 2025 Day 4: Printing Department
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/03/25 21:05:11
//

import Foundation
import Library

let vectors = [
    Point2D( x: -1,  y: -1 ), Point2D( x:  0,  y: -1 ), Point2D( x:  1,  y: -1 ),
    Point2D( x: -1,  y:  0 ),                           Point2D( x:  1,  y:  0 ),
    Point2D( x: -1,  y:  1 ), Point2D( x:  0,  y:  1 ), Point2D( x:  1,  y:  1 ),
]

func parse( input: AOCinput ) -> Set<Point2D> {
    input.lines.indices.reduce( into: Set<Point2D>() ) { ( rolls, y ) in
        let row = Array( input.lines[y] )
        for x in row.indices {
            if row[x] == "@" {
                rolls.insert( Point2D( x: x, y: y ) )
            }
        }
    }
}


func neighborCount( point: Point2D, in rolls: Set<Point2D> ) -> Int {
    vectors.reduce( 0 ) { $0 + ( rolls.contains( $1 + point ) ? 1 : 0 ) }
}


func removable( rolls: Set<Point2D> ) -> Set<Point2D> {
    rolls.reduce( into: Set<Point2D>() ) { ( removable, roll ) in
        if neighborCount( point: roll, in: rolls ) < 4 {
            removable.insert( roll )
        }
    }
}


func part1( input: AOCinput ) -> String {
    let rolls = parse( input: input )
    return "\(removable( rolls: rolls ).count)"
}


func part2( input: AOCinput ) -> String {
    var rolls = parse( input: input )
    let initialCount = rolls.count
    
    while true {
        let removable = removable( rolls: rolls )
        if removable.isEmpty { break }
        rolls.subtract( removable )
    }
    return "\(initialCount - rolls.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
