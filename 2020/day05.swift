//
//  main.swift
//  day05
//
//  Created by Mark Johnson on 12/04/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

func seatID<T>( input: T ) -> Int where T: StringProtocol {
    let noF = input.replacingOccurrences( of: "F", with: "0" )
    let noB = noF.replacingOccurrences(   of: "B", with: "1" )
    let noL = noB.replacingOccurrences(   of: "L", with: "0" )
    let noR = noL.replacingOccurrences(   of: "R", with: "1" )
    
    return Int( noR, radix: 2 )!
}

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day05.txt"
let seats = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map {
    seatID( input: $0 ) }.sorted()
let myIndex = ( 0 ..< seats.count - 1 ).first { seats[$0] + 1 != seats[$0+1] }!

print( "Part 1: \(seats.last!)" )
print( "Part 2: \(seats[myIndex]+1)" )
