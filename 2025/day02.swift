//
//         FILE: day02.swift
//  DESCRIPTION: Advent of Code 2025 Day 2: Gift Shop
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/25 21:00:01
//

import Foundation
import Library

func digitsCount( of number: Int ) -> Int {
    Int( floor( log10( Double( number ) ) ) + 1 )
}

func maxWithDigits( of number: Int ) -> Int {
    Int( pow( 10.0, floor( log10( Double( number ) ) ) + 1 ) ) - 1
}

func maxWith( digits: Int ) -> Int {
    Int( pow( 10.0, Double( digits ) ) ) - 1
}


func parse( input: AOCinput ) -> [ClosedRange<Int>] {
    let ranges = input.line.split( separator: "," ).map { String( $0 ) }
    let bounds = ranges.map { $0.split( separator: "-" ).map { Int( $0 )! } }

    return bounds.map { $0[0] ... $0[1] }
}


func part1( input: AOCinput ) -> String {
    let ranges = parse( input: input )
    let all = ranges.flatMap { $0.filter {
        let numDigits = digitsCount( of: $0 )
        guard numDigits.isMultiple( of: 2 ) else { return false }
        let divisor = maxWithDigits( of: $0 ) / maxWith( digits: numDigits / 2 )
        return $0.isMultiple( of: divisor )
    } }
    
    return "\(all.reduce( 0, + ))"
}


func part2( input: AOCinput ) -> String {
    let ranges = parse( input: input )
    let all = ranges.flatMap { $0.filter {
        let numDigits = digitsCount( of: $0 )
        guard numDigits > 1 else { return false }
        for subDigits in 1 ... numDigits / 2 where numDigits.isMultiple( of: subDigits ) {
            let divisor = maxWithDigits( of: $0 ) / maxWith( digits: subDigits )
            if $0.isMultiple( of: divisor ) { return true }
        }
        return false
    } }
    
    return "\(all.reduce( 0, + ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
