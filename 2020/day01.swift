//
//  main.swift
//  day01
//
//  Created by Mark Johnson on 12/04/20.
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

    var triples: [ ( Element, Element, Element ) ] {
        get {
            var result: [ ( Element, Element, Element ) ] = []
            for index1 in 0 ..< count - 2 {
                for index2 in index1 + 1 ..< count - 1 {
                    for index3 in index2 + 1 ..< count {
                        result.append( (self[index1], self[index2], self[index3] ) )
                    }
                }
            }
            return result
        }
    }
}

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day01.txt"
let expenses = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int($0)! }

for ( index1, value1 ) in expenses.enumerated() {
    for index2 in (index1+1) ..< expenses.count {
        let value2 = expenses[index2]
        
        if value1 + value2 == 2020 {
            print( "Part 1: \(value1 * value2)" )
        } else if value1 + value2 < 2020 {
            for value3 in expenses[(index2+1)...] {
                if value1 + value2 + value3 == 2020 {
                    print( "Part 2: \(value1 * value2 * value3)" )
                }
            }
        }
    }
}

for ( value1, value2 ) in expenses.pairs {
    if value1 + value2 == 2020 {
        print( "Part 1: \(value1 * value2)" )
        break
    }
}

for ( value1, value2, value3 ) in expenses.triples {
    if value1 + value2 + value3 == 2020 {
        print( "Part 2: \(value1 * value2 * value3)" )
        break
    }
}
