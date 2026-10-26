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

    init( from: Character, slipperySlope: Bool = true ) {
        switch from {
        case ".":
            self = .path
        case "#":
            self = .forest
        default:
            if !slipperySlope {
                self = .path
            } else {
                guard let direction = DirectionUDLR.fromArrows( char: String( from ) ) else {
                    fatalError( "\(from) is not a valid tile." )
                }
                self = .slope( direction )
            }
        }
    }
}


struct Network: CustomStringConvertible {
    struct Edge: Hashable {
        let position: Point2D
        let direction: DirectionUDLR
        let length: Int
        
        init( position: Point2D, direction: DirectionUDLR, length: Int ) {
            self.position = position
            self.direction = direction
            self.length = length
        }
        
        var step: Edge {
            Edge( position: position + direction.vector, direction: direction, length: length + 1 )
        }
    }

    let nodes: [ Point2D : [ DirectionUDLR : Edge ] ]
    let start: Edge
    let finish: Edge
    
    var description: String {
        let sorted = nodes.sorted {
            if $0.key.y < $1.key.y { return true }
            if $0.key.y > $1.key.y { return false }
            return $0.key.x < $1.key.x
        }
        var lines = [String]()
        
        for node in sorted {
            lines.append( "\(node.key)" )
            for edge in node.value {
                lines.append(
                    "   \(edge.key) => \(edge.value.position), \(edge.value.direction), \(edge.value.length)"
                )
            }
        }
        return lines.joined( separator: "\n" )
    }
    
    init( nodes: [ Point2D : [ DirectionUDLR : Network.Edge ] ], start: Edge, finish: Edge ) {
        self.nodes = nodes
        self.start = start
        self.finish = finish
    }
    
    init( trails: Trails ) {
        start = Edge( position: trails.start, direction: .down, length: 0 )
        finish = Edge(position: trails.finish, direction: .down, length: 0 )
        var nodes = [
            start.position : [ DirectionUDLR : Edge ](),
            finish.position : [ DirectionUDLR : Edge ](),
        ]
        var queue = [ start ]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            let next = trails.walk( from: current )
            let neighbors = trails.neighbors( node: next )
                .filter { nodes[ next.position ]?[ $0.direction ] == nil }
            
            if neighbors.count > 1 || nodes[next.position] != nil {
                nodes[ current.position, default: [:] ][ current.direction ] = next
                neighbors.forEach {
                    queue.append( Edge( position: next.position, direction: $0.direction, length: 0 ) )
                }
            }
        }
        
        self.nodes = nodes
    }
    
    var refined: Network {
        struct QueueNode {
            let from: Point2D
            let to: Point2D
        }
        
        var newNodes = nodes
        var queue = [ QueueNode( from: start.position, to: nodes[start.position]!.first!.value.position ) ]
        var edges = Set( nodes.filter { $0.value.count == 3 }.map { $0.key } ).union( [finish.position ] )

        while let current = queue.first {
            queue.removeFirst()
            edges.remove( current.to )
            newNodes[current.to] = newNodes[current.to]!.filter { $0.value.position != current.from }
            queue.append( contentsOf: newNodes[current.to]!
                .filter { edges.contains( $0.value.position ) }
                .map { QueueNode( from: current.to, to: $0.value.position ) }
            )
        }
        
        return Network( nodes: newNodes, start: start, finish: finish )
    }
    
    struct QueueNode {
        let position: Point2D
        let steps: Int
    }

    func longestPath() -> Int {
        allPaths( start: QueueNode( position: start.position, steps: 0), seen: Set<Point2D>() ).max()!
    }
    
    func allPaths( start: QueueNode, seen: Set<Point2D> ) -> [ Int ] {
        var seen = seen
        var queue = [ start ]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let neighbors = nodes[current.position]!
                .filter { !seen.contains( $0.value.position ) }
                .map { QueueNode( position: $0.value.position, steps: current.steps + $0.value.length ) }
            
            seen.insert( current.position )
            if current.position == finish.position { return [ current.steps ] }
            if neighbors.count == 1 {
                queue.append( contentsOf: neighbors )
            } else {
                return neighbors.flatMap { allPaths( start: $0, seen: seen ) }
            }
        }
        
        return []
    }
}


struct Trails {
    let tiles: [[Tile]]
    let bounds: Rect2D
    let start: Point2D
    let finish: Point2D
    
    subscript( _ point: Point2D ) -> Tile {
        tiles[point.y][point.x]
    }
    
    init( lines: [String], slipperySlope: Bool = true ) {
        let tiles = lines.map { $0.map { Tile( from: $0, slipperySlope: slipperySlope ) } }
        let startX = tiles.first!.indices.first( where: { tiles.first![$0] == .path } )!
        let finishX = tiles.last!.indices.first( where: { tiles.last![$0] == .path } )!
        
        self.tiles = tiles
        self.bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: tiles[0].count, height: tiles.count )!
        self.start = Point2D( x: startX, y: 0 )
        self.finish = Point2D( x: finishX, y: tiles.count - 1 )
    }
    
    func neighbors( node: Network.Edge ) -> [Network.Edge] {
        DirectionUDLR.allCases
            .map {
                Network.Edge( position: node.position + $0.vector, direction: $0, length: node.length + 1 )
            }
            .filter {
                guard bounds.contains( point: $0.position ) else { return false }
                let tile = self[$0.position]
                return tile == .path || tile.direction == $0.direction
            }
    }
    
    func walk( from: Network.Edge ) -> Network.Edge {
        var current = from.step
        
        while true {
            let neighbors = neighbors( node: current )
                .filter { $0.direction != current.direction.turn( .back ) }
            
            if neighbors.count != 1 { return current }
            current = neighbors[0]
        }
    }
}


func part1( input: AOCinput ) -> String {
    let trails = Trails( lines: input.lines )
    let network = Network( trails: trails )
    return "\( network.longestPath() )"
}


func part2( input: AOCinput ) -> String {
    let trails = Trails( lines: input.lines, slipperySlope: false )
    let network = Network( trails: trails ).refined
    return "\( network.longestPath() )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
