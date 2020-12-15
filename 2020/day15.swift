//
//  main.swift
//  day15
//
//  Created by Mark Johnson on 12/14/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

let part1Limit = 2020
let part2Limit = 30000000
let inputFile = "/Users/markj/Development/adventofcode/2020/input/day15.txt"
let starting = try String( contentsOfFile: inputFile ).split( separator: "\n" )[0].split( separator: "," )
    .map { Int( $0 )! }
var spoken = Array( starting.dropLast() )
var already = Dictionary( zip( spoken, spoken.indices ), uniquingKeysWith: { (_, last) in last } )
var speakNext = starting.last!

for index in spoken.count ... part2Limit {
    let speakNow = speakNext
    spoken.append( speakNext )
    
    if let prevIndex = already[speakNow] {
        speakNext = index - prevIndex
    } else {
        speakNext = 0
    }
    already[speakNow] = index
}


print( "Part 1: \(spoken[part1Limit-1])" )
print( "Part 2: \(spoken[part2Limit-1])" )
