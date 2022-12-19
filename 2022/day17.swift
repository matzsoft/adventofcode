//
//         FILE: main.swift
//  DESCRIPTION: day17 - Pyroclastic Flow
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/16/22 21:51:01
//

import Foundation

extension Rect2D {
    func contains( other: Rect2D ) -> Bool {
        contains( point: other.min ) && contains( point: other.max )
    }
}

struct Shape {
    let points: Set<Point2D>
    let bounds: Rect2D
    
    init( lines: [String] ) {
        let points = lines.enumerated().reduce( into: [Point2D]() ) { ( array, arg1 ) -> Void in
            let ( y, line ) = arg1
            for ( x, character ) in line.enumerated() {
                if character == "#" {
                    array.append( Point2D( x: x, y: lines.count - 1 - y ) )
                }
            }
        }
        
        self.points = Set( points )
        bounds = Rect2D( points: points )
    }
    
    init( points: [Point2D] ) {
        self.points = Set( points )
        bounds = Rect2D( points: points )
    }
    
    static func +( left: Shape, right: Point2D ) -> Shape {
        Shape( points: left.points.map { $0 + right } )
    }
}


func parse( input: AOCinput ) -> ( [Direction4], [Shape] ) {
    let directions = input.line.map { Direction4.fromArrows( char: String( $0 ) )! }
    let shapes = input.extras.split( separator: "", omittingEmptySubsequences: false )
        .map { $0.map { String( $0 ) } }.map { Shape( lines: $0 ) }

    return ( directions, shapes )
}


func part1( input: AOCinput ) -> String {
    let ( directions, shapes ) = parse( input: input )
    let chamber = Rect2D( min: Point2D( x: 0, y: 0 ), width: 7, height: Int.max / 7 )!
    var dropped = Set<Point2D>()
    let entry = Point2D( x: 2, y: 3 )
    var available = Point2D( x: 0, y: 0 )
    var time = 0
    
    for drop in 0 ..< 2022 {
        var shape = shapes[ drop % shapes.count ] + entry + available
        
        repeat {
            let blown = shape + directions[ time % directions.count ].vector
            time += 1
            if chamber.contains( other: blown.bounds ) && blown.points.isDisjoint( with: dropped ) {
                shape = blown
            }
            let down = shape + Direction4.south.vector
            if chamber.contains( other: down.bounds ) && down.points.isDisjoint( with: dropped ) {
                shape = down
            } else {
                dropped.formUnion( shape.points )
                available = Point2D( x: 0, y: max( available.y, shape.bounds.max.y + 1 ) )
                break
            }
        } while true
    }
    return "\(available.y)"
}


struct Cascade {
    let chamber: Rect2D
    let rocks: Set<Point2D>
    
    func isOpen( drop: Point2D, direction: Direction4, water: Set<Point2D> ) -> Bool {
        let next = drop.move( direction: direction )
        return chamber.contains( point: next ) && !rocks.contains( next ) && !water.contains( next )
    }
    
    func drop( _ drop: Point2D, water: Set<Point2D> ) -> Point2D {
        var drop = drop

        while isOpen( drop: drop, direction: .south, water: water ) {
            drop = drop.move( direction: Direction4.south )
        }
        
        if isOpen( drop: drop, direction: .west, water: water ) {
            while isOpen( drop: drop, direction: .west, water: water ) {
                drop = drop + Direction4.west.vector
                if isOpen( drop: drop, direction: .south, water: water ) {
                    return self.drop( drop + Direction4.south.vector, water: water )
                }
            }
            return drop
        }
        
        if isOpen( drop: drop, direction: .east, water: water ) {
            while isOpen( drop: drop, direction: .east, water: water ) {
                drop = drop + Direction4.east.vector
                if isOpen( drop: drop, direction: .south, water: water ) {
                    return self.drop( drop.move( direction: Direction4.south ), water: water )
                }
            }
            return drop
        }
        
        return drop
    }
}

