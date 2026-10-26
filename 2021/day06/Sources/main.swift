//
//         FILE: main.swift
//  DESCRIPTION: day06 - Lanternfish
//        NOTES: The brute force solution works for part 1, but clearly not for part 2.
//               I tried a recursive solution, but it took over night to run.
//               Then I came up with the simple solution below.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/05/21 21:00:10
//

import Foundation
import Library

func spawn( fish: [Int], days: Int ) -> Int {
    var fish = fish.reduce( into: Array( repeating: 0, count: 9 ) ) { $0[$1] += 1 }
    
    for _ in 1 ... days {
        let newCount = fish[0]
        for index in 0 ... 7 {
            fish[index] = fish[index+1]
        }
        fish[8] = newCount
        fish[6] += newCount
    }
    
    return fish.reduce( 0, + )
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    return "\( spawn( fish: parse( input: input ), days: 80 ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( spawn( fish: parse( input: input ), days: 256 ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
