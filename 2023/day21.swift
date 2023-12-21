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
    let start: Point2D
    let map: [[TileType]]
    let bounds: Rect2D
    
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
        self.start = start!
        bounds = Rect2D(min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count )!
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    var reached = [ Set( [ map.start ] ) ]
    
    for step in 1 ... stepLimit {
        var next = Set<Point2D>()
        
        for plot in reached[step-1] {
            for neighbor in DirectionUDLR.allCases.map( { plot + $0.vector } ) {
                if map[neighbor] == .plot { next.insert( neighbor ) }
            }
        }
        reached.append( next )
    }
    
    return "\( reached[stepLimit].count )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
