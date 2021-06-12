//
//         FILE: main.swift
//  DESCRIPTION: day03 - No Matter How You Slice It
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/26/21 18:44:28
//

import Foundation

extension Rect2D {
    var setOfPoints: Set<Point2D> {
        return ( min.x ... max.x ).reduce( into: Set<Point2D>() ) { set, x  in
            ( min.y ... max.y ).forEach { set.insert( Point2D( x: x, y: $0 ) ) }
        }
    }
}


extension Array where Element == Rect2D {
    var overlaps: [Rect2D] {
        return ( 0 ..< count - 1 ).flatMap { i in
            ( i + 1 ..< count ).compactMap{ self[i].intersection( with: self[$0] ) }
        }
    }

    var setOfPoints: Set<Point2D> {
        reduce( into: Set<Point2D>() ) { $0.formUnion( $1.setOfPoints ) }
    }
}


func parse( input: AOCinput ) -> [ Int : Rect2D ] {
    return Dictionary( uniqueKeysWithValues: input.lines.map {
        let words = $0.split( whereSeparator: { "# @,:x".contains( $0 ) } ).map { Int($0)! }
        return (
            words[0],
            Rect2D( min: Point2D( x: words[1], y: words[2] ), width: words[3], height: words[4] )!
        )
    } )
}


func part1( input: AOCinput ) -> String {
    let claims = parse( input: input )
    let overlaps = Array<Rect2D>( claims.values ).overlaps
    return "\(overlaps.setOfPoints.count)"
}


func part2( input: AOCinput ) -> String {
    let claims = parse( input: input )
    let overlaps = Array<Rect2D>( claims.values ).overlaps
    let set = overlaps.setOfPoints
    let result = claims.keys.first { claims[$0]!.setOfPoints.intersection( set ).isEmpty }!

    return "\(result)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
