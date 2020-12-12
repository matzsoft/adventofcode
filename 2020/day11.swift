//
//  main.swift
//  day11
//
//  Created by Mark Johnson on 12/10/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct SeatLayout {
    enum State: String {
        case floor = ".", occupied = "#", empty = "L"
    }
    
    enum Direction: CaseIterable {
        case north, northeast, east, southeast, south, southwest, west, northwest
        
        var row: Int {
            switch self {
            case .northwest, .north, .northeast:
                return -1
            case .west, .east:
                return 0
            case .southwest, .south, .southeast:
                return 1
            }
        }
        
        var col: Int {
            switch self {
            case .northwest, .west, .southwest:
                return -1
            case .north, .south:
                return 0
            case .northeast, .east, .southeast:
                return 1
            }
        }
    }
    
    struct Position {
        let row: Int
        let col: Int
        
        func offset( by: Direction ) -> Position {
            return Position( row: row + by.row, col: col + by.col )
        }
    }
    
    var grid: [[State]]
    
    init( input: String ) {
        grid = input.split( separator: "\n" ).map { $0.map { State( rawValue: String( $0 ) )! } }
    }

    subscript( position: Position ) -> State {
        get {
            return grid[position.row][position.col]
        }
        set(newValue) {
            grid[position.row][position.col] = newValue
        }
    }
    
    func isValid( position: Position ) -> Bool {
        guard 0 <= position.row && position.row < grid.count else { return false }
        guard 0 <= position.col && position.col < grid[position.row].count else { return false }
        
        return true
    }

    func part1OccupiedCount( position: Position, direction: Direction ) -> Int {
        let target = position.offset( by: direction )
        
        return !isValid( position: target ) ? 0 : ( self[target] == .occupied ? 1 : 0 )
    }
    
    func part1NeighborCount( position: Position ) -> Int {
        return Direction.allCases.reduce( 0 ) {
            $0 + part1OccupiedCount( position: position, direction: $1 )
        }
    }
    
    func part2OccupiedCount( position: Position, direction: Direction ) -> Int {
        var target = position.offset( by: direction )
        
        while isValid( position: target ) {
            if self[target] != .floor { return self[target]  == .occupied ? 1 : 0 }
            target = target.offset( by: direction )
        }
        
        return 0
    }
    
    func part2NeighborCount( position: Position ) -> Int {
        return Direction.allCases.reduce( 0 ) {
            $0 + part2OccupiedCount( position: position, direction: $1 )
        }
    }
    
    func part1() -> Int {
        var oldgrid = self
        var newgrid = self
        let positions = grid.indices.flatMap { (row) -> [Position] in
            grid[row].indices.map { Position( row: row, col: $0 ) }
        }

        repeat {
            oldgrid = newgrid
            for position in positions {
                let count = oldgrid.part1NeighborCount( position: position )
                
                if oldgrid[position] == .empty {
                    if count == 0 { newgrid[position] = .occupied }
                } else if oldgrid[position] == .occupied {
                    if count > 3 { newgrid[position] = .empty }
                }
            }
        } while oldgrid.grid != newgrid.grid
        
        return oldgrid.grid.flatMap { $0 }.filter { $0 == .occupied }.count
    }
    
    func part2() -> Int {
        var oldgrid = self
        var newgrid = self
        let positions = grid.indices.flatMap { (row) -> [Position] in
            grid[row].indices.map { Position( row: row, col: $0 ) }
        }

        repeat {
            oldgrid = newgrid
            for position in positions {
                let count = oldgrid.part2NeighborCount( position: position )
                
                if oldgrid[position] == .empty {
                    if count == 0 { newgrid[position] = .occupied }
                } else if oldgrid[position] == .occupied {
                    if count > 4 { newgrid[position] = .empty }
                }
            }
        } while oldgrid.grid != newgrid.grid

        return oldgrid.grid.flatMap { $0 }.filter { $0 == .occupied }.count
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day11.txt"
let initial = try SeatLayout( input:  String( contentsOfFile: inputFile ) )

print( "Part 1: \(initial.part1())" )
print( "Part 2: \(initial.part2())" )
