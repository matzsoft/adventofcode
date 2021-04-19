//
//         FILE: main.swift
//  DESCRIPTION: day10 - Knot Hash
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/18/21 20:44:19
//

import Foundation

class KnotHash {
    var list: [Int]
    let lengths: [Int]
    var current: Int
    var skip: Int
    
    init( list: [Int], lengths: [Int] ) {
        self.list = list
        self.lengths = lengths
        current = 0
        skip = 0
    }
    
    func oneRound() -> Void {
        for length in lengths {
            if current + length  < list.count {
                let reversed = Array( list[ current ..< ( current + length) ].reversed() )
                
                list.replaceSubrange( current ..< ( current + length), with: reversed )
            } else {
                let working = list + list
                let reversed = Array( working[ current ..< ( current + length) ].reversed() )
                let part1 = Array( reversed[ ( list.count - current )...] )
                let part2 = Array( list[ ( ( current + length ) % list.count ) ..< current ] )
                let part3 = Array( reversed[ 0 ..< ( list.count - current ) ] )
                
                list = part1 + part2 + part3
            }
            
            current = ( current + length + skip ) % list.count
            skip += 1
        }
    }
    
    func generate() -> String {
        guard list.count == 256 else { return "Wrong sized list" }
        
        for _ in 0 ..< 64 { oneRound() }
        
        return stride( from: 0, to: list.count, by: 16 ).map {
            return String( format: "%02x", list[ $0 ..< ( $0 + 16 ) ].reduce( 0, { $0 ^ $1 } ) )
        }.joined()
    }
}


func part1( input: AOCinput ) -> String {
    let list = ( 0 ... 255 ).map { $0 }
    let lengths = input.line.split( separator: "," ).map { Int( $0 )! }
    let knot = KnotHash( list: list, lengths: lengths )

    knot.oneRound()
    return "\(knot.list[0] * knot.list[1])"
}


func part2( input: AOCinput ) -> String {
    let list = ( 0 ... 255 ).map { $0 }
    let lengths = input.line.map { Int( $0.unicodeScalars.first!.value ) } + [ 17, 31, 73, 47, 23 ]
    let knothash = KnotHash( list: list, lengths: lengths )
    
    return "\(knothash.generate())"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
