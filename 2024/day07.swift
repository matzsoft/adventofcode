//
//         FILE: day07.swift
//  DESCRIPTION: Advent of Code 2024 Day 7: Bridge Repair
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/24 21:00:02
//

import Foundation
import Library

enum Operation: CaseIterable {
    case add, multiply, concatenate
    
    static var someCases: [Operation] {
        [ .add, .multiply ]
    }
    
    static func possibles( length: Int, opList: [Operation] ) -> [[Operation]] {
        if length == 1 { return opList.map { [$0] } }
        
        let next = possibles( length: length - 1, opList: opList )
        return next.flatMap { array in
            opList.map { op -> [Operation] in array + [op] }
        }
    }
    
    func operate( left: Int, right: Int ) -> Int {
        switch self {
        case .add:
            return right + left
        case .multiply:
            return right * left
        case .concatenate:
            return Int( String( left ) + String( right ) )!
        }
    }
}

struct Equation {
    let solution: Int
    let values: [Int]
    
    init( line: String ) {
        let numbers = line.split( whereSeparator: { ": ".contains( $0 ) } )
            
        solution = Int( numbers[0] )!
        values = numbers[1...].map { Int( $0 )! }
    }
    
    func isValid( opList: [Operation] ) -> Bool {
        let possibles = Operation.possibles( length: values.count - 1, opList: opList )
        for opList in possibles {
            var result = values[0]
            for index in values.indices.dropLast() {
                result = opList[index].operate( left: result, right: values[index+1] )
                if result > solution { break }
            }
            if result == solution { return true }
        }
        return false
    }
}


func part1( input: AOCinput ) -> String {
    let equations = input.lines.map { Equation( line: $0 ) }
    let valids = equations.filter { $0.isValid(opList: Operation.someCases ) }
    return "\(valids.reduce( 0, { $0 + $1.solution } ) )"
}


func part2( input: AOCinput ) -> String {
    let equations = input.lines.map { Equation( line: $0 ) }
    let valids = equations.filter { $0.isValid(opList: Operation.allCases ) }
    return "\(valids.reduce( 0, { $0 + $1.solution } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
