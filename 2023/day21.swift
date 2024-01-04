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

extension String {
    func center( within length: Int ) -> String {
        guard count < length else { return self }
        let prefix = String( repeating: " ", count: ( length - count ) / 2 )
        let suffix = String( repeating: " ", count: ( length - count + 1 ) / 2 )
        return prefix + self + suffix
    }
}


extension Point2D: CustomStringConvertible {
    public var description: String {
        "(\(x),\(y))"
    }
}


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
    let parentAge: Int
    var current: Set<Point2D>
    var history: [ Set<Point2D> : Int ]
    var cycle: Cycle?
    
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
    
    var statusDescription: String {
        [
            "\(location)",
            "\(startStep)(\(parentAge))",
            cycle == nil
                ? "No cycle"
                : "\(cycle!.startStep)(\(cycle!.relative))-\(cycle!.length)"
        ].joined( separator: "\n" )
    }
    
    subscript( point: Point2D ) -> TileType? {
        return plots[point] == nil ? nil : .plot
    }
    
    init( parent: Map, location: Point2D, current: Set<Point2D>, stepNumber: Int ) {
        self.plots = parent.plots
        self.bounds = parent.bounds
        self.location = location
        self.startStep = stepNumber
        self.parentAge = stepNumber - parent.startStep
        self.current = current
        self.history = [ current : stepNumber ]

//        print( "\(location) created at step \(stepNumber)" )
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
        self.parentAge = 0
        self.current = [start!]
        self.history = [ current : 0 ]

//        print( "\(location) created at step 0" )
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
//                print( "\(location) detected cycle at \(start), \(stepNumber) (\(cycle!.relative))" )
            }
        }

        return outside
    }
    
    mutating func overflow( _ overflow: Set<Point2D> ) -> Void {
        current.formUnion( overflow )
    }
}


struct QueueNode {
    let location: Point2D
    let parent: Point2D
    let overflow: Set<Point2D>
}


struct InfinityMap: CustomStringConvertible {
    var maps: [ Point2D : Map ]
    let plots: [ Point2D : Set<Point2D> ]
    let bounds: Rect2D
    var bigBounds: Rect2D
    var stepNumber: Int
    let stepLimit: Int
    
    init( initial: Map, stepLimit: Int ) {
        self.maps = [ initial.location : initial ]
        self.plots = initial.plots
        self.bounds = initial.bounds
        self.bigBounds = Rect2D( min: initial.location, max: initial.location )
        self.stepNumber = 0
        self.stepLimit = stepLimit
    }
    
