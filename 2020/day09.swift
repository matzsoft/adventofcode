//
//  main.swift
//  day09
//
//  Created by Mark Johnson on 12/08/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

extension Array {
    var pairs: [ ( Element, Element ) ] {
        get {
            var result: [ ( Element, Element ) ] = []
            for index1 in 0 ..< count - 1 {
                for index2 in index1 + 1 ..< count {
                    result.append( (self[index1], self[index2] ) )
                }
            }
            return result
        }
    }
}


let preambleLength = 25
let inputFile = "/Users/markj/Development/adventofcode/2020/input/day09.txt"
let input = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int($0)! }
var preamble = Array( input[ 0 ..< preambleLength ] )
let remaining = input[ preambleLength ..< input.count ]

FINDINVALID:
for next in remaining {
    for ( value1, value2 ) in preamble.pairs {
        if value1 + value2 == next {
            preamble.removeFirst()
            preamble.append( next )
            continue FINDINVALID
        }
    }
    print( "Part 1: \(next)" )
    
    FINDSEQUENCE:
    for firstIndex in 0 ..< input.count - 1 {
        if input[firstIndex] < next {
            var sum = input[firstIndex]
            
            for lastIndex in firstIndex + 1 ..< input.count {
                sum += input[lastIndex]
                if sum > next { continue FINDSEQUENCE }
                if sum == next {
                    let inOrder = input[ firstIndex ... lastIndex ].sorted()
                    
                    print( "Part 2: \(inOrder.min()! + inOrder.max()!)" )
                    break FINDSEQUENCE
                }
            }
        }
    }
    
    break
}
