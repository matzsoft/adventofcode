//
//         FILE: day05.swift
//  DESCRIPTION: Advent of Code 2023 Day 5: If You Give A Seed A Fertilizer
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/23 21:01:41
//

import Foundation
import Library

struct SourceRange {
    let range: Range<Int>
    let addend: Int
    
    init( line: String ) {
        let numbers = line.split( separator: " " ).map { Int( $0 )! }
        range = numbers[1] ..< ( numbers[1] + numbers[2] )
        addend = numbers[0] - numbers[1]
    }
}

struct Map {
    let source: String
    let destination: String
    let ranges: [SourceRange]
    
    init( lines: [String] ) {
        let header = lines[0].split( whereSeparator: { "- ".contains( $0 ) } )
        source = String( header[0] )
        destination = String( header[2] )
        ranges = lines[1...]
            .map { SourceRange( line: $0 ) }
            .sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
}


func parse( input: AOCinput ) -> ( [Int], [ String : Map ] ) {
    let seeds = input.line.split( separator: " " )[1...].map { Int( $0 )! }
    let maps = input.paragraphs[1...].reduce( into: [ String : Map ]() ) { maps, lines in
        let map = Map( lines: lines )
        maps[ map.source ] = map
    }
    return ( seeds, maps )
}


func locationFor( seed: Int, maps: [ String: Map ] ) -> Int {
    var current = "seed"
    var value = seed
    
    while let map = maps[current] {
        if let range = map.ranges.first( where: { $0.range.contains( value ) } ) {
            value += range.addend
        }
        current = map.destination
    }
    
    return value
}


func part1( input: AOCinput ) -> String {
    let ( seeds, maps ) = parse( input: input )
    let locations = seeds.reduce( into: [ Int : Int ]() ) { $0[$1] = locationFor( seed: $1, maps: maps ) }
    
    return "\( locations.min( by: { $0.value < $1.value } )!.value )"
}


func part2( input: AOCinput ) -> String {
    let ( seeds, maps ) = parse( input: input )
    var minLocation = Int.max
    
    for index in stride(from: 0, to: seeds.count, by: 2 ) {
        for seed in seeds[index] ..< ( seeds[index] + seeds[index+1] ) {
            minLocation = min( minLocation, locationFor( seed: seed, maps: maps ) )
        }
    }
    
//    let total = stride( from: 1, to: seeds.count, by: 2 ).reduce( 0, { $0 + seeds[$1] } )
    return "\(minLocation)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
