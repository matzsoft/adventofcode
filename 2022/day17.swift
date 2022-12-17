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
                available = Point2D( x: 0, y: dropped.map { $0.y }.max()! + 1 )
                break
            }
        } while true
    }
    return "\(available.y)"
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
