//
//         FILE: main.swift
//  DESCRIPTION: day05 - Supply Stacks
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/22 21:00:11
//

import Foundation


func parse( input: AOCinput ) -> ( [[Character]], [[Int]] ) {
    let rawStacks = Array( input.paragraphs[0].dropLast().map {
        let chars = Array( $0 )
        return stride( from: 1, through: chars.count, by: 4 ).map { chars[$0] }
    }.reversed() )
    let stacks = ( 0 ..< rawStacks[0].count ).map { index in
        rawStacks.compactMap { $0[index] != " " ? $0[index] : nil }
    }
    let procedure = input.paragraphs[1].map {
        let numbers = $0.split( separator: " " ).compactMap { Int( $0 ) }
        return [ numbers[0], numbers[1] - 1, numbers[2] - 1 ]
    
    }
    return ( stacks, procedure )
}


func part1( input: AOCinput ) -> String {
    let ( startStacks, procedure ) = parse( input: input )
    var stacks = startStacks
    
    for step in procedure {
        stacks[ step[2] ].append( contentsOf: stacks[ step[1] ].suffix( step[0] ).reversed() )
        stacks[ step[1] ].removeLast( step[0] )
    }
    return "\(String( stacks.map { $0.last! } ))"
}


func part2( input: AOCinput ) -> String {
    let ( startStacks, procedure ) = parse( input: input )
    var stacks = startStacks

    for step in procedure {
        stacks[ step[2] ].append( contentsOf: stacks[ step[1] ].suffix( step[0] ) )
        stacks[ step[1] ].removeLast( step[0] )
    }
    return "\(String( stacks.map { $0.last! } ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
