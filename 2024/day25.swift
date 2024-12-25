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

struct Lock {
    let heights: [Int]
    let space: Int
    
    init( lines: [String] ) {
        let map = lines.map { [Character]( $0 ) }
        let skeleton = Array(
            repeating: Array( repeating: Character( " " ), count: map.count ),
            count: map[0].count
        )
        let flipped = map.indices.reduce( into: skeleton ) { flipped, y in
            map[0].indices.forEach { x in
                flipped[ map[0].count - x - 1 ][y] = map[y][x]
            }
        }
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
        let skeleton = Array(
            repeating: Array( repeating: Character( " " ), count: map.count ),
            count: map[0].count
        )
        let flipped = map.indices.reduce( into: skeleton ) { flipped, y in
            map[0].indices.forEach { x in
                flipped[ map[0].count - x - 1 ][y] = map[y][x]
            }
        }
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
        var count = 0
        for lock in locks {
            for key in keys {
                if lock.heights.indices.allSatisfy(
                    { lock.heights[$0] + key.heights[$0] <= lock.space }
                ) {
                    count += 1
                }
            }
        }
        return count
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
