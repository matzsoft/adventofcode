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


extension String {
    func splitBy( length: Int ) -> [String] {
        guard length > 0 else { return [] } // Handle invalid length
        var result: [String] = []
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex {
            let endIndex = self
                .index( startIndex, offsetBy: length, limitedBy: self.endIndex ) ?? self.endIndex
            let substring = self[ startIndex ..< endIndex ]
            result.append( String( substring ) )
            startIndex = endIndex
        }
        return result
    }
}



func parse( input: AOCinput ) -> [ClosedRange<Int>] {
    let ranges = input.line.split( separator: "," ).map { String( $0 ) }
    let bounds = ranges.map { $0.split( separator: "-" ).map { Int( $0 )! } }

    return bounds.map { $0[0] ... $0[1] }
}


func part1( input: AOCinput ) -> String {
    let ranges = parse( input: input )
    var sum = 0
    
    for range in ranges {
        for id in range {
            let string = String( id )
            let len = string.count
            if len.isMultiple( of: 2 ) {
                if string.prefix( len/2 ) == string.suffix( len/2 ) {
                    sum += id
                }
            }
        }
    }
    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let ranges = parse( input: input )
    var sum = 0
    
    for range in ranges {
        for id in range {
            let string = String( id )
            let len = string.count
            
            if len > 1 {
                for size in 1 ... len / 2 {
                    if len.isMultiple( of: size ) {
                        let parts = string.splitBy( length: size )
                        if parts.allSatisfy( { $0 == parts[0] } ) {
                            sum += id
                            break
                        }
                    }
                }
            }
        }
    }
    
    return "\(sum)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
