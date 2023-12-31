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

struct Cycle {
    let location: Point2D
    let startStep: Int
    let relative: Int
    let length: Int
    let states: [ Set<Point2D> ]
}


enum TileType: Character { case plot = ".", rock = "#" }

struct Map: CustomStringConvertible {
    let plots: [ Point2D : Set<Point2D> ]
    let bounds: Rect2D
    let location: Point2D
    let startStep: Int
    var current: Set<Point2D>
    var history: [ Set<Point2D> : Int ]
    var cycle: Cycle?
    
    var isFull: Bool { plots.count == current.count }
    
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
    
    subscript( point: Point2D ) -> TileType? {
        return plots[point] == nil ? nil : .plot
    }
    
    init(
        plots: [Point2D : Set<Point2D>], bounds: Rect2D, location: Point2D,
        current: Set<Point2D>, stepNumber: Int
    ) {
        self.plots = plots
        self.bounds = bounds
        self.location = location
        self.startStep = stepNumber
        self.current = current
        self.history = [ current : stepNumber ]

        print( "\(location) created at step \(stepNumber)" )
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
        self.location = Point2D( x: 0, y: 0 )
        self.startStep = 0
        self.current = [start!]
        self.history = [ current : 0 ]

        print( "\(location) created at step 0" )
    }
    
    mutating func step( stepNumber: Int ) -> Set<Point2D> {
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
        if let cycle = cycle {
            if current != cycle.states[ ( stepNumber - cycle.startStep ) % cycle.length ] {
                print( "\(location) broken cycle at \(stepNumber)" )
            }
        } else {
            if history[current] == nil {
                history[current] =  stepNumber
            } else if let start = history[current] {
                let states = ( start ..< stepNumber ).map { step in
                    history.first( where: { $0.value == step } )!.key
                }
                cycle = Cycle(
                    location: location, startStep: start, relative: start - startStep,
                    length: stepNumber - start, states: states
                )
                print( "\(location) detected cycle at \(start), \(stepNumber) (\(cycle!.relative))" )
            }
        }

        return outside
    }
    
    mutating func overflow( _ overflow: Set<Point2D> ) -> Void {
        current.formUnion( overflow )
    }
}


struct QueueNode {
    let smallMap: Point2D
    let overflow: Set<Point2D>
}


struct InfinityMap: CustomStringConvertible {
    var maps: [ Point2D : Map ]
    let plots: [ Point2D : Set<Point2D> ]
    let bounds: Rect2D
    var bigBounds: Rect2D
    
    init( initial: Map ) {
        maps = [ initial.location : initial ]
        plots = initial.plots
        bounds = initial.bounds
        bigBounds = Rect2D( min: initial.location, max: initial.location )
    }
    
    var description: String {
        let layout = bigBounds.yRange.map { y in
            bigBounds.xRange.map { x in
                let location = Point2D( x: x, y: y )
                if maps[location] == nil {
                    return Array(
                        repeating: String( repeating: " ", count: bounds.width ), count: bounds.height
                    )
                }
                return maps[location]!.description.split( separator: "\n" ).map { String( $0 ) }
            }
        }
        let level2 = layout
            .map { bigrow in
                bigrow[0].indices.map { index in
                    bigrow.map {
                        $0[index]
                    }.joined(separator: " " )
                }.joined( separator: "\n" )
            }.joined( separator: "\n\n" )
        
        return level2
    }
    
    var reachedCount: Int {
        maps.values.reduce( 0 ) { $0 + $1.current.count }
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

    mutating func steo( stepNumber: Int ) -> Void {
        var queue = [QueueNode]()
        
        for location in maps.keys {
            let escaped = maps[location]!.step( stepNumber: stepNumber )

            for direction in DirectionUDLR.allCases {
                let neighbor = location + direction.vector
                let overflows = escaped
                    .filter { bounds.contains( point: $0 - direction.vector ) }
                    .map { clip( point: $0 ) }
                
                if !overflows.isEmpty {
                    queue.append( QueueNode( smallMap: neighbor, overflow: Set( overflows ) ) )
                }
            }
        }
        
        for node in queue {
            if maps[node.smallMap] == nil {
                add( location: node.smallMap, starting: node.overflow, stepNumber: stepNumber )
            } else {
                maps[node.smallMap]!.overflow( node.overflow )
            }
        }
    }

    mutating func add( location: Point2D, starting: Set<Point2D>, stepNumber: Int ) -> Void {
        maps[location] = Map(
            plots: plots, bounds: bounds, location: location, current: starting, stepNumber: stepNumber
        )
        bigBounds = bigBounds.expand( with: location )
    }
}


func part1( input: AOCinput ) -> String {
    var map = Map( lines: input.lines )
    let stepLimit = Int( input.extras[0] )!
    
    for stepNumber in 1 ... stepLimit {
        _ = map.step( stepNumber: stepNumber )
    }
    
    return "\( map.current.count )"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    let stepLimit = 1000
//    let stepLimit = Int( input.extras[1] )!
    var bigMap = InfinityMap( initial: map )
    
//    print( "At step 0" )
//    print( "\(bigMap)" )
    
    for stepCount in 1 ... stepLimit {
        bigMap.steo( stepNumber: stepCount )
        
//        if stepCount == 10 {
//            print( "At step \(stepCount)" )
//            print( "\(bigMap)" )
//        }
                
//        if stepCount > 16 {
//            print( "At step \(stepCount)" )
//            print( "\(bigMap)" )
//        }
        
//        if bigMap.maps[ Point2D( x: 0, y: 0 ) ]!.isStable {
//            print( "At step \(stepCount)" )
//            print( "\( bigMap.maps[ Point2D( x: 0, y: 0 ) ]! )" )
//            return "\(bigMap.reachedCount)"
//        }
        
//        if bigMap.maps.count > 9 {
//            return "\(stepCount)"
//        }
    }
    
    let cycles = bigMap.maps.filter { $0.value.cycle != nil }.map { $0.value.cycle! }
    print( "At step \(stepLimit)" )
    print( "There are \( bigMap.maps.count) small maps." )
    print( "\( cycles.count ) of them have cycles." )
    print( "Cycle \(cycles[0].location) has \(cycles[0].states.count) states with counts:" )
    print( "   \( cycles[0].states.map { $0.count } )" )
    for otherCycle in cycles[1...] {
        if cycles[0].states != otherCycle.states {
            print( "Cycle \(otherCycle.location) is different from cycle \(cycles[0].location)" )
        }
    }
//    print( "\( bigMap.maps[ Point2D( x: 0, y: 0 ) ]! )" )
    return "\(bigMap.reachedCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
//try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
