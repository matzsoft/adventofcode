//
//         FILE: main.swift
//  DESCRIPTION: day06 - Santa sending a message via repetition code
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/25/21 18:59:49
//

import Foundation


func parse( input: AOCinput ) -> [[Character:Int]] {
    let lines = input.lines
    let columns: [[Character:Int]] = Array(repeating: [:], count: lines[0].count )

    return input.lines.reduce( into: columns ) { columns, line in
        line.enumerated().forEach {  ( index, letter ) in
            columns[index][letter] = ( columns[index][letter] ?? 0 ) + 1
            columns[index][letter] = columns[index][letter, default: 0] + 1
        }
    }
}


func part1( input: AOCinput ) -> String {
    let columns = parse( input: input )

    return columns.map { $0.max( by: { $0.1 < $1.1 } )!.key }.map { String( $0 ) }.joined()
}


func part2( input: AOCinput ) -> String {
    let columns = parse( input: input )

    return columns.map { $0.min( by: { $0.1 < $1.1 } )!.key }.map { String( $0 ) }.joined()
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
