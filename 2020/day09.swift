//
//         FILE: main.swift
//  DESCRIPTION: day09 - Encoding Error
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/25/21 11:50:28
//

import Foundation

extension Collection {
    var pairs: [ ( Element, Element ) ] {
        get {
            var result: [ ( Element, Element ) ] = []
            for index1 in indices {
                if index1 < endIndex {
                    var index2 = index( after: index1 )
                    while index2 < endIndex {
                        result.append( (self[index1], self[index2] ) )
                        index2 = index( after: index2 )
                    }
                }
            }
            return result
        }
    }
}


func findInvalid( numbers: [Int], preambleLength: Int ) -> Int {
    let index = ( preambleLength ..< numbers.count ).first( where: { index in
        return numbers[ index - preambleLength ..< index ].pairs.first( where: { pair in
            return pair.0 + pair.1 == numbers[index]
        } ) == nil
    } )!

    return numbers[index]
}


func findSequence( input: [Int], invalid: Int ) -> [Int] {
    var lastIndex = 0
    let firstIndex = input.indices.first( where: { index1 in
        var sum = input[index1]
        
        if sum < invalid {
            for index2 in index1 + 1 ..< input.count {
                sum += input[index2]
                lastIndex = index2
                if sum >= invalid { break }
            }
        }
        return sum == invalid
    } )!

    return Array( input[ firstIndex ... lastIndex ] )
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let numbers = parse( input: input )
    let preambleLength = Int( input.extras[0] )!
    
    return "\( findInvalid( numbers: numbers, preambleLength: preambleLength ) )"
}


func part2( input: AOCinput ) -> String {
    let numbers = parse( input: input )
    let preambleLength = Int( input.extras[0] )!
    let invalid = findInvalid( numbers: numbers, preambleLength: preambleLength )
    let sequence = findSequence( input: numbers, invalid: invalid )
    
    return "\( sequence.min()! + sequence.max()! )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
