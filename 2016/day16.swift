//
//  main.swift
//  day16
//
//  Created by Mark Johnson on 1/3/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let dragonTests: [ ( in: String, out: String ) ] = [
    ( in: "1", out: "100" ),
    ( in: "0", out: "001" ),
    ( in: "11111", out: "11111000000" ),
    ( in: "111100001010", out: "1111000010100101011110000" )
]

let checksumTests: [ ( in: String, out: String ) ] = [
    ( in: "110010110100", out: "100" )
]

let fullTests: [ ( length: Int, initial: String, checksum: String ) ] = [
    ( length: 20, initial: "10000", checksum: "01100" )
]

let lengthDisk1 = 272
let initialDisk1 = "11101000110010100"
let lengthDisk2 = 35651584
let initialDisk2 = initialDisk1

func dragonStep( a: String ) -> String {
    let b = a.reversed()
    let b1 = b.map { $0 == "1" ? "2" : $0 }
    let b2 = b1.map { $0 == "0" ? "1" : $0 }
    let b3 = b2.map { $0 == "2" ? "0" : $0 }
    
    return a + "0" + b3
}

extension Substring {
    subscript( offset: Int ) -> Character {
        return self[ self.index( self.startIndex, offsetBy: offset ) ]
    }
}

func checksum( input: Substring ) -> String {
    guard input.count > 2 else { return input[0] == input[1] ? "1" : "0" }
    
    let index = input.index( input.startIndex, offsetBy: input.count / 2 )
    let left = input[..<index]
    let right = input[index...]
    
    if left == right { return "1" }
    return checksum(input: left) == checksum(input: right) ? "1" : "0"
}

func checksum( input: String ) -> String {
    let current = input.count
    var chunkSize = 1
    var result = ""
    
    while current & chunkSize == 0 { chunkSize <<= 1 }
    for offset in stride(from: 0, to: input.count, by: chunkSize) {
        let startIndex = input.index( input.startIndex, offsetBy: offset )
        let endIndex = input.index( startIndex, offsetBy: chunkSize  )
        
        result += checksum( input: input[ startIndex ..< endIndex ] )
    }
    
    return result
}

func fill( length: Int, initial: String ) -> String {
    var data = initial
    
    while data.count < length {
        data = dragonStep(a: data)
    }
    
    let index = data.index(data.startIndex, offsetBy: length)
    
    data = String( data[..<index] )
    return data
}

func fillAndChecksum( length: Int, initial: String ) -> String {
    return checksum(input: fill(length: length, initial: initial))
}


for test in dragonTests {
    if dragonStep(a: test.in ) != test.out {
        print( "Dragon test failed for '\(test.in)'" )
        exit(1)
    }
}

for test in checksumTests {
    if checksum(input: test.in) != test.out {
        print( "Checksum test failed for '\(test.in)'" )
        exit(1)
    }
}

for test in fullTests {
    if fillAndChecksum(length: test.length, initial: test.initial) != test.checksum {
        print( "Checksum test failed for '\(test.initial)'" )
        exit(1)
    }
}

print( "Part1:", fillAndChecksum(length: lengthDisk1, initial: initialDisk1) )
print( "Part2:", fillAndChecksum(length: lengthDisk2, initial: initialDisk2) )
