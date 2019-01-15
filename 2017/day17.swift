//
//  main.swift
//  day17
//
//  Created by Mark Johnson on 1/15/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = 301

let step = input
var buffer = [ 0 ]
var current = 0

for value in 1 ... 2017 {
    current = ( current + step ) % buffer.count + 1
    buffer.insert( value, at: current )
}

let desired = ( current + 1 ) % buffer.count

print( "Part1:", buffer[desired] )


var bufferLen = buffer.count
var last = buffer[1]

for value in 2018 ... 50000000 {
    current = ( current + step ) % bufferLen + 1
    bufferLen += 1
    
    if current == 1 {
        last = value
    }
}

print( "Part2:", last )
