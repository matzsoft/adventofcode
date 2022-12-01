//
//         FILE: main.swift
//  DESCRIPTION: day01 - Calorie Counting
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/30/22 21:01:35
//

import Foundation


func parse( input: AOCinput ) -> [[Int]] {
    return input.paragraphs.map {
        $0.map { Int( $0 )! }
    }
}


func part1( input: AOCinput ) -> String {
    let elves = parse( input: input )
    let calories = elves.map { $0.reduce( 0, + ) }

    return "\(calories.max()!)"
}


func part2( input: AOCinput ) -> String {
    let elves = parse( input: input )
    let calories = elves.map { $0.reduce( 0, + ) }.sorted { $0 > $1 }
    let answer = calories[ 0 ... 2 ].reduce( 0, + )
    return "\(answer)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
