//
//         FILE: main.swift
//  DESCRIPTION: day14 - Regolith Reservoir
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/13/22 21:00:13
//

import Foundation

// Note - in order to use existing Direction8, treat gravity as pulling the sand North.
let directions: [Direction8] = [ .N, .NW, .NE ]
let drip = Point2D( x: 500, y: 0 )

extension Array {
    var pairs: [ ( Element, Element ) ] {
        return ( 0 ..< count - 1 ).map { ( self[$0], self[$0+1] ) }
    }
}


func line( from: Point2D, to: Point2D ) -> Set<Point2D> {
    if from.x == to.x {
        let start = min( from.y, to.y )
        let end = max( from.y, to.y )
        return ( start ... end ).reduce( into: Set<Point2D>() ) { set, y in
            set.insert( Point2D( x: from.x, y: y ) )
        }
    } else if from.y == to.y {
        let start = min( from.x, to.x )
        let end = max( from.x, to.x )
        return ( start ... end ).reduce( into: Set<Point2D>() ) { set, x in
            set.insert( Point2D( x: x, y: from.y ) )
        }
    }
    fatalError( "Can't do diagonal lines" )
}


func sandCount( blocks: Set<Point2D>, bounds: Rect2D, limit: Int? ) -> Int {
    var sand = Set<Point2D>()
    
    while true {
        var next = drip
        
        FALL:
        while true {
            if next.y == limit {
                sand.insert( next )
                break
            }
            for direction in directions {
                let trial = next.move( direction: direction )
                if limit == nil && !bounds.contains( point: trial ) { return sand.count }
                guard blocks.contains( trial ) || sand.contains( trial ) else {
                    next = trial
                    continue FALL
                }
            }
            
            sand.insert( next )
            if next == drip { return sand.count }
            break
        }
    }
}


func parse( input: AOCinput ) -> Set<Point2D> {
    let structures = input.lines.map {
        $0.split( whereSeparator: { " ->".contains( $0 ) } ).map { pair in
            let coordinates = pair.split( separator: "," ).map { Int( $0 )! }
            return Point2D( x: coordinates[0], y: coordinates[1] )
        }.pairs.map { line( from: $0.0, to: $0.1 ) }
    }
    return structures.flatMap { $0 }.reduce( Set<Point2D>() ) { $0.union( $1 ) }
}


func part1( input: AOCinput ) -> String {
    let blocks = parse( input: input )
    let bounds = Rect2D( points: Array( blocks ) ).expand( with: drip )

    return "\( sandCount( blocks: blocks, bounds: bounds, limit: nil ) )"
}


func part2( input: AOCinput ) -> String {
    let blocks = parse( input: input )
    let bounds = Rect2D( points: Array( blocks ) ).expand( with: drip )

    return "\( sandCount( blocks: blocks, bounds: bounds, limit: bounds.max.y + 1 ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
