//
//  main.swift
//  day10
//
//  Created by Mark Johnson on 12/09/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//
// Per the problem definition there can be no deltas with a value of zero.  However deltas with a value of
// two are not explicitly prohibited.  This is not a problem for Part 1, but my method for solving Part 2
// will not work if there are any deltas with a value of 2.

import Foundation

func getFactor( count: Int ) -> Int {
    guard count > 1 else { return 1 }
    
    let power = 1 << ( count - 1 )
    
    guard count > 3 else { return power }
    
    return power - ( count - 3 ) * ( count - 2 ) / 2
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day10.txt"
let input = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int($0)! }.sorted()
var last = 0

let deltas = input.map { (jolts) -> Int in let r = jolts - last; last = jolts; return r }
let onesCount = deltas.filter { $0 == 1 }.count
let twosCount = deltas.filter { $0 == 2 }.count
let threesCount = deltas.filter { $0 == 3 }.count

guard twosCount == 0 else {
    print( "Unexpected delta(s) of 2 in input.  Unable to solve Part2." )
    exit(0)
}

let runs = deltas.split( separator: 3 )

print( "Part 1: \(onesCount * ( threesCount + 1 ))" )
print( "Part 2: \(runs.reduce( 1 ) { $0 * getFactor( count: $1.count ) })" )
