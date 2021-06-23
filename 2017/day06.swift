//
//         FILE: main.swift
//  DESCRIPTION: day06 - Memory Reallocation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/16/21 15:16:27
//

import Foundation

struct Result {
    let stepCount: Int
    let cycleLength: Int
}


func makeKey( for banks: [Int] ) -> String {
    return banks.map { String( $0 ) }.joined( separator: "," )
}


func redistribute( from banks: [Int] ) -> [Int] {
    let biggie = banks.max()!
    let index = banks.indices.first( where: { banks[$0] == biggie } )!
    let portion = biggie / banks.count
    let remainder = biggie % banks.count
    return banks.enumerated().map { ( arg0 ) -> Int in
        if arg0.offset == index {
            return portion
        }
        let permutedIndex = ( arg0.offset - index - 1 + banks.count ) % banks.count
        return arg0.element + portion + ( permutedIndex < remainder ? 1 : 0 )
    }
}


func parse( input: AOCinput ) -> Result? {
    var banks = input.line.split( separator: "\t" ).map { Int( $0 )! }
    var seen = [ makeKey( for: banks ) : 0 ]
    
    for stepCount in 1 ... Int.max {
        banks = redistribute( from: banks )
        
        let key = makeKey( for: banks )
        
        if let last = seen[key] {
            return Result( stepCount: stepCount, cycleLength: stepCount - last )
        }
        seen[key] = stepCount
    }
    
    return nil
}


func part1( input: AOCinput ) -> String {
    guard let result = parse( input: input )?.stepCount else { return "Failed!" }
    
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    guard let result = parse( input: input )?.cycleLength else { return "Failed!" }
    
    return "\(result)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
