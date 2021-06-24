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

struct Traversal {
    let slope: Point2D
    
    func downhill( grid: [[Character]] ) -> Int {
        var position = Point2D( x: 0, y: 0 )
        var treeCount = 0
        
        while position.y < grid.count {
            if grid[position.y][position.x] == "#" {
                treeCount += 1
            }
            position = position + slope
            position = Point2D( x: position.x % grid[0].count, y: position.y )
        }
        
        return treeCount
    }
}


func parse( input: AOCinput ) -> [[Character]] {
    return input.lines.map { $0.map { $0 } }
}


func part1( input: AOCinput ) -> String {
    let grid = parse( input: input )
    let traversal = Traversal( slope: Point2D( x: 3, y: 1 ) )
    
    return "\( traversal.downhill( grid: grid ) )"
}


func part2( input: AOCinput ) -> String {
    let grid = parse( input: input )
    let traversals = [
        Traversal( slope: Point2D( x: 1, y: 1 ) ),
        Traversal( slope: Point2D( x: 3, y: 1 ) ),
        Traversal( slope: Point2D( x: 5, y: 1 ) ),
        Traversal( slope: Point2D( x: 7, y: 1 ) ),
        Traversal( slope: Point2D( x: 1, y: 2 ) ),
    ]
    let treeCounts = traversals.map { $0.downhill( grid: grid ) }

    return "\( treeCounts.reduce( 1, * ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
