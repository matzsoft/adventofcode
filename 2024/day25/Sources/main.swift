//
//         FILE: day25.swift
//  DESCRIPTION: Advent of Code 2024 Day 25: Code Chronicle
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/24/24 21:01:00
//

import Foundation
import Library

func rotate90<T>( array: [[T]] ) -> [[T]] {
    return array[0].indices.reversed().reduce( into: [[T]]() ) {
        result, x in
        result.append( array.indices.map { array[$0][x] } )
    }
}

struct Lock {
    let heights: [Int]
    let space: Int
    
    init( lines: [String] ) {
        let map = lines.map { [Character]( $0 ) }
        let flipped = rotate90( array: map )
        heights = flipped.map { $0.firstIndex( of: "." )! - 1 }
        space = lines.count - 2
    }
}

struct Key {
    let heights: [Int]
    let space: Int
    
    init( lines: [String] ) {
        let space = lines.count - 2
        let map = lines.map { [Character]( $0 ) }
        let flipped = rotate90( array: map )
        heights = flipped.map { space - $0.lastIndex( of: "." )! }
        self.space = space
    }
}

struct Schematics {
    let locks: [Lock]
    let keys: [Key]
    
    init( paragraphs: [[String]] ) {
        locks = paragraphs
            .filter { $0[0].allSatisfy { $0 == "#" } }
            .map { Lock( lines: $0 ) }
        
        keys = paragraphs
            .filter { $0[0].allSatisfy { $0 == "." } }
            .map { Key( lines: $0 ) }
    }
    
    var matches: Int {
        locks.reduce( 0 ) { total, lock in
            total + keys.filter { key in
                lock.heights.indices.allSatisfy {
                    lock.heights[$0] + key.heights[$0] <= lock.space
                }
            }.count
        }
    }
}


func part1( input: AOCinput ) -> String {
    let schematics = Schematics( paragraphs: input.paragraphs )
    return "\(schematics.matches)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
