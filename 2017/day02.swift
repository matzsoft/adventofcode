//
//         FILE: main.swift
//  DESCRIPTION: day02 - Corruption Checksum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/14/21 20:23:03
//

import Foundation


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { $0.split(separator: " ").map { Int( $0 )! } }
}


func part1( input: AOCinput ) -> String {
    return "\(parse( input: input ).reduce( 0, { $0 + $1.max()! - $1.min()! } ))"
}


func part2( input: AOCinput ) -> String {
    let table = parse( input: input )
    let sum = table.reduce( 0 ) { ( sum, row ) -> Int in
        for i in 0 ..< row.count - 1 {
            for j in i + 1 ..< row.count {
                if row[i] % row[j] == 0 {
                    return sum + row[i] / row[j]
                }
                if row[j] % row[i] == 0 {
                    return sum + row[j] / row[i]
                }
            }
        }
        return sum
    }
    
    return "\(sum)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
