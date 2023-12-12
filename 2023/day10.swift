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
    
    init?( directions: Set<Direction4> ) {
        for tile in Tile.allCases {
            if tile.directions == directions { self = tile; return }
        }
        return nil
    }
    
    var directions: Set<Direction4> {
        switch self {
        case .northSouth:
            return [ .north, .south ]
        case .eastWest:
            return [ .east, .west ]
        case .northEast:
            return [ .north, .east ]
        case .northWest:
            return [ .north, .west ]
        case .southWest:
            return [ .south, .west ]
        case .southEast:
            return [ .south, .east ]
        default:
            return []
        }
    }
}


struct Map: CustomStringConvertible {
    let start: Point2D
    let map: [[Tile]]
    
    var description: String {
        map.reversed().map { row in
            row.map { String( $0.rawValue ) }.joined()
        }.joined( separator: "\n" )
    }
    
    init( start: Point2D, map: [[Tile]] ) {
        self.start = start
        self.map = map
    }
    
    init( lines: [String] ) {
        var start: Point2D?
        let lines = Array( lines.reversed() )
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
        var startDirections = Set<Direction4>()
        
        if let tile = self[x,y-1], tile.directions.contains( .north )  { startDirections.insert( .south ) }
        if let tile = self[x,y+1], tile.directions.contains( .south )    { startDirections.insert( .north ) }
        if let tile = self[x-1,y], tile.directions.contains( .east ) { startDirections.insert( .west ) }
        if let tile = self[x+1,y], tile.directions.contains( .west )  { startDirections.insert( .east ) }
        
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
    
    while bounds.contains( point: current ) {
        ray.insert( current )
        current = current + vector
    }
    
    return ray
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let loop = map.loop
    let validEdges = loop.filter { map[$0] != .northEast && map[$0] != .southWest }
    let bounds = Rect2D( points: Array( loop ) )
    let candidates = Set( bounds.points )
        .subtracting( loop )
        .filter {
            let ray = ray( start: $0, bounds: bounds, vector: Point2D( x: 1, y: -1 ) )
            return !ray.intersection( validEdges ).count.isMultiple( of: 2 )
        }

    return "\(candidates.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
