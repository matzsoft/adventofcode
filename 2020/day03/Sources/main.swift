//
//         FILE: main.swift
//  DESCRIPTION: day03 - Toboggan Trajectory
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/23/21 19:07:20
//

import Foundation
import Library

struct Forest {
    let grid: [[Character]]
    
    init( lines: [String] ) {
        grid = lines.map { $0.map { $0 } }
    }
    
    func traverse( slope: Point2D ) -> Int {
        var position = Point2D( x: 0, y: 0 )
        var treeCount = 0
        
        while position.y < grid.count {
            if grid[position.y][ position.x % grid[0].count ] == "#" {
                treeCount += 1
            }
            position = position + slope
        }
        
        return treeCount
    }
}


func parse( input: AOCinput ) -> Forest {
    return Forest( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let forest = parse( input: input )
    
    return "\( forest.traverse( slope: Point2D( x: 3, y: 1 ) ) )"
}


func part2( input: AOCinput ) -> String {
    let forest = parse( input: input )
    let slopes = [
        Point2D( x: 1, y: 1 ),
        Point2D( x: 3, y: 1 ),
        Point2D( x: 5, y: 1 ),
        Point2D( x: 7, y: 1 ),
        Point2D( x: 1, y: 2 ),
    ]
    let treeCounts = slopes.map { forest.traverse( slope: $0 ) }

    return "\( treeCounts.reduce( 1, * ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