func isAdjacent( point: Point2D, water: Set<Point2D> ) -> Bool {
    Direction4.allCases.contains { water.contains( point.move( direction: $0 ) ) }
}


// For debug purposes - no longer used
func chamberPrint( chamber: Rect2D, available: Point2D, rocks: Set<Point2D>, water: Set<Point2D> ) -> Void {
    for y in ( 0 ... available.y ).reversed() {
        var row = Array( repeating: ".", count: chamber.width )
        let rowRocks = rocks.filter { $0.y == y }
        let rowWater = water.filter { $0.y == y }
        
        rowRocks.forEach { row[$0.x] = "#" }
        rowWater.forEach { row[$0.x] = "~" }
        print( "|\(row.joined())|" )
        if rowRocks.isEmpty && rowWater.isEmpty { break }
    }
    print( "+\( String( repeating: "-", count: chamber.width ) )+" )
    print()
}


struct Status {
    let drop: Int
    let time: Int
    let available: Point2D
    let rocks: Set<Point2D>
    
    init( drop: Int, time: Int, available: Point2D, rocks: Set<Point2D>) {
        let minY = rocks.min( by: { $0.y < $1.y } )!.y
        
        self.drop = drop
        self.time = time
        self.available = available
        self.rocks = Set( rocks.map { Point2D( x: $0.x, y: $0.y - minY ) } )
    }
    
    func matches( other: Status, shapesCount: Int, directionsCount: Int ) -> Bool {
        guard drop % shapesCount == other.drop % shapesCount else { return false }
        guard time % directionsCount == other.time % directionsCount else { return false }
        return rocks == other.rocks
    }
}


func part2( input: AOCinput ) -> String {
    let ( directions, shapes ) = parse( input: input )
    let dropLimit = 1000000000000
    let chamber = Rect2D( min: Point2D( x: 0, y: 0 ), width: 7, height: Int.max / 7 )!
    var dropped = Set<Point2D>()
    let entry = Point2D( x: 2, y: 3 )
    var available = Point2D( x: 0, y: 0 )
    var drop = 0
    var time = 0
    var history = [Status]()
    var needCycle = true
    
    while drop < dropLimit {
        var shape = shapes[ drop % shapes.count ] + entry + available
        
        repeat {
            if needCycle && time % directions.count == 0 {
                let rocks = dropped.union( shape.points )
                let status = Status( drop: drop, time: time, available: available, rocks: rocks )
                if let match = history.first( where: {
                    status.matches(other: $0, shapesCount: shapes.count, directionsCount: directions.count )
                } ) {
                    let cycleSize = status.drop - match.drop
                    let cycleCount = ( dropLimit - drop ) / cycleSize
                    let heightDifference = cycleCount * ( status.available.y - match.available.y )
                    let heightVector = Point2D( x: 0, y: heightDifference )

                    drop += cycleCount * cycleSize
                    available = available + heightVector
                    shape = Shape( points: shape.points.map { $0 + heightVector } )
                    dropped = Set( dropped.map { $0 + heightVector } )
                    needCycle = false
                } else {
                    history.append( status )
                }
            }
            
            let blown = shape + directions[ time % directions.count ].vector
            time += 1
            if chamber.contains( other: blown.bounds ) && blown.points.isDisjoint( with: dropped ) {
                shape = blown
            }
            
            let down = shape + Direction4.south.vector
            if chamber.contains( other: down.bounds ) && down.points.isDisjoint( with: dropped ) {
                shape = down
            } else {
                available = Point2D( x: 0, y: max( available.y, shape.bounds.max.y + 1 ) )
                dropped.formUnion( shape.points )
                
                var water = Set<Point2D>()
                let cascade = Cascade( chamber: chamber, rocks: dropped )
                while true {
                    let drop = cascade.drop( available + Direction4.north.vector, water: water )
                    water.insert( drop )
                    if drop == available { break }
                }
                
                dropped = dropped.filter { isAdjacent( point: $0, water: water ) }
                break
            }
        } while true
        drop += 1
    }
    return "\(available.y)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
