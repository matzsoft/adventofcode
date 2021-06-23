//
//         FILE: main.swift
//  DESCRIPTION: day11 - Hex Ed
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/19/21 13:27:53
//

import Foundation


func parse( input: AOCinput ) -> [Direction6] {
    return input.line.split( separator: "," ).map { Direction6( rawValue: String( $0 ) )! }
}


func part1( input: AOCinput ) -> String {
    let directions = parse( input: input )
    let position = directions.reduce( Point2D( x: 0, y: 0 ) ) { $0 + $1.vector }
    return "\(position.hexDistance( other: Point2D( x: 0, y: 0 ) ))"
}


func part2( input: AOCinput ) -> String {
    let directions = parse( input: input )
    var position = Point2D( x: 0, y: 0 )
    let positions = directions.map { ( direction ) -> Point2D in
        position = position + direction.vector; return position
    }
    let farthest = positions.max {
        $0.hexDistance( other: Point2D( x: 0, y: 0 ) ) < $1.hexDistance( other: Point2D( x: 0, y: 0 ) )
    }!
    return "\(farthest.hexDistance( other: Point2D( x: 0, y: 0 ) ))"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
