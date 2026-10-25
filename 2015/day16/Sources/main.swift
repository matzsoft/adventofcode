//
//         FILE: main.swift
//  DESCRIPTION: day16 - Aunt Sue
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/08/21 20:02:14
//

import Foundation
import Library

let MFCSAM = [
    "children":    3,
    "cats":        7,
    "samoyeds":    2,
    "pomeranians": 3,
    "akitas":      0,
    "vizslas":     0,
    "goldfish":    5,
    "trees":       3,
    "cars":        2,
    "perfumes":    1,
]

struct AuntSue {
    let number: Int
    let attributes: [ String : Int ]
    
    init( line: String ) {
        let words = line.split { ": ,".contains( $0 ) }
        
        number = Int( words[1] )!
        attributes = stride( from: 2, to: words.count, by: 2 ).reduce(into: [ String : Int ]() ) {
            dict, index in
            dict[ String( words[index] ) ] = Int( words[ index + 1 ] )!
        }
    }
}


func parse( input: AOCinput ) -> [AuntSue] {
    return input.lines.map { AuntSue( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let aunties = parse( input: input )
    let aunt = aunties.first { $0.attributes.allSatisfy { $0.value == MFCSAM[$0.key] } }!
    
    return "\( aunt.number )"
}


func part2( input: AOCinput ) -> String {
    let aunties = parse( input: input )
    let aunt = aunties.first { $0.attributes.allSatisfy {
        switch $0.key {
        case "cats", "trees":
            return $0.value > MFCSAM[$0.key]!
        case "pomeranians", "goldfish":
            return $0.value < MFCSAM[$0.key]!
        default:
            return $0.value == MFCSAM[$0.key]
        }
    } }!
    
    return "\( aunt.number )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
