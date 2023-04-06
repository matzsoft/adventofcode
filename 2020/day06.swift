//
//         FILE: main.swift
//  DESCRIPTION: day06 - Custom Customs
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/24/21 12:35:36
//

import Foundation
import Library

struct Group {
    let people: [Set<String.Element>]

    init( lines: [String] ) {
        people = lines.map { $0.map { $0 } }.map { Set( $0 ) }
    }
}


func parse( input: AOCinput ) -> [Group] {
    return input.paragraphs.map { Group( lines: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let groups = parse( input: input )
    let anyone = groups.map { $0.people.reduce( $0.people[0] ) { $0.union( $1 ) }.count }
    return "\( anyone.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let groups = parse( input: input )
    let everyone = groups.map { $0.people.reduce( $0.people[0] ) { $0.intersection( $1 ) }.count }
    return "\( everyone.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
