//
//  main.swift
//  day25
//
//  Created by Mark Johnson on 01/01/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//

import Foundation

let modulus = 20201227
let startValue = 1

struct Device {
    let publicKey: Int
    let loopCount: Int
    
    static func oneTransform( value: Int, subject: Int ) -> Int {
        return value * subject % modulus
    }
    
    init( input: Substring ) {
        var value = startValue
        var loopCount = 0

        publicKey = Int( input )!
        for loops in 1 ... Int.max {
            value = Device.oneTransform( value: value, subject: 7 )
            if value == publicKey {
                loopCount = loops
                break
            }
        }
        self.loopCount = loopCount
    }
    
    func fullTransform( subject: Int ) -> Int {
        var value = startValue
        
        for _ in 1 ... loopCount {
            value = Device.oneTransform( value: value, subject: subject )
        }
        
        return value
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day25.txt"
let devices = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Device( input: $0 ) }


print( "Part 1: \( devices[0].fullTransform( subject: devices[1].publicKey ) )" )
print( "Part 1: \( devices[1].fullTransform( subject: devices[0].publicKey ) )" )
//print( "Part 2: \( part2( initial: blacks ) )" )
