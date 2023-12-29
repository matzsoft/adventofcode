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
    let plots: [ Point2D : Set<Point2D> ]
    let bounds: Rect2D
    let location: Point2D
    var current: Set<Point2D>
    var full: Bool
    
    subscript( point: Point2D ) -> TileType? {
        return plots[point] == nil ? nil : .plot
    }
    
    init( lines: [String] ) {
        var start: Point2D?
        let bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: lines[0].count, height: lines.count )!
        var plots = lines.indices.reduce(into: [ Point2D : Set<Point2D> ]() ) { neighbors, y in
            let characters = Array( lines[y] )
            characters.indices.forEach { x in
                if let tile = TileType( rawValue: characters[x] ) {
                    if tile == .plot { neighbors[ Point2D( x: x, y: y ) ] = Set() }
                } else {
                    guard characters[x] == "S" else {
                        fatalError( "Invalid character '\(characters[x])' in map." )
                    }
                    start = Point2D( x: x, y: y )
                    neighbors[ start! ] = Set()
                }
            }
        }
        
        func clip( point: Point2D ) -> Point2D {
            if point.x > bounds.max.x {
                return Point2D( x: point.x - bounds.max.x - 1 + bounds.min.x, y: point.y )
            } else if point.x < bounds.min.x {
                return Point2D( x: bounds.max.x + point.x + 1 - bounds.min.x, y: point.y )
            } else if point.y > bounds.max.y {
                return Point2D( x: point.x, y: point.y - bounds.max.y - 1 + bounds.min.y )
            } else if point.y < bounds.min.y {
                return Point2D( x: point.x, y: bounds.max.y + point.y + 1 - bounds.min.y )
            }
            return point
        }

        for plot in plots.keys {
            let neighbors = DirectionUDLR.allCases
                .map { plot + $0.vector }
                .filter {
                    if plots[$0] != nil { return true }
                    if bounds.contains( point: $0 ) { return false }
                    
                    let revised = clip( point: $0 )
                    return plots[revised] != nil
                }
            
            plots[plot] = Set( neighbors )
        }
        
        self.plots = plots
        self.bounds = bounds
        self.location = Point2D( x: 0, y: 0 )
        self.current = [start!]
        self.full = false
    }
    
    mutating func step() -> Set<Point2D> {
        var inside = Set<Point2D>()
        var outside = Set<Point2D>()

        for plot in current {
            for neighbor in plots[plot]! {
                if bounds.contains( point: neighbor ) {
                    inside.insert( neighbor )
                } else {
                    outside.insert( neighbor )
                }
            }
        }
        
        current = inside
        return outside
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
    
    for _ in 1 ... stepLimit {
        _ = map.step()
    }
    
    return "\( map.current.count )"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    let bigMap = InfinityMap( initial: map )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
