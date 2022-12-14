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

extension Array {
    var pairs: [ ( Element, Element ) ] {
        return ( 0 ..< count - 1 ).map { ( self[$0], self[$0+1] ) }
    }
}


func django( first: Point2D, second: Point2D ) -> Set<Point2D> {
    if first.x == second.x {
        let start = min( first.y, second.y )
        let end = max( first.y, second.y )
        return ( start ... end ).reduce( into: Set<Point2D>() ) { set, y in
            set.insert( Point2D( x: first.x, y: y ) )
        }
    } else if first.y == second.y {
        let start = min( first.x, second.x )
        let end = max( first.x, second.x )
        return ( start ... end ).reduce( into: Set<Point2D>() ) { set, x in
            set.insert( Point2D( x: x, y: first.y ) )
        }
    }
    fatalError( "Can't do diagonal lines" )
}


func parse( input: AOCinput ) -> Set<Point2D> {
    let structures = input.lines.map {
        $0.split( whereSeparator: { " ->".contains( $0 ) } ).map { pair in
            let coordinates = pair.split( separator: "," ).map { Int( $0 )! }
            return Point2D( x: coordinates[0], y: coordinates[1] )
        }.pairs.map { django( first: $0.0, second: $0.1 ) }
    }
    return structures.flatMap { $0 }.reduce( Set<Point2D>() ) { $0.union( $1 ) }
}


// Note - in order to use existing Direction8, treat gravity as pulling the sand North.
func part1( input: AOCinput ) -> String {
    let blocks = parse( input: input )
    let drip = Point2D( x: 500, y: 0 )
    let bounds = Rect2D( points: Array( blocks ) ).expand( with: drip )
    var sand = Set<Point2D>()
    
    while true {
        var next = drip
        
        while true {
            var trial = next.move( direction: Direction8.N )
            if !bounds.contains( point: trial ) { return "\(sand.count)" }
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            trial = next.move( direction: Direction8.NW )
            if !bounds.contains( point: trial ) { return "\(sand.count)" }
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            trial = next.move( direction: Direction8.NE )
            if !bounds.contains( point: trial ) { return "\(sand.count)" }
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            sand.insert( next )
            break
        }
    }
}


func part2( input: AOCinput ) -> String {
    let blocks = parse( input: input )
    let drip = Point2D( x: 500, y: 0 )
    let bounds = Rect2D( points: Array( blocks ) ).expand( with: drip )
    let limit = bounds.max.y + 1
    var sand = Set<Point2D>()
    
    while true {
        var next = drip
        
        while true {
            if next.y == limit {
                sand.insert( next )
                break
            }
            var trial = next.move( direction: Direction8.N )
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            trial = next.move( direction: Direction8.NW )
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            trial = next.move( direction: Direction8.NE )
            guard blocks.contains( trial ) || sand.contains( trial ) else {
                next = trial
                continue
            }
            
            sand.insert( next )
            if next == drip { return "\(sand.count)" }
            break
        }
    }
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