    subscript( coords: ( Int, Int ) ) -> Map {
        maps[ Point2D( x: coords.0, y: coords.1 ) ]!
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
    
    var statusDescription: String {
        let layout = bigBounds.yRange.map { y in
            bigBounds.xRange.map { x in
                let location = Point2D( x: x, y: y )
                if maps[location] == nil {
                    return Array( repeating: " ", count: 3 )
                }
                return maps[location]!.statusDescription.split( separator: "\n" ).map { String( $0 ) }
            }
        }
        let maxWidth = layout.flatMap { $0.flatMap { $0.map { $0.count } } }.max()!
        let level2 = layout
            .map { bigrow in
                bigrow[0].indices.map { index in
                    bigrow.map {
                        $0[index].center( within: maxWidth )
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

    mutating func advanceTo( extent: Int ) -> Bool {
        repeat {
            step()
            guard stepNumber < stepLimit else { return false }
        } while bigBounds.max.x < extent
        return true
    }
    
    mutating func advanceTo( stepTarget: Int ) -> Bool {
        repeat {
            step()
            guard stepNumber < stepLimit else { return false }
        } while stepNumber < stepTarget
        return true
    }
    
    mutating func step() -> Void {
        var queue = [QueueNode]()
        
        stepNumber += 1
        for location in maps.keys {
            let escaped = maps[location]!.step( stepNumber: stepNumber )

            for direction in DirectionUDLR.allCases {
                let neighbor = location + direction.vector
                let overflows = escaped
                    .filter { bounds.contains( point: $0 - direction.vector ) }
                    .map { clip( point: $0 ) }
                
                if !overflows.isEmpty {
                    queue.append(
                        QueueNode( location: neighbor, parent: location, overflow: Set( overflows ) )
                    )
                }
            }
        }
        
        for node in queue {
            if maps[node.location] == nil {
                add( node: node, stepNumber: stepNumber )
            } else {
                maps[node.location]!.overflow( node.overflow )
            }
        }
    }

    mutating func add( node: QueueNode, stepNumber: Int ) -> Void {
        maps[node.location] = Map(
            parent: maps[node.parent]!, location: node.location,
            current: node.overflow, stepNumber: stepNumber
        )
        bigBounds = bigBounds.expand( with: node.location )
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
//    let stepLimit = 1000
    let stepLimit = Int( input.extras[1] )!
    var bigMap = InfinityMap( initial: map, stepLimit: stepLimit )
    
//    print( "At step 0" )
//    print( "\(bigMap)" )
    
    if stepLimit < 10000 {
//        _ = bigMap.advanceTo( stepTarget: stepLimit )
        return "\(bigMap.reachedCount)"
//    } else {
//        _ = bigMap.advanceTo( extent: 8 )
//        print( "Step number \(bigMap.stepNumber)" )
//        print( bigMap.statusDescription )
//        exit(0)
    }

    guard bigMap.advanceTo( extent: 2 ) else { return "\(bigMap.reachedCount)" }
    
    let point1 = Point2D( x: 1, y: 0 )
    let point2 = Point2D( x: 2, y: 0 )
    let period1 = bigMap.maps[point1]!.parentAge
    let period2 = bigMap.maps[point2]!.parentAge
    let maxExtent = ( stepLimit + period2 - period1 ) / period2
    let extraSteps = ( stepLimit + period2 - period1 ) % period2
    let cycle = bigMap.maps[map.location]!.cycle!.states.map { $0.count }

    guard bigMap.advanceTo( stepTarget: bigMap.stepNumber + extraSteps ) else {
        return "\(bigMap.reachedCount)" }
    
    let outerLayer = maxExtent * [ (1,2), (1,-2), (-1,2), (-1,-2) ]
        .map { bigMap[$0].current.count }
        .reduce( 0, + )
    let innerLayer = ( maxExtent - 1 ) * [ (1,1), (1,-1), (-1,1), (-1,-1) ]
        .map { bigMap[$0].current.count }
        .reduce( 0, + )
    let corners = [ (2,0), (0,2), (-2,0), (0,-2) ] .map { bigMap[$0].current.count }.reduce( 0, + )
    let likeOrigin
        = maxExtent.isMultiple( of: 2 ) ? ( maxExtent - 1 ) * ( maxExtent - 1 ) : maxExtent * maxExtent
    let unlikeOrigin
        = maxExtent.isMultiple( of: 2 ) ? maxExtent * maxExtent : ( maxExtent - 1 ) * ( maxExtent - 1 )
    let gargon = ( stepLimit - 129 ) % 2
    let pizza = ( stepLimit - 130 ) % 2
    let total = likeOrigin * cycle[gargon] + unlikeOrigin * cycle[pizza] + innerLayer + outerLayer + corners

//    let poi = [
//        [ (2,0), (0,2), (-2,0), (0,-2) ],
//        [ (1,1), (1,-1), (-1,1), (-1,-1) ],
//        [ (1,2), (1,-2), (-1,2), (-1,-2) ],
//        [ (2,1), (2,-1), (-2,1), (-2,-1) ],
//    ].map { $0.map { Point2D( x: $0.0, y: $0.1 ) } }
//    for list in poi {
//        for index1 in 1 ..< list.count {
//            for index2 in 0 ..< index1 {
//                let current1 = bigMap.maps[list[index1]]!.current
//                let current2 = bigMap.maps[list[index2]]!.current
//                let header = "\(list[index1]) and \(list[index2]) "
//                if current1 == current2 {
//                    print( "\(header) match (\(current1.count))." )
//                } else {
//                    print( "\(header) don't match (\(current1.count), \(current2.count))." )
//                }
//            }
//        }
//        print()
//    }

//    print( bigMap.statusDescription )
//        if stepCount == 10 {
//            print( "At step \(stepCount)" )
//            print( "\(bigMap)" )
//        }
                
//        if stepCount > 16 {
//            print( "At step \(stepCount)" )
//            print( "\(bigMap)" )
//        }
        
//        if stepCount == 589 {
//            let center = likeOrigin * bigMap.maps[map.location]!.cycle!.states[gargon].count
//            let others = unlikeOrigin * bigMap.maps[map.location]!.cycle!.states[pizza].count
//            print( "\(center) + \(others) = \( center + others )" )
//            
//            let poi = [
//                [ (4,1), (3,2), (2,3) ],
//                [ (4,-1), (3,-2), (2,-3) ],
//                [ (-4,1), (-3,2), (-2,3) ],
//                [ (-4,-1), (-3,-2), (-2,-3) ],
//                [ (3,1), (2,2), (1,3) ],
//                [ (3,-1), (2,-2), (1,-3) ],
//                [ (-3,1), (-2,2), (-1,3) ],
//                [ (-3,-1), (-2,-2), (-1,-3) ],
//                [ (4,0), (0,4), (-4,0), (0,-4) ],
//            ].map { $0.map { Point2D( x: $0.0, y: $0.1 ) } }
//            for list in poi {
//                for index1 in 1 ..< list.count {
//                    for index2 in 0 ..< index1 {
//                        let current1 = bigMap.maps[list[index1]]!.current
//                        let current2 = bigMap.maps[list[index2]]!.current
//                        let header = "\(list[index1]) and \(list[index2]) "
//                        if current1 == current2 {
//                            print( "\(header) match (\(current1.count))." )
//                        } else {
//                            print( "\(header) don't match (\(current1.count), \(current2.count))." )
//                        }
//                    }
//                }
//                print()
//            }
//            print( bigMap.statusDescription )
//            return "\(stepCount)"
//        }
    
//    let cycles = bigMap.maps.filter { $0.value.cycle != nil }.map { $0.value.cycle! }
//    print( "At step \(stepLimit)" )
//    print( "There are \( bigMap.maps.count) small maps." )
//    print( "\( cycles.count ) of them have cycles." )
//    print( "Cycle \(cycles[0].location) has \(cycles[0].states.count) states with counts:" )
//    print( "   \( cycles[0].states.map { $0.count } )" )
//    print( bigMap.maps[ Point2D( x: 0, y: 0 ) ]!.statusDescription )
//    for otherCycle in cycles[1...] {
//        if cycles[0].states != otherCycle.states {
//            if cycles[0].states[0] == otherCycle.states[1] && cycles[0].states[1] == otherCycle.states[0] {
//                print( "Cycle \(otherCycle.location) is reversed from cycle \(cycles[0].location)" )
//            } else {
//                print( "Cycle \(otherCycle.location) is different from cycle \(cycles[0].location)" )
//            }
//        }
//    }
//    print( "\( bigMap.maps[ Point2D( x: 0, y: 0 ) ]! )" )
//    print()
//    print( bigMap.statusDescription )
//    return "\(bigMap.reachedCount)"
    
    return "\(total)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
