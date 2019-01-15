//
//  main.swift
//  day15
//
//  Created by Mark Johnson on 1/14/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = """
Generator A starts with 783
Generator B starts with 325
"""

let startA = 783
let factorA = 16807
let maskA = 3

let startB = 325
let factorB = 48271
let maskB = 7

let divisor = 2147483647

func simpleNextValue( previous: Int, factor: Int ) -> Int {
    return ( previous * factor ) % divisor
}

func complexNextValue( previous: Int, factor: Int, mask: Int ) -> Int {
    var next = previous
    
    repeat {
        next = ( next * factor ) % divisor
    } while next & mask != 0
    
    return next
}



var currentA = startA
var currentB = startB
var judge = 0

for _ in 0 ..< 40000000 {
    currentA = simpleNextValue( previous: currentA, factor: factorA )
    currentB = simpleNextValue( previous: currentB, factor: factorB )
    
    let maskedA = currentA & 0xFFFF
    let maskedB = currentB & 0xFFFF
    
    if maskedA == maskedB { judge += 1 }
}

print( "Part1:", judge )



currentA = startA
currentB = startB
judge = 0

for _ in 0 ..< 5000000 {
    currentA = complexNextValue( previous: currentA, factor: factorA, mask: maskA )
    currentB = complexNextValue( previous: currentB, factor: factorB, mask: maskB )
    
    let maskedA = currentA & 0xFFFF
    let maskedB = currentB & 0xFFFF
    
    if maskedA == maskedB { judge += 1 }
}

print( "Part2:", judge )
