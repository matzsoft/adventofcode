//
//         FILE: main.swift
//  DESCRIPTION: day14 - Extended Polymerization
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/13/21 22:44:33
//

import Foundation

extension Array {
    var adjacentPairs: [ [ Element ] ] { ( 0 ..< count - 1 ).map { [ self[$0], self[$0+1] ] } }
}


struct Rule {
    let match: [Character]
    let replacement: [Character]
    
    init( line : String ) {
        let words = line.split( whereSeparator: { " ->".contains( $0 ) } )
        
        match = Array( words[0] )
        replacement = Array( words[1] )
    }
}


func polymerLength( start: Int, cycles: Int ) -> Int {
    return ( 1 ... cycles ).reduce( start ) { value, _ in 2 * value - 1 }
}


func parse( input: AOCinput ) -> ( [Character], [ [Character] : Rule ] ) {
    let template = Array( input.paragraphs[0][0] )
    let rules = input.paragraphs[1].map { Rule( line: $0 ) }.reduce( into: [ [Character] : Rule ]() ) {
        $0[$1.match] = $1
    }
    return ( template, rules )
}


func part1( input: AOCinput ) -> String {
    let ( template, rules ) = parse( input: input )
    let final = ( 1 ... 10 ).reduce( template ) { polymer, _ in
        let pairs = polymer.adjacentPairs
        return pairs.flatMap { [ $0[0] ] + rules[$0]!.replacement } + [ rules[ pairs.last! ]!.match.last! ]
    }
    let histogram = final.reduce( into: [ Character : Int ]() ) { $0[ $1, default: 0 ] += 1 }.sorted {
        $0.value < $1.value
    }
    return "\( histogram.last!.value - histogram.first!.value )"
}


func part2( input: AOCinput ) -> String {
    let ( template, rules ) = parse( input: input )
    var elementCounts = template.reduce( into: [ Character : Int ]() ) { $0[ $1, default: 0 ] += 1 }
    var trackPairs = template.adjacentPairs.reduce( into: [ [Character] : Int ]() ) {
        $0[ $1, default: 0 ] += 1
    }
    
    for _ in 1 ... 40 {
        trackPairs = trackPairs.reduce( into: [ [Character]: Int ]() ) {
            $0[ [ $1.key[0] ] + rules[$1.key]!.replacement, default: 0 ] += trackPairs[$1.key]!
            $0[ rules[$1.key]!.replacement + [ $1.key[1] ], default: 0 ] += trackPairs[$1.key]!
            elementCounts[ rules[$1.key]!.replacement[0], default: 0 ] += trackPairs[$1.key]!
        }
    }

    let histogram = elementCounts.sorted { $0.value < $1.value }
    return "\( histogram.last!.value - histogram.first!.value )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
