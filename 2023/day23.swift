//
//         FILE: day23.swift
//  DESCRIPTION: Advent of Code 2023 Day 23: A Long Walk
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/22/23 21:00:01
//

import Foundation
import Library

enum Tile: Equatable {
    case path, forest, slope( DirectionUDLR )
    
    var description: String {
        switch self {
        case .path:
            return "."
        case .forest:
            return "#"
        case .slope( let direction):
            return direction.rawValue
        }
    }
    
    var direction: DirectionUDLR? {
        switch self {
        case .path, .forest:
            return nil
        case .slope( let direction ):
            return direction
        }
    }

    init( from: Character ) {
        switch from {
        case ".":
            self = .path
        case "#":
            self = .forest
        default:
            guard let direction = DirectionUDLR.fromArrows( char: String( from ) ) else {
                fatalError( "\(from) is not a valid tile." )
            }
            self = .slope( direction )
        }
    }
}


struct Node {
    let location: Point2D
    let steps: Int
}


struct Trails {
    let tiles: [[Tile]]
    let bounds: Rect2D
    let start: Point2D
    let finish: Point2D
    
    subscript( _ point: Point2D ) -> Tile {
        tiles[point.y][point.x]
    }
    
    init( lines: [String] ) {
        let tiles = lines.map { $0.map { Tile( from: $0 ) } }
        let startX = tiles.first!.indices.first( where: { tiles.first![$0] == .path } )!
        let finishX = tiles.last!.indices.first( where: { tiles.last![$0] == .path } )!
        
        self.tiles = tiles
        self.bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: tiles[0].count, height: tiles.count )!
        self.start = Point2D( x: startX, y: 0 )
        self.finish = Point2D( x: finishX, y: tiles.count - 1 )
    }
    
    var traverse: Int {
        var seen = Set<Point2D>()
        var queue = [ Node( location: start, steps: 0 ) ]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let neighbors = DirectionUDLR.allCases
                .filter { bounds.contains( point: current.location + $0.vector ) }
                .filter { direction in
                    let location = current.location + direction.vector
                    guard bounds.contains( point: location ) else { return false }
                    if seen.contains( location ) { return false }
                    let tile = self[ location ]
                    return tile == .path || tile.direction == direction
                }
                .map { Node(location: current.location + $0.vector, steps: current.steps + 1 ) }
            
            seen.insert( current.location )
            if current.location == finish { return current.steps }
            queue.append( contentsOf: neighbors )
        }
        
        return 0
    }
    
    func longestPath( slipperySlope: Bool = true ) -> Int {
        allPaths(
            start: Node( location: start, steps: 0),
            seen: Set<Point2D>(),
            slipperySlope: slipperySlope
        ).max()!
    }
    
    func allPaths( start: Node, seen: Set<Point2D>, slipperySlope: Bool ) -> [ Int ] {
        var seen = seen
        var queue = [ start ]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let neighbors = DirectionUDLR.allCases
                .filter { bounds.contains( point: current.location + $0.vector ) }
                .filter { direction in
                    let location = current.location + direction.vector
                    guard bounds.contains( point: location ) else { return false }
                    if seen.contains( location ) { return false }
                    let tile = self[ location ]
                    switch tile {
                    case .forest:
                        return false
                    case .path:
                        return true
                    case .slope( let tileDirection ):
                        return !slipperySlope || tileDirection == direction
                    }
                }
                .map { Node(location: current.location + $0.vector, steps: current.steps + 1 ) }
            
            seen.insert( current.location )
            if current.location == finish { return [ current.steps ] }
            if neighbors.count == 1 {
                queue.append( contentsOf: neighbors )
            } else {
                return neighbors.flatMap { allPaths( start: $0, seen: seen, slipperySlope: slipperySlope ) }
            }
        }
        
        return []
    }
}


func part1( input: AOCinput ) -> String {
    let trails = Trails( lines: input.lines )
    return "\( trails.longestPath() )"
}


func part2( input: AOCinput ) -> String {
    let trails = Trails( lines: input.lines )
    return "\( trails.longestPath( slipperySlope: false ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
