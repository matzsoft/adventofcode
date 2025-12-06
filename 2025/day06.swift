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
    internal init(operation: Problem.Operator, numbers: [Int]) {
        self.operation = operation
        self.numbers = numbers
    }
    
    enum Operator: String { case add = "+", multipy = "*" }
    
    let operation: Operator
    let numbers: [Int]
    
    var value: Int {
        switch operation {
        case .add: return numbers.reduce( 0, + )
        case .multipy: return numbers.reduce( 1, * )
        }
    }
    
    init( operations: [Operator], rows: [[[Character]]], index: Int ) {
        let elements = rows.indices.map { rows[ $0 ][ index ] }
        let numbers = elements[0].indices.reduce( into: [Int]() ) { result, i in
            let number = rows.indices.reduce( into: [Character]() ) { result, j in
                result.append( elements[ j ][ i ] )
            }.filter { $0 != " " }
            result.append( Int( String( number ) )! )
        }
        
        operation = operations[ index ]
        self.numbers = numbers
    }
    
    func add( number: Int ) -> Problem {
        Problem( operation: operation, numbers: numbers + [number] )
    }
    
    func changeOperator( to newOp: Operator ) -> Problem {
        Problem( operation: newOp, numbers: numbers )
    }
}


func allIndices( row: [Character] ) -> [Int] {
    row.indices.filter { Problem.Operator( rawValue: String( row[ $0 ] ) ) != nil }
}


func parse( input: AOCinput ) -> [Problem] {
    let operationRow = Array( input.lines.last! )
    let operations = operationRow.compactMap { Problem.Operator( rawValue: String( $0 ) ) }
    let columnIndices = allIndices( row: operationRow )
    let rows = input.lines.dropLast().map {
        let row = Array( $0 )
        var chunks = [[Character]]()
        
        for index in columnIndices.indices.dropLast() {
            chunks.append( Array( row[ columnIndices[ index ] ..< columnIndices[ index + 1 ] - 1 ] ) )
        }
        chunks.append( Array( row[ columnIndices.last!... ] ) )
        return chunks
    }
    
    var numbers = [[Int]]()
    var problems = operations.indices.map { Problem(operations: operations, rows: rows, index: $0 ) }
    
//    for line in input.lines {
//        let local = line.split( separator: " ")
//        if Problem.Operator( rawValue: String( local[0] ) ) != nil {
//            operations = local.map { Problem.Operator( rawValue: String( $0 ) )! }
//        } else {
//            numbers.append( local.compactMap{ Int( $0 )! } )
//        }
//    }
    
//    for opIndex in operations.indices {
//        let problemNumbers = numbers.indices.map { numbers[ $0 ][ opIndex ] }
//        problems.append( Problem( operation: operations[opIndex], numbers: problemNumbers ) )
//    }
    
    return problems
}


func part1( input: AOCinput ) -> String {
    var numbers = [[Int]]()
    var operations = [Problem.Operator]()
    var problems = [Problem]()
    
    for line in input.lines {
        let local = line.split( separator: " ")
        if Problem.Operator( rawValue: String( local[0] ) ) != nil {
            operations = local.map { Problem.Operator( rawValue: String( $0 ) )! }
        } else {
            numbers.append( local.compactMap{ Int( $0 )! } )
        }
    }
    
    for opIndex in operations.indices {
        let problemNumbers = numbers.indices.map { numbers[ $0 ][ opIndex ] }
        problems.append( Problem( operation: operations[opIndex], numbers: problemNumbers ) )
    }
    
    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


func part2( input: AOCinput ) -> String {
    let problems = parse( input: input )
    return "\(problems.reduce( 0 ) { $0 + $1.value } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
