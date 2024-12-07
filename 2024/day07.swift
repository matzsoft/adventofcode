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
    
    static func somePossibles( length: Int ) -> [[Operation]] {
        if length == 1 { return Operation.someCases.map { [$0] } }
        
        let next = somePossibles( length: length - 1 )
        return next.flatMap { array in
            Operation.someCases.map { op -> [Operation] in array + [op] }
        }
    }
    
    static func allPossibles( length: Int ) -> [[Operation]] {
        if length == 1 { return Operation.allCases.map { [$0] } }
        
        let next = allPossibles( length: length - 1 )
        return next.flatMap { array in
            Operation.allCases.map { op -> [Operation] in array + [op] }
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
    
    func isValid( possibles: [[Operation]] ) -> Bool {
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
    
    var isValid: Bool {
        isValid( possibles: Operation.somePossibles( length: values.count - 1 ) )
    }

    var isReallyValid: Bool {
        isValid( possibles: Operation.allPossibles( length: values.count - 1 ) )
    }
}


func parse( input: AOCinput ) -> [Equation] {
    return input.lines.map { Equation( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let equations = parse( input: input )
    return "\(equations.filter { $0.isValid }.reduce( 0, { $0 + $1.solution } ) )"
}


func part2( input: AOCinput ) -> String {
    let equations = parse( input: input )
    let valids = equations.filter { $0.isReallyValid }
    return "\(valids.reduce( 0, { $0 + $1.solution } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
