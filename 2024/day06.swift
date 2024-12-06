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
    
    mutating func walk() -> Set<Visited> {
        var positions = Set<Visited>()
        
        while bounds.contains( point: sentry.position ) {
            positions.insert( sentry )
            while obstacles.contains( sentry.move().position ) {
                sentry = sentry.turn()
                positions.insert( sentry )
            }
            sentry = sentry.move()
        }
        
        return positions
    }
    
    mutating func countPositions() -> Int {
        walk().reduce(into: Set<Point2D>() ) { visited, place in
            visited.insert( place.position )
        }.count
    }
    
    func add( sentry: Visited, newObstacle: Point2D ) -> Map {
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


func part1( input: AOCinput ) -> String {
    var map = Map( lines: input.lines )
    
    return "\(map.countPositions())"
}


func part2( input: AOCinput ) -> String {
    let originalMap = Map( lines: input.lines )
    var map = originalMap
    let walk = map.walk().filter {
        !originalMap.obstacles.contains( $0.move().position )
    }
    var loopCount = 0
    var added = Set<Point2D>()
    
    for visited in walk {
        let newObstacle = visited.move().position
        if newObstacle != originalMap.sentry.position {
            if added.insert( newObstacle ).inserted {
                map = originalMap.add( sentry: visited, newObstacle: newObstacle )
                loopCount += ( map.checkLoop() ? 1 : 0 )
            }
        }
    }
    return "\(loopCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
