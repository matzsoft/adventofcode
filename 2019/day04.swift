//
//  main.swift
//  day04
//
//  Created by Mark Johnson on 12/3/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = "193651-649729"
let bounds = input.split( separator: "-" ).map { Int( $0 )! }
var validCount1 = 0
var validCount2 = 0

func isValid1( number: Int ) -> Bool {
    let digits = Array( String( number ) ).map { Int( String( $0 ) )! }
    var duplicate = false
    var last = 0
    
    for digit in digits {
        if digit < last {
            return false
        }
        if digit == last {
            duplicate = true
        }
        last = digit
    }
    
    return duplicate
}

func isValid2( number: Int ) -> Bool {
    let digits = Array( String( number ) ).map { Int( String( $0 ) )! }
    var duplicateCount = 1
    var last = 0
    
    for digit in digits {
        if digit == last {
            duplicateCount += 1
        } else if duplicateCount == 2 {
            return true
        } else {
            duplicateCount = 1
        }
        last = digit
    }
    
    return duplicateCount == 2
}

for number in bounds[0] ... bounds[1] {
    if isValid1( number: number ) {
        validCount1 += 1
        if isValid2( number: number ) {
            validCount2 += 1
        }
    }
}

print( "Part 1: \(validCount1)" )
print( "Part 2: \(validCount2)" )
