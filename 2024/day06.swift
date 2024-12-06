//
//         FILE: day06.swift
//  DESCRIPTION: Advent of Code 2024 Day 6: Guard Gallivant
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/05/24 21:00:02
//

import Foundation
import Library

struct Visited: Hashable {
    let position: Point2D
    let direction: DirectionUDLR
    
    func turn() -> Visited {
        Visited( position: position, direction: direction.turn( .right ) )
    }
    
    func move() -> Visited {
        Visited( position: position + direction.vector, direction: direction )
    }
}

struct Map {
    var sentry: Visited
    let obstacles: Set<Point2D>
    let bounds: Rect2D
    
    init( sentry: Visited, obstacles: Set<Point2D>, bounds: Rect2D ) {
        self.sentry = sentry
        self.obstacles = obstacles
        self.bounds = bounds
    }
    
    init( lines: [String] ) {
        var obstacles = Set<Point2D>()
        let map = lines.map { $0.map { $0 } }
                    
        sentry = Visited( position: Point2D( x: 0, y: 0 ), direction: .up )
        bounds = Rect2D(
            min: sentry.position, width: map[0].count, height: map.count )!

        for y in map.indices {
            for x in map[y].indices {
                if map[y][x] == "#" { obstacles.insert( Point2D( x: x, y: y ) ) }
                else if map[y][x] != "." {
                    sentry = Visited(
                        position: Point2D( x: x, y: y ),
                        direction: DirectionUDLR.fromArrows(
                            char: String( map[y][x] ) )!
                    )
                }
            }
        }
        
        self.obstacles = obstacles
    }
    
    mutating func countPositions() -> Set<Point2D> {
        var positions = Set<Point2D>()
        
        while bounds.contains( point: sentry.position ) {
            positions.insert( sentry.position )
            while obstacles.contains( sentry.position + sentry.direction.vector ) {
                sentry = sentry.turn()
            }
            sentry = sentry.move()
        }
        
        return positions
    }
    
    func add( newObstacle: Point2D ) -> Map {
        Map(
            sentry: sentry,
            obstacles: obstacles.union( [ newObstacle ] ), bounds: bounds
        )
    }
    
    mutating func checkLoop() -> Bool {
        var visited = Set<Visited>()
        
        while bounds.contains( point: sentry.position ) {
            if !visited.insert( sentry ).inserted { return true }
            while obstacles.contains( sentry.move().position ) {
                sentry = sentry.turn()
            }
            sentry = sentry.move()
        }
        
        return false
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var map = parse( input: input )
    
    return "\(map.countPositions().count)"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    var loopCount = 0
    
    for point in map.bounds.points {
        if point != map.sentry.position && !map.obstacles.contains( point ) {
            var newMap = map.add( newObstacle: point )
            loopCount += ( newMap.checkLoop() ? 1 : 0 )
        }
    }
    return "\(loopCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
