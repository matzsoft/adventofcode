//
//  main.swift
//  day09
//
//  Created by Mark Johnson on 12/08/20.
//  Copyright © 2020 matzsoft. All rights reserved.
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


func findSequence( input: [Int], invalid: Int ) -> Int {
    var sum = 0
    var lastIndex = 0
    let firstIndex = input.indices.first( where: { index1 in
        sum = input[index1]
        
        if sum < invalid {
            for index2 in index1 + 1 ..< input.count {
                sum += input[index2]
                lastIndex = index2
                if sum >= invalid { break }
            }
        }
        return sum == invalid
    } )!

    let sequence = input[ firstIndex ... lastIndex ]
        
    return sequence.min()! + sequence.max()!
}


let preambleLength = 25
let inputFile = "/Users/markj/Development/adventofcode/2020/input/day09.txt"
let input = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int($0)! }
var preambleStart = 0
let invalid = input[ preambleLength ..< input.count ].first( where: { candidate in
    if input[ preambleStart ..< preambleStart + preambleLength ].pairs.first( where: { pair in
        return pair.0 + pair.1 == candidate
    } ) == nil {
        return true
    }
    
    preambleStart += 1
    return false
} )!

print( "Part 1: \(invalid)" )
print( "Part 2: \(findSequence( input: input, invalid: invalid ))" )
