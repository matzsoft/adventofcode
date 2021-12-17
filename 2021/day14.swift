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
    var pairs: [ [ Element ] ] {
        return ( 0 ..< count - 1 ).map { [ self[$0], self[$0+1] ] }
    }
}

extension Sequence {
    var pairs: [ [ Element ] ] {
        let array = Array( self )
        return array.pairs
    }
}


struct Rule {
    let match: String
    let replacement: String
    
    init( line : String ) {
        let words = line.split( whereSeparator: { " ->".contains( $0 ) } )
        
        match = String( words[0] )
        replacement = String( match.first! ) + words[1]
    }
}


func polymerLength( start: Int, cycles: Int ) -> Int {
    return ( 1 ... cycles ).reduce( start ) { value, _ in 2 * value - 1 }
}


func parse( input: AOCinput ) -> ( String, [ String : Rule ] ) {
    let template = input.paragraphs[0][0]
    let rules = input.paragraphs[1].map { Rule( line: $0 ) }.reduce( into: [ String : Rule ]() ) {
        $0[$1.match] = $1
    }
    return ( template, rules )
}


func part1( input: AOCinput ) -> String {
    let ( template, rules ) = parse( input: input )
    let final = ( 1 ... 10 ).reduce( template ) { string, _ in
        let pairs = string.pairs
        return pairs.map { rules[ String( $0 ) ]!.replacement }.joined() + String( rules[ String( pairs.last! ) ]!.match.last! )
    }
    let histogram = final.reduce(into: [ Character : Int ]() ) { $0[ $1, default: 0 ] += 1 }.sorted {
        $0.value < $1.value
    }
    return "\( histogram.last!.value - histogram.first!.value )"
}


func part2( input: AOCinput ) -> String {
    let ( template, rules ) = parse( input: input )
    let final = ( 1 ... 20 ).reduce( template ) { string, _ in
        let pairs = string.pairs
        return pairs.map { rules[ String( $0 ) ]!.replacement }.joined() + String( rules[ String( pairs.last! ) ]!.match.last! )
    }
    let histogram = final.reduce(into: [ Character : Int ]() ) { $0[ $1, default: 0 ] += 1 }.sorted {
        $0.value < $1.value
    }
    let big = polymerLength( start: histogram.last!.value, cycles: 20 )
    let small = polymerLength( start: histogram.first!.value, cycles: 20 )
    return "\( big - small )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
