//
//         FILE: day20.swift
//  DESCRIPTION: Advent of Code 2024 Day 20: Race Condition
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/19/24 23:20:40
//

import Foundation
import Library

struct Node {
    let position: Point2D
    let distance: Int
    let previous: Point2D?
    
    init( position: Point2D, distance: Int, previous: Point2D? = nil ) {
        self.position = position
        self.distance = distance
        self.previous = previous
    }
    
    func move( direction: DirectionUDLR ) -> Node {
        Node(
            position: position + direction.vector, distance: distance + 1,
            previous: position
        )
    }
}


struct Map {
    enum External: Character {
        case wall = "#", empty = ".", start = "S", end = "E"
        
        var toInternal: Internal {
            switch self {
            case .wall:
                return .wall
            case .empty, .start, .end:
                return .empty
            }
        }
    }
    enum Internal { case wall, empty }
    
    let map: [[Internal]]
    let bounds: Rect2D
    let start: Point2D
    let end: Point2D
    
    init( lines: [String] ) {
        var start = Point2D( x: 0, y: 0 )
        var end = start
        let trimmed = Array( lines[ 1 ..< lines.count - 1 ] )
        map = trimmed.indices.map { y in
            let line = trimmed[y].dropLast().dropFirst().map { $0 }
            return line.indices.map { x in
                let external = External( rawValue: line[x] )!
                if external == .start { start = Point2D( x: x, y: y ) }
                if external == .end { end = Point2D( x: x, y: y ) }
                return external.toInternal
            }
        }
        bounds = Rect2D( min: Point2D.origin, width: map[0].count, height: map.count )!
        self.start = start
        self.end = end
    }
    
    subscript( _ point: Point2D ) -> Internal? {
        guard bounds.contains( point: point ) else { return nil }
        return map[point.y][point.x]
    }
    
    
    var shortestPath: [[Node?]] {
        var current = Node( position: start, distance: 0 )
        var previous = current
        var path = map.map { $0.map { _ -> Node? in nil } }
        path[start.y][start.x] = current
                
        while current.position != end {
            for trial in DirectionUDLR.allCases.map( { current.move( direction: $0 ) } ) {
                if bounds.contains( point: trial.position ) {
                    if self[trial.position] == .empty && trial.position != previous.position {
                        path[trial.position.y][trial.position.x] = trial
                        previous = current
                        current = trial
                        break
                    }
                }
            }
        }
        return path
    }

    // ...3...
    // ..323..
    // .32123.
    // 3210123
    // .32123.
    // ..323..
    // ...3...
    func countCheats( cheatLimit: Int, threshold: Int ) -> Int {
        let path = shortestPath
        let circle = manhattenCircle( radius: cheatLimit )

        var total = 0
        for point1 in bounds.points {
            guard let path1 = path[point1.y][point1.x] else { continue }
            let candidatePaths = circle
                .map { $0 + point1 }
                .filter { bounds.contains( point: $0 ) }
                .compactMap { path[$0.y][$0.x] }
            for path2 in candidatePaths {
                let delta = path2.distance - path1.distance
                let distance = point1.distance( other: path2.position )
                if delta - distance >= threshold { total += 1 }
            }
        }
        return total
    }
    
    func manhattenCircle( radius: Int ) -> [Point2D] {
        ( -radius ... radius ).reduce( into: [Point2D]() ) { circle, x in
            for y in -radius + abs( x ) ... radius - abs( x ) {
                circle.append( Point2D( x: x, y: y ) )
            }
        }
    }
}


func part1( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let threshold = input.extras[0].split( separator: "," ).map { Int( $0 )! }[0]

    return "\( map.countCheats( cheatLimit: 2, threshold: threshold ) )"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let threshold = input.extras[0].split( separator: "," ).map { Int( $0 )! }[1]

    return "\( map.countCheats( cheatLimit: 20, threshold: threshold ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
