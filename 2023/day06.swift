//
//         FILE: day06.swift
//  DESCRIPTION: Advent of Code 2023 Day 6: Wait For It
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/05/23 21:00:02
//

import Foundation
import Library

struct Race {
    let time: Int
    let record: Int
    
    var wins: Int {
        ( 0 ... time ).filter { $0 * ( time - $0 ) > record }.count
    }
}

func part1( input: AOCinput ) -> String {
    let times = input.lines[0].split( whereSeparator: { ": ".contains( $0 ) } )[1...].map { Int( $0 )! }
    let records = input.lines[1].split( whereSeparator: { ": ".contains( $0 ) } )[1...].map { Int( $0 )! }
    let races = times.indices.map { Race( time: times[$0], record: records[$0] ) }
    return "\( races.map { $0.wins }.reduce( 1, * ) )"
}


func part2( input: AOCinput ) -> String {
    let time = Int( input.lines[0].split( whereSeparator: { ": ".contains( $0 ) } )[1...].joined() )!
    let record = Int( input.lines[1].split( whereSeparator: { ": ".contains( $0 ) } )[1...].joined() )!
    let race = Race( time: time, record: record )
    return "\( race.wins )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
