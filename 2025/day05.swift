//
//         FILE: day05.swift
//  DESCRIPTION: Advent of Code 2025 Day 5: Cafeteria
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/25 21:04:03
//

import Foundation
import Library

extension ClosedRange where Bound: Comparable {
    func union( other: ClosedRange<Bound> ) -> ClosedRange<Bound>? {
        guard self.overlaps( other ) else { return nil }
        let lower = Swift.min( self.lowerBound, other.lowerBound )
        let upper = Swift.max( self.upperBound, other.upperBound )
        return lower ... upper
    }
}


extension [ClosedRange<Int>] {
    var condensed: [ClosedRange<Int>] {
        let sorted = self.sorted { $0.lowerBound < $1.lowerBound }
        var condensed = [ sorted[0] ]
        
        for range in sorted.dropFirst() {
            if let union = condensed.last!.union( other: range ) {
                condensed[ condensed.count - 1 ] = union
            } else {
                condensed.append( range )
            }
        }
        return condensed
    }
}


func parse( input: AOCinput ) -> ( [ ClosedRange<Int> ], [ Int ] ) {
    let ranges = input.paragraphs[0].map { line in
        let bounds = line.split( separator: "-" ).map { Int( $0 )! }
        return bounds[0] ... bounds[1]
        
    }
    let available = input.paragraphs[1].map { Int( $0 )! }
    return ( ranges, available )
}


func part1( input: AOCinput ) -> String {
    let ( ranges, available ) = parse( input: input )
    let fresh = available.filter { ingredient in
        ranges.contains { $0.contains( ingredient ) }
    }

    return "\(fresh.count)"
}


func part2( input: AOCinput ) -> String {
    let ( ranges, _ ) = parse( input: input )
    let condensed = ranges.condensed

    return "\(condensed.reduce( 0 ) { $0 + $1.count })"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
