//
//  main.swift
//  day06
//
//  Created by Mark Johnson on 1/11/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = "4    1    15    12    0    9    9    5    5    8    7    3    14    5    12    3"
var banks = input.split(separator: " ").map { Int( $0 )! }
var seen: [String:Int] = [:]
var stepCount = 0

func banksKey() -> String {
    return banks.map { String( $0 ) }.joined(separator: ",")
}

func redistribute() -> Void {
    let biggie = banks.max()!
    let index = ( 0 ..< banks.count ).first( where: { banks[$0] == biggie } )!
    
    banks[index] = 0
    ( 0 ..< banks.count ).forEach { banks[$0] += biggie / banks.count }
    
    for index in index + 1 ... index + biggie % banks.count {
        let index = index % banks.count
        
        banks[index] += 1
    }
}

seen[banksKey()] = stepCount
while true {
    stepCount += 1
    redistribute()
    
    let key = banksKey()
    
    if let last = seen[key] {
        print( "Part1:", stepCount )
        print( "Part2:", stepCount - last )
        break
    }
    seen[key] = stepCount
}
