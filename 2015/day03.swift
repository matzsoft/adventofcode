//
//         FILE: main.swift
//  DESCRIPTION: day03 - Perfectly Spherical Houses in a Vacuum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/03/21 20:59:22
//

import Foundation

extension Sequence {
    func pairs() -> AnyIterator<(Element, Element?)> {
        return AnyIterator( sequence( state: makeIterator(), next: { it in
            it.next().map { ( $0, it.next() ) }
        } ) )
    }
}


func parse( input: AOCinput ) -> [Direction4] {
    return input.line.compactMap { Direction4.fromArrows( char: String( $0 ) ) }
}


func part1( input: AOCinput ) -> String {
    let directions = parse( input: input )
    var position = Point2D( x: 0, y: 0 )
    var seen = Set( [ position ] )
    
    for direction in directions {
        position = position + direction.vector
        seen.insert( position )
    }
    
    return "\( seen.count )"
}


func part2( input: AOCinput ) -> String {
    let directions = parse( input: input )
    var santa = Point2D( x: 0, y: 0 )
    var robot = Point2D( x: 0, y: 0 )
    var seen = Set( [ santa ] )
    
    for ( santa_direction, robot_direction ) in directions.pairs() {
        santa = santa + santa_direction.vector
        seen.insert( santa )
        
        if let robot_direction = robot_direction {
            robot = robot + robot_direction.vector
            seen.insert( robot )
        }
    }
    
    return "\( seen.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
