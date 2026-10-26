//
//         FILE: day09.swift
//  DESCRIPTION: Advent of Code 2023 Day 9: Mirage Maintenance
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/08/23 21:00:02
//

import Foundation
import Library

func find( input: AOCinput, update: ( Int, [Int] ) -> Int ) -> Int {
    input.lines
        .map {
            var pyramid = [ $0.split( separator: " " ).map { Int( $0 )! } ]

            while pyramid.last!.contains( where: { $0 != 0 } ) {
                let row = pyramid.last!
                pyramid.append( ( 0 ..< row.count - 1 ).map { row[ $0 + 1 ] - row[$0] } )
            }

            return ( 1 ..< pyramid.count ).reversed().reduce( 0 ) { update( $0, pyramid[ $1 - 1 ] ) }
        }
        .reduce( 0, + )
}


func part1( input: AOCinput ) -> String {
    return "\( find( input: input, update: { $1.last! + $0 } ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( find( input: input, update: { $1[0] - $0 } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
