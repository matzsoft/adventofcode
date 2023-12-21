//
//         FILE: day21.swift
//  DESCRIPTION: Advent of Code 2023 Day 21: Step Counter
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/20/23 21:00:01
//

import Foundation
import Library

enum TileType: Character { case plot = ".", rock = "#" }

struct Map {
    var current: Set<Point2D>
    let map: [[TileType]]
    let bounds: Rect2D
    let location: Point2D
    var full: Bool
    
    subscript( point: Point2D ) -> TileType? {
        guard bounds.contains( point: point ) else { return nil }
        return map[point.y][point.x]
    }
    
    init( lines: [String] ) {
        var start: Point2D?
        map = lines.indices.map { y in
            let characters = Array( lines[y] )
            return characters.indices.map { x in
                if let tile = TileType( rawValue: characters[x] ) { return tile }
                guard characters[x] == "S" else {
                    fatalError( "Invalid character '\(characters[x]) in map." )
                }
                start = Point2D( x: x, y: y )
                return .plot
            }
        }
        self.current = [start!]
        bounds = Rect2D(min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count )!
        location = Point2D( x: 0, y: 0 )
        full = false
    }
    
    mutating func step() -> Void {
        var next = Set<Point2D>()
        
        for plot in current {
            for neighbor in DirectionUDLR.allCases.map( { plot + $0.vector } ) {
                if self[neighbor] == .plot { next.insert( neighbor ) }
            }
        }
        current = next
    }
}


struct InfinityMap {
    let maps: [ Point2D : Map ]
    
    init( initial: Map ) {
        maps = [ initial.location : initial ]
    }
}


func part1( input: AOCinput ) -> String {
    var map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    var reached = [ Set( map.current ) ]
    
    for step in 1 ... stepLimit {
        map.step()
    }
    
    return "\( map.current.count )"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
