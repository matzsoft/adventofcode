//
//         FILE: main.swift
//  DESCRIPTION: day11 - Seating System
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/25/21 16:06:56
//

import Foundation

struct SeatLayout: CustomStringConvertible {
    enum State: String { case floor = ".", occupied = "#", empty = "L" }
    
    var grid: [[State]]
    
    init( lines: [String] ) {
        grid = lines.map { $0.map { State( rawValue: String( $0 ) )! } }
    }

    subscript( position: Point2D ) -> State {
        get {
            return grid[position.y][position.x]
        }
        set( newValue ) {
            grid[position.y][position.x] = newValue
        }
    }
    
    func isValid( position: Point2D ) -> Bool {
        guard 0 <= position.y && position.y < grid.count else { return false }
        guard 0 <= position.x && position.x < grid[position.y].count else { return false }
        
        return true
    }
    
    var description: String {
        grid.map { $0.map { $0.rawValue }.joined() }.joined( separator: "\n" )
    }
    
    func occupiedCount( position: Point2D, isOccupied: ( SeatLayout, Point2D, Direction8 ) -> Bool ) -> Int {
        return Direction8.allCases.filter { isOccupied( self, position, $0 ) }.count
    }

    func solve( crowdThreshold: Int, isOccupied: ( SeatLayout, Point2D, Direction8 ) -> Bool ) -> Int {
        var oldgrid = self
        var newgrid = self
        let positions = grid.indices.flatMap { (row) -> [Point2D] in
            grid[row].indices.map { Point2D( x: $0, y: row ) }
        }

        repeat {
            oldgrid = newgrid
            //print( "\(oldgrid)" )
            //print()
            for position in positions {
                let count = oldgrid.occupiedCount( position: position, isOccupied: isOccupied )

                if oldgrid[position] == .empty {
                    if count == 0 { newgrid[position] = .occupied }
                } else if oldgrid[position] == .occupied {
                    if count >= crowdThreshold { newgrid[position] = .empty }
                }
            }
        } while oldgrid.grid != newgrid.grid
        
        return oldgrid.grid.flatMap { $0 }.filter { $0 == .occupied }.count
    }
}


func parse( input: AOCinput ) -> SeatLayout {
    return SeatLayout( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let result = parse( input: input ).solve( crowdThreshold: 4 ) { layout, position, direction in
        let target = position + direction.vector
        
        guard layout.isValid( position: target ) else { return false }
        return layout[target] == .occupied
    }
    
    return "\( result )"
}


func part2( input: AOCinput ) -> String {
    let result = parse( input: input ).solve( crowdThreshold: 5 ) { layout, position, direction in
        var target = position + direction.vector
        
        while layout.isValid( position: target ) {
            if layout[target] != .floor { return layout[target] == .occupied }
            target = target + direction.vector
        }
        
        return false
    }
    
    return "\( result )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
