//
//         FILE: main.swift
//  DESCRIPTION: day25 - Combo Breaker
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/01/21 16:00:07
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
    
    init( input: String ) {
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


func parse( input: AOCinput ) -> [Device] {
    return input.lines.map { Device( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let devices = parse( input: input )
    let card = devices[1].fullTransform( subject: devices[0].publicKey )
    let door = devices[0].fullTransform( subject: devices[1].publicKey )
    
    guard card == door else {
        return "Card and door don't match."
    }
    
    return "\( card )"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
