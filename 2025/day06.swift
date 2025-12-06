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
    
    init( operation: Problem.Operator, numbers: [Int] ) {
        self.operation = operation
        self.numbers = numbers
    }
    
    init( operations: [Operator], rows: [[[Character]]], index: Int ) {
        let elements = rows.indices.map { rows[ $0 ][ index ] }
        let numbers = elements[0].indices.reduce( into: [Int]() ) { numbers, i in
            let number = rows.indices.reduce( into: [Character]() ) { number, j in
                number.append( elements[ j ][ i ] )
            }.filter { $0 != " " }
            numbers.append( Int( String( number ) )! )
        }
        
        operation = operations[ index ]
        self.numbers = numbers
    }
}


func part1( input: AOCinput ) -> String {
    let operationRow = Array( input.lines.last! )
    let operations = operationRow.compactMap { Problem.Operator( rawValue: String( $0 ) ) }
    
    let numbers = input.lines.dropLast().reduce( into: [[Int]]() ) {
        $0.append( $1.split( separator: " ").compactMap{ Int( $0 )! } )
    }
    
    let problems = operations.indices.reduce( into: [Problem]() ) { problems, opIndex in
        let problemNumbers = numbers.indices.map { numbers[ $0 ][ opIndex ] }
        problems.append( Problem( operation: operations[opIndex], numbers: problemNumbers ) )
    }
    
    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


func allIndices( row: [Character] ) -> [Int] {
    row.indices.filter { Problem.Operator( rawValue: String( row[ $0 ] ) ) != nil }
}


func part2( input: AOCinput ) -> String {
    let operationRow = Array( input.lines.last! )
    let operations = operationRow.compactMap { Problem.Operator( rawValue: String( $0 ) ) }
    let columnIndices = allIndices( row: operationRow )
    let rows = input.lines.dropLast().map {
        let row = Array( $0 )
        let chunks = columnIndices.indices.reduce( into: [[Character]]() ) { chunks, index in
            if index < columnIndices.count - 1 {
                chunks.append( Array( row[ columnIndices[ index ] ..< columnIndices[ index + 1 ] - 1 ] ) )
            } else {
                chunks.append( Array( row[columnIndices[ index ]...] ) )
            }
        }
        return chunks
    }
    
    let problems = operations.indices.map {
        Problem( operations: operations, rows: rows, index: $0 )
    }
    
    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
