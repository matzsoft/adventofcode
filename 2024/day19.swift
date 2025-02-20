//
//         FILE: day19.swift
//  DESCRIPTION: Advent of Code 2024 Day 19: Linen Layout
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/18/24 21:49:32
//

import Foundation
import Library


func parse( input: AOCinput ) -> ( Set<String>, [String] ) {
    let fields = input.paragraphs[0][0]
        .split( whereSeparator: { ", ".contains( $0 ) } )
        .map { String( $0 ) }
    return ( Set( fields ), input.paragraphs[1] )
}


func isPossible( design: String, towels: Set<String> ) -> Bool {
    if design.isEmpty { return true }
    
    for prefixLength in 1 ... design.count {
        let prefix = String( design.prefix( prefixLength ) )
        
        if towels.contains( prefix ) {
            let suffix = String( design.dropFirst( prefixLength ) )
            if isPossible( design: suffix, towels: towels ) { return true }
        }
    }
    
    return false
}


var cache = [ "" : 1 ]

func possibleCount2( design: String, towels: Set<String> ) -> Int {
    if let possibles = cache[ design ] { return possibles }
    
    let starts = towels.filter { design.hasPrefix( $0 ) }
    let total = starts.reduce( 0 ) { total, towel in
        let suffix = String( design.dropFirst( towel.count ) )
        return total + possibleCount2( design: suffix, towels: towels )
    }
    
    cache[design] = total
    return total
}


func part1( input: AOCinput ) -> String {
    let ( towels, designs ) = parse( input: input )
    let valid = designs.filter { isPossible( design: $0, towels: towels ) }
    return "\(valid.count)"
}


func part2( input: AOCinput ) -> String {
    cache = [ "" : 1 ]

    let ( towels, designs ) = parse( input: input )
    let total = designs.reduce( 0 ) {
        $0 + possibleCount2( design: $1, towels: towels )
    }
    return "\(total)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
