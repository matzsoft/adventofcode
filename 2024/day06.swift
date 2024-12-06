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
}

struct Map {
    var sentryPosition: Point2D
    var sentryDirection: DirectionUDLR
    let obstacles: Set<Point2D>
    let bounds: Rect2D
    
    init(
        sentryPosition: Point2D, sentryDirection: DirectionUDLR,
        obstacles: Set<Point2D>, bounds: Rect2D
    ) {
        self.sentryPosition = sentryPosition
        self.sentryDirection = sentryDirection
        self.obstacles = obstacles
        self.bounds = bounds
    }
    
    init( lines: [String] ) {
        var obstacles = Set<Point2D>()
        let map = lines.map { $0.map { $0 } }
                    
        sentryPosition = Point2D( x: 0, y: 0 )
        sentryDirection = .up
        bounds = Rect2D(
            min: sentryPosition, width: map[0].count, height: map.count )!

        for y in map.indices {
            for x in map[y].indices {
                if map[y][x] == "#" { obstacles.insert( Point2D( x: x, y: y ) ) }
                else if map[y][x] != "." {
                    sentryPosition = Point2D( x: x, y: y )
                    sentryDirection = DirectionUDLR.fromArrows(
                        char: String( map[y][x] ) )!
                }
            }
        }
        
        self.obstacles = obstacles
    }
    
    mutating func countPositions() -> Set<Point2D> {
        var positions = Set<Point2D>()
        
        while bounds.contains( point: sentryPosition ) {
            positions.insert( sentryPosition )
            while obstacles.contains( sentryPosition + sentryDirection.vector ) {
                sentryDirection = sentryDirection.turn( .right )
            }
            sentryPosition = sentryPosition + sentryDirection.vector
        }
        
        return positions
    }
    
    func add( newObstacle: Point2D ) -> Map {
        Map( sentryPosition: sentryPosition, sentryDirection: sentryDirection, obstacles: obstacles.union( [ newObstacle ] ), bounds: bounds )
    }
    
    mutating func checkLoop() -> Bool {
        var visited = Set<Visited>()
        
        while bounds.contains( point: sentryPosition ) {
            if !visited.insert( Visited(
                position: sentryPosition, direction: sentryDirection ) ).inserted {
                return true
            }
            while obstacles.contains( sentryPosition + sentryDirection.vector ) {
                sentryDirection = sentryDirection.turn( .right )
            }
            sentryPosition = sentryPosition + sentryDirection.vector
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
        if point != map.sentryPosition && !map.obstacles.contains( point ) {
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
