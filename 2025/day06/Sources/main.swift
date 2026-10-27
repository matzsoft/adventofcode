//
//         FILE: day06.swift
//  DESCRIPTION: Advent of Code 2025 Day 6: Trash Compactor
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/05/25 21:00:01
//

import Foundation
import Library

struct Problem {
    enum Operator: String { case add = "+", multipy = "*" }
    
    let operation: Operator
    let numbers: [Int]
    
    var value: Int {
        switch operation {
        case .add: return numbers.reduce( 0, + )
        case .multipy: return numbers.reduce( 1, * )
        }
    }
}


func part1( input: AOCinput ) -> String {
    let operationRow = Array( input.lines.last! )
    let operations = operationRow.compactMap {
        Problem.Operator( rawValue: String( $0 ) )
    }
    
    let numbers = input.lines.dropLast().reduce( into: [[Int]]() ) {
        $0.append( $1.split( separator: " ").compactMap{ Int( $0 )! } )
    }
    
    let problems = operations.indices.reduce( into: [Problem]() ) {
        problems, opIndex in
        let problemNumbers = numbers.indices.map { numbers[ $0 ][ opIndex ] }
        problems.append(
            Problem( operation: operations[opIndex], numbers: problemNumbers )
        )
    }
    
    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


func part2( input: AOCinput ) -> String {
    let operationRow = Array( input.lines.last! )
    let operations = Array(
        operationRow.compactMap { Problem.Operator( rawValue: String( $0 ) ) }
            .reversed()
    )
    let transposed = input.lines.dropLast()
        .map { Array( $0 ) }.transpose()
        .map { String( $0.filter { $0 != " " } ) }
        .split( whereSeparator: { $0.isEmpty } )
        .map { $0.map { Int( $0 )! } }
    let problems = operations.indices.reduce( into: [Problem]() ) {
        $0.append( Problem( operation: operations[$1], numbers: transposed[ $1 ] ) )
    }

    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
