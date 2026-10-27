//
//         FILE: day16.swift
//  DESCRIPTION: Advent of Code 2024 Day 16: Reindeer Maze
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/15/24 21:59:31
//

import Foundation
import Library

extension Direction4 {
    public var toArrow: Character {
        switch self {
        case .north:
            return "^"
        case .south:
            return "v"
        case .west:
            return "<"
        case .east:
            return ">"
        }
    }
}

enum Tile: Character { case empty = ".", wall = "#", start = "S", end = "E" }

struct Reindeer {
    let position: Point2D
    let direction: Direction4
    let score: Int
    
    var move: Reindeer {
        Reindeer(
            position: position + direction.vector,
            direction: direction, score: score + 1
        )
    }
    
    func turn( _ turn: Turn ) -> Reindeer {
        Reindeer(
            position: position,
            direction: direction.turn( direction: turn ), score: score + 1000
        )
    }
}

struct Maze {
    let map: [[Tile]]
    let start: Point2D
    let end: Point2D
    var reindeer: Reindeer
    
    init( lines: [String] ) {
        let map = lines.reversed().map { $0.map { Tile( rawValue: $0 )! } }
        let startY = map.indices.first( where: { map[$0].contains( .start ) } )!
        let startX = map[startY].indices.first( where: { map[startY][$0] == .start } )!
        let endY = map.indices.first( where: { map[$0].contains( .end ) } )!
        let endX = map[endY].indices.first( where: { map[endY][$0] == .end } )!

        self.map = map
        start = Point2D( x: startX, y: startY )
        end = Point2D( x: endX, y: endY )
        reindeer = Reindeer( position: start, direction: .east, score: 0 )
    }
    
    subscript( point: Point2D ) -> Tile {
        map[point.y][point.x]
    }
    
    func solve() -> ( Int, [[Reindeer]] ) {
        var seen = [ reindeer.position : [ reindeer.direction : reindeer.score ] ]
        var queue = [[reindeer]]
        var bestScore = Int.max
        var bestPaths = [[Reindeer]()]
        
        func update( path: [Reindeer], candidate: Reindeer ) {
            if seen[candidate.position] == nil {
                seen[candidate.position] = [ candidate.direction : candidate.score ]
                queue.append( path + [candidate] )
            } else if seen[candidate.position]?[candidate.direction] == nil {
                seen[candidate.position]![candidate.direction] = candidate.score
                queue.append( path + [candidate] )
            } else if seen[candidate.position]![candidate.direction]! >= candidate.score {
                seen[candidate.position]![candidate.direction] = candidate.score
                queue.append( path + [candidate] )
            }
        }
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let moved = current.last!.move
            
            switch self[moved.position] {
            case .wall:
                break
            case .empty, .start:
                update( path: current, candidate: moved )
            case .end:
                if moved.score < bestScore {
                    bestScore = moved.score
                    bestPaths = [ current + [moved] ]
                } else if moved.score == bestScore {
                    bestPaths.append( current + [moved] )
                }
            }
            
            let right = current.last!.turn( .right )
            update( path: current, candidate: right )

            let left = current.last!.turn( .left )
            update( path: current, candidate: left )
        }
        
        guard bestScore < Int.max else { fatalError( "No solution" ) }
//        print( showPath( path: bestPath ) )
        return ( bestScore, bestPaths )
    }
    
    func showPath( path: [Reindeer] ) -> String {
        var buffer = map.map { $0.map { $0.rawValue } }
        
        for reindeer in path {
            buffer[reindeer.position.y][reindeer.position.x] = reindeer.direction.toArrow
        }
        
        return buffer.reversed().map { String( $0 ) }.joined( separator: "\n" )
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let maze = Maze( lines: input.lines )
    let ( score, _ ) = maze.solve()
    return "\(score)"
}


func part2( input: AOCinput ) -> String {
    let maze = Maze( lines: input.lines )
    let ( score, paths ) = maze.solve()
    let goodSeats = paths.reduce( into: Set<Point2D>() ) { set, path in
        path.forEach { set.insert( $0.position ) }
    }
    return "\(goodSeats.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
