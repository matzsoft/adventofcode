//
//         FILE: day10.swift
//  DESCRIPTION: Advent of Code 2023 Day 10: Pipe Maze
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/23 21:00:01
//

import Foundation
import Library

enum Tile: Character, CaseIterable {
    case northSouth = "|", eastWest = "-",  northEast = "L"
    case northWest = "J",  southWest = "7", southEast = "F"
    case ground = ".",     start = "S"
    
    init?( directions: Set<DirectionUDLR> ) {
        for tile in Tile.allCases {
            if tile.directions == directions { self = tile; return }
        }
        return nil
    }
    
    var directions: Set<DirectionUDLR> {
        switch self {
        case .northSouth:
            return [ .up, .down ]
        case .eastWest:
            return [ .right, .left ]
        case .northEast:
            return [ .up, .right ]
        case .northWest:
            return [ .up, .left ]
        case .southWest:
            return [ .down, .left ]
        case .southEast:
            return [ .down, .right ]
        default:
            return []
        }
    }
}


struct Map: CustomStringConvertible {
    let start: Point2D
    let map: [[Tile]]
    
    var description: String {
        map.map { row in
            row.map { String( $0.rawValue ) }.joined()
        }.joined( separator: "\n" )
    }
    
    init( start: Point2D, map: [[Tile]] ) {
        self.start = start
        self.map = map
    }
    
    init( lines: [String] ) {
        var start: Point2D?
        let map = lines.indices.reduce( into: [[Tile]]() ) { map, y in
            let characters = Array( lines[y] )
            let row = characters.map { Tile( rawValue: $0 )! }
            if let x = row.firstIndex( of: .start ) { start = Point2D( x: x, y: y ) }
            map.append( row )
        }
        
        self.start = start!
        self.map = map
    }
    
    subscript( point: Point2D ) -> Tile? {
        self[ point.x, point.y ]
    }
    
    subscript( _ x: Int, _ y: Int ) -> Tile? {
        guard 0 <= y && y < map.count else { return nil }
        guard 0 <= x && x < map[y].count else { return nil }
        return map[y][x]
    }
    
    var startConverted: Map {
        let x = self.start.x
        let y = self.start.y
        var startDirections = Set<DirectionUDLR>()
        
        if let tile = self[x,y-1], tile.directions.contains( .down )  { startDirections.insert( .up ) }
        if let tile = self[x,y+1], tile.directions.contains( .up )    { startDirections.insert( .down ) }
        if let tile = self[x-1,y], tile.directions.contains( .right ) { startDirections.insert( .left ) }
        if let tile = self[x+1,y], tile.directions.contains( .left )  { startDirections.insert( .right ) }
        
        var map = self.map
        map[y][x] = Tile( directions: startDirections )!
        
        return Map( start: start, map: map )
    }
    
    var loop: Set<Point2D> {
        var current = start + self[ start ]!.directions.first!.vector
        var loop = Set<Point2D>( [ start ] )
        
        while true {
            loop.insert( current )
            
            let direction = self[ current ]!.directions.first { !loop.contains( current + $0.vector ) }
            
            if direction == nil  { break }
            current = current + direction!.vector
        }
        
        return loop
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines ).startConverted
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    return "\( map.loop.count / 2 )"
}


func ray( start: Point2D, bounds: Rect2D, vector: Point2D ) -> Set<Point2D> {
    var ray = Set<Point2D>()
    var current = start
    
    repeat {
        ray.insert( current )
        current = current + vector
    } while bounds.contains( point: current )
    
    return ray
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let loop = map.loop/*.filter { map[$0] != .northEast && map[$0] != .southWest }*/
    let bounds = Rect2D( points: Array( loop ) )
    let vectors = Array<Direction8>( [ .NE, .SE, .NW, .SW ] ).map { $0.vector }
    let candidates = Set( bounds.points ).subtracting( loop )
    let insiders = candidates.filter { candidate in
        let rays = vectors.map { ray( start: candidate, bounds: bounds, vector: $0 ) }
        let maxCrossings = rays.map { $0.intersection( loop ).count }.max()!

        return !maxCrossings.isMultiple( of: 2 )
    }
    return "\( insiders.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
