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

extension Range<Int> {
    func offset( by offset: Int ) -> Range<Int> {
        ( lowerBound + offset ) ..< ( upperBound + offset )
    }
    
    func subtracting( other: Range<Int> ) -> Range<Int> {
        let clamped = clamped( to: other )
        return clamped.upperBound ..< upperBound
    }
}

struct SourceRange {
    let range: Range<Int>
    let addend: Int
    
    var lowerBound: Int { range.lowerBound }
    var upperBound: Int { range.upperBound }
    
    init( _ range: Range<Int>, addend: Int ) {
        self.range = range
        self.addend = addend
    }
    
    init( line: String ) {
        let numbers = line.split( separator: " " ).map { Int( $0 )! }
        range = numbers[1] ..< ( numbers[1] + numbers[2] )
        addend = numbers[0] - numbers[1]
    }
    
    func clamped( to other: Range<Int> ) -> SourceRange {
        SourceRange( range.clamped( to: other ), addend: addend )
    }
    
    func offset( by offset: Int ) -> SourceRange {
        SourceRange( range.offset( by: offset ), addend: addend )
    }
    
    func blend( with others: [SourceRange] ) -> [SourceRange] {
        var last = lowerBound
        var newRanges = [SourceRange]()
        
        for other in others {
            if last < other.lowerBound {
                newRanges.append( SourceRange( last ..< other.lowerBound, addend: addend ) )
            }
            newRanges.append( SourceRange( other.range, addend: addend + other.addend ) )
            last = other.upperBound
        }
        if last < upperBound {
            newRanges.append( SourceRange( last ..< upperBound, addend: addend ) )
        }
        
        return newRanges
    }
}

struct Map {
    let source: String
    let destination: String
    let ranges: [SourceRange]
    
    init( source: String, destination: String, ranges: [SourceRange] ) {
        self.source = source
        self.destination = destination
        self.ranges = ranges
    }
    
    init( lines: [String] ) {
        let header = lines[0].split( whereSeparator: { "- ".contains( $0 ) } )
        source = String( header[0] )
        destination = String( header[2] )
        ranges = lines[1...]
            .map { SourceRange( line: $0 ) }
            .sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
    
    func merge( other: Map ) -> Map {
        var last = Int.min
        var newRanges = [SourceRange]()
        
        func handleUnaffected( clampRange: Range<Int> ) {
            let otherRanges = other.ranges
                .map { $0.clamped( to: clampRange ) }
                .filter { !$0.range.isEmpty }
            
            newRanges.append( contentsOf: otherRanges )
        }
        
        for range in ranges {
            if last < range.lowerBound {
                handleUnaffected( clampRange: last ..< range.lowerBound )
            }
            
            let otherRanges = other.ranges
                .map { $0.clamped( to: range.range.offset( by: range.addend ) ) }
                .filter { !$0.range.isEmpty }
                .map { $0.offset( by: -range.addend ) }
            
            newRanges.append( contentsOf: range.blend( with: otherRanges ) )
            last = range.upperBound
        }
        
        handleUnaffected( clampRange: last ..< Int.max )

        return Map( source: source, destination: other.destination, ranges: newRanges )
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
    
    return "\( seeds.map { locationFor( seed: $0, maps: maps ) }.min()! )"
}


func part2( input: AOCinput ) -> String {
    let ( seeds, maps ) = parse( input: input )
    var baseMap = maps["seed"]!
    
    while baseMap.destination != "location" {
        baseMap = baseMap.merge( other: maps[ baseMap.destination]! )
    }
    let mergedMaps = [ "seed" : baseMap ]
    var minLocation = Int.max
    
    for index in stride( from: 0, to: seeds.count, by: 2 ) {
        for seed in seeds[index] ..< ( seeds[index] + seeds[index+1] ) {
            minLocation = min( minLocation, locationFor( seed: seed, maps: mergedMaps ) )
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
