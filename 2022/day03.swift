//
//         FILE: main.swift
//  DESCRIPTION: day03 - Rucksack Reorganization
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/22 21:00:13
//

import Foundation
import Library


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { Array( $0 ).map {
        if ( "a" ... "z" ).contains( $0 ) { return Int( $0.asciiValue! - Character( "a" ).asciiValue! + 1 ) }
        return Int( $0.asciiValue! - Character( "A" ).asciiValue! + 27 )
    } }
}


func part1( input: AOCinput ) -> String {
    let rucksacks = parse( input: input )
    let sum = rucksacks.reduce( 0 ) { sum, rucksack -> Int in
        let middle = rucksack.count / 2
        let first = Set( rucksack[..<middle] )
        let second = Set( rucksack[middle...] )
        let culprit = first.intersection( second ).first!
        
        return sum + culprit
    }
    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let rucksacks = parse( input: input )
    let groups = stride( from: 0, to: rucksacks.count, by: 3 ).map { rucksacks[$0...$0+2] }
    let sum = groups.reduce( 0 ) { sum, group -> Int in
        let sets = group.map { Set( $0 ) }
        return sum + sets.reduce( sets[0] ) {  $0.intersection( $1 ) }.first!
    }
    return "\(sum)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
