//
//         FILE: main.swift
//  DESCRIPTION: day01 - Report Repair
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/23/21 16:21:42
//

import Foundation

extension Array {
    var pairs: [ ( Element, Element ) ] {
        get {
            var result: [ ( Element, Element ) ] = []
            for index1 in 0 ..< count - 1 {
                for index2 in index1 + 1 ..< count {
                    result.append( ( self[index1], self[index2] ) )
                }
            }
            return result
        }
    }

    var triples: [ ( Element, Element, Element ) ] {
        get {
            var result: [ ( Element, Element, Element ) ] = []
            for index1 in 0 ..< count - 2 {
                for index2 in index1 + 1 ..< count - 1 {
                    for index3 in index2 + 1 ..< count {
                        result.append( ( self[index1], self[index2], self[index3] ) )
                    }
                }
            }
            return result
        }
    }
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let expenses = parse( input: input )
    
    if let ( value1, value2 ) = expenses.pairs.first( where: { $0.0 + $0.1 == 2020 } ) {
        return "\( value1 * value2 )"
    }

    return ""
}


func part2( input: AOCinput ) -> String {
    let expenses = parse( input: input )
    
    if let ( value1, value2, value3 ) = expenses.triples.first( where: { $0.0 + $0.1 + $0.2 == 2020 } ) {
        return "\( value1 * value2 * value3 )"
    }
    
    return ""
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
