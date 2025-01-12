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

extension DirectionUDLR {
    init( from vector: Point2D ) {
        switch ( vector.x, vector.y ) {
        case let ( x, y ) where x < 0 && y == 0:
            self = .left
        case let ( x, y ) where x > 0 && y == 0:
            self = .right
        case let ( x, y ) where x == 0 && y < 0:
            self = .up
        case let ( x, y ) where x == 0 && y > 0:
            self = .down
        default:
            fatalError( "\(vector) is not orthogonal" )
        }
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
    enum Internal {
        case wall, empty
        
        var toExternal: External {
            switch self {
            case .wall:
                return .wall
            case .empty:
                return .empty
            }
        }
    }
    
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
    
    
    var shortestPath: ( [Point2D], [[Int?]] ) {
        var current = start
        var previous = current
        var points = [ start ]
        var distances = map.map { $0.map { _ -> Int? in nil } }
        distances[start.y][start.x] = 0
                
        while current != end {
            for trial in DirectionUDLR.allCases.map( { current + $0.vector } ) {
                if bounds.contains( point: trial ) {
                    if self[trial] == .empty && trial != previous {
                        points.append( trial )
                        distances[trial.y][trial.x] = distances[current.y][current.x]! + 1
                        previous = current
                        current = trial
                        break
                    }
                }
            }
        }
//        print( pathDescription( points: points, distances: distances ) )
        return ( points, distances )
    }

    func pathDescription( points: [Point2D], distances: [[Int?]] ) -> String {
        var pathBuffer = map.map { $0.map { $0.toExternal.rawValue } }
        pathBuffer[start.y][start.x] = External.start.rawValue
        pathBuffer[end.y][end.x] = External.end.rawValue
        
        for index in points.indices.dropFirst().dropLast() {
            let vector = points[index+1] - points[index]
            let point = points[index]
            pathBuffer[point.y][point.x]
            = Character( DirectionUDLR( from: vector ).toArrow )
        }
        
        let bigRow = String( repeating: "#", count: bounds.width + 2 )
        let lines = pathBuffer.map { "#" + String( $0 ) + "#" }
        let distanceBuffer = distances.map {
            $0.map { $0 == nil ? "--" : String( format: "%2d", $0! ) }.joined( separator: " ")
        }
        return ( [ bigRow ] + lines + [ bigRow ] + distanceBuffer                                                            ).joined( separator: "\n" )
    }
    
    // ...3...
    // ..323..
    // .32123.
    // 3210123
    // .32123.
    // ..323..
    // ...3...
    func countCheats( cheatLimit: Int, threshold: Int ) -> Int {
        let ( points, distances ) = shortestPath
        let circle = manhattenCircle( radius: cheatLimit )

        var total = 0
        for point1 in points {
            let distance1 = distances[point1.y][point1.x]!
            let candidatePoints = circle
                .map { $0 + point1 }
                .filter { bounds.contains( point: $0 ) }
                .filter { distances[$0.y][$0.x] != nil }
            for point2 in candidatePoints {
                let delta = distances[point2.y][point2.x]! - distance1
                let distance = point1.distance( other: point2 )
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
