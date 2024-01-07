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

extension Int {
    func floorDiv( _ d: Int ) -> Int {
        Int( floor( Double( self ) / Double( d ) ) )
    }
}


enum TileType: Character { case plot = ".", rock = "#" }

struct Map: CustomStringConvertible {
    let plots: [ Point2D : Set<Point2D> ]
    let bounds: Rect2D
    var current: Set<Point2D>
    
    var description: String {
        bounds.yRange.map { y in
            bounds.xRange.map { x in
                let point = Point2D( x: x, y: y )
                if plots[point] == nil { return "#" }
                if current.contains( point ) { return "O" }
                return "."
            }.joined()
        }.joined( separator: "\n" )
    }
    
    init( lines: [String] ) {
        var start: Point2D?
        let bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: lines[0].count, height: lines.count )!
        var plots = lines.indices.reduce( into: [ Point2D : Set<Point2D> ]() ) { neighbors, y in
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
        self.current = [start!]
    }
    
    mutating func step( stepNumber: Int ) -> Void {
        var inside = Set<Point2D>()

        for plot in current {
            for neighbor in plots[plot]! {
                if bounds.contains( point: neighbor ) {
                    inside.insert( neighbor )
                }
            }
        }
        
        current = inside
    }
}


struct InfinityMap: CustomStringConvertible {
    var map: Map
    var bounds: Rect2D
    var current: Set<Point2D>
    var stepNumber: Int
    let stepLimit: Int
    
    init( initial: Map, stepLimit: Int ) {
        self.map = initial
        self.bounds = Rect2D( points: Array( initial.current ) )
        self.current = initial.current
        self.stepNumber = 0
        self.stepLimit = stepLimit
    }
        
    var description: String {
        bounds.yRange.map { y in
            bounds.xRange.map { x in
                let location = Point2D( x: x, y: y )
                if current.contains( location ) { return "O" }
                if map.current.contains( location ) { return "S" }
                let base = Point2D(
                    x: location.x.floorDiv( map.bounds.width ) * map.bounds.width,
                    y: location.y.floorDiv( map.bounds.height ) * map.bounds.height
                )
                let relative = location - base
                return map.plots[relative] != nil ? "." : "#"
            }.joined()
        }.joined( separator: "\n" )
    }
    
    mutating func step() -> Void {
        var next = Set<Point2D>()

        stepNumber += 1
        for plot in current {
            let base = Point2D(
                x: plot.x.floorDiv( map.bounds.width ) * map.bounds.width,
                y: plot.y.floorDiv( map.bounds.height ) * map.bounds.height
            )
            let relative = plot - base
            for neighbor in map.plots[relative]! {
                next.insert( base + neighbor )
                bounds = bounds.expand( with: base + neighbor )
            }
        }
        
        current = next
    }

    mutating func advanceTo( stepTarget: Int ) -> Bool {
        repeat {
            step()
            guard stepNumber < stepLimit else { return false }
        } while stepNumber < stepTarget
        return true
    }
    
    mutating func advanceBy( steps: Int ) -> Bool {
        advanceTo( stepTarget: stepNumber + steps )
    }
}


func part1( input: AOCinput ) -> String {
    var map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    
    for stepNumber in 1 ... stepLimit {
        map.step( stepNumber: stepNumber )
    }
    
    return "\( map.current.count )"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[1] )!
    var bigMap = InfinityMap( initial: map, stepLimit: stepLimit )
    let period = map.bounds.width
    let extent = stepLimit / period
    let extras = stepLimit % period
    
    guard bigMap.advanceBy( steps: extras ) else { return "\(bigMap.current.count)" }
    let y0 = bigMap.current.count
    
    guard bigMap.advanceBy( steps: period ) else { return "\(bigMap.current.count)" }
    let y1 = bigMap.current.count

    guard bigMap.advanceBy(steps: period ) else { return "\(bigMap.current.count)" }
    let y2 = bigMap.current.count

    let n = extent
    // a+n*(b-a+(n-1)*(c-b-b+a)//2)
    let it = y0 + n * ( y1 - y0 + ( n - 1 ) * ( y2 - y1 - y1 + y0 ) / 2 )
    return "\(it)"
}


try print( projectInfo() )
try runTests( part1: part1 )
//try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
