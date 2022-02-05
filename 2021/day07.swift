//
//         FILE: main.swift
//  DESCRIPTION: day07 - The Treachery of Whales
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/21 21:40:21
//

import Foundation

func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let crabs = parse( input: input )
    let fuelUse = ( crabs.min()! ... crabs.max()! ).map { position in
        crabs.reduce( 0 ) { $0 + abs( $1 - position ) }
    }
    return "\( fuelUse.min()! )"
}


func part2( input: AOCinput ) -> String {
    let crabs = parse( input: input )
    let fuelUse = ( crabs.min()! ... crabs.max()! ).map { position in
        crabs.reduce( 0 ) { let delta = abs( $1 - position ); return $0 + ( delta * delta + delta ) / 2 }
    }
    return "\( fuelUse.min()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
