//
//         FILE: main.swift
//  DESCRIPTION: day18 - Like a GIF For Your Yard
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/09/21 13:31:09
//

import Foundation
import Library

class Grid {
    var cells: Set<Point2D>
    let bounds: Rect2D
    let stuck: Bool
    let corners: [Point2D]
    
    init( lines: [String], stuck: Bool = false ) {
        cells = lines.enumerated().reduce( into: Set<Point2D>() ) { set, row in
            row.element.enumerated().forEach { col in
                if col.element == "#" { set.insert( Point2D( x: col.offset, y: row.offset ) ) }
            }
        }
        let maxes = Point2D( x: lines.map { $0.count }.max()! - 1, y: lines.count - 1 )
        
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), max: maxes )
        self.stuck = stuck
        corners = [
            Point2D( x: bounds.min.x, y: bounds.min.y ),
            Point2D( x: bounds.min.x, y: bounds.max.y ),
            Point2D( x: bounds.max.x, y: bounds.min.y ),
            Point2D( x: bounds.max.x, y: bounds.max.y ),
        ]
        if stuck { cells.formUnion( corners ) }
    }
    
    func update() -> Void {
        var newCells = Set<Point2D>()

        for x in bounds.min.x ... bounds.max.x {
            for y in bounds.min.y ... bounds.max.y {
                let position = Point2D( x: x, y: y )
                let neighbors = Direction8.allCases.filter { cells.contains( position + $0.vector ) }.count
                
                if neighbors == 3 || ( neighbors == 2 && cells.contains( position ) ) {
                    newCells.insert( position )
                }
            }
        }
        
        cells = newCells
        if stuck { cells.formUnion( corners ) }
    }
}


func part1( input: AOCinput ) -> String {
    let grid = Grid( lines: input.lines )
    
    for _ in 1 ... Int( input.extras[0] )! { grid.update() }
    return "\( grid.cells.count )"
}


func part2( input: AOCinput ) -> String {
    let grid = Grid( lines: input.lines, stuck: true )
    
    for _ in 1 ... Int( input.extras[1] )! { grid.update() }
    return "\( grid.cells.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
