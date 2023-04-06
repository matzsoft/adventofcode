//
//         FILE: main.swift
//  DESCRIPTION: day05 - Alchemical Reduction
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/01/21 12:35:41
//

import Foundation
import Library

extension Character {
    func toggleCase() -> Character {
        if isLowercase { return Character( uppercased() ) }
        return Character( lowercased() )
    }
}


func react( _ input: String ) -> Int {
    var input = input.map { Character?( $0 ) }
    var leftIndex = 0
    var rightIndex = 0
    
    while rightIndex < input.count {
        if input[leftIndex] != input[rightIndex]?.toggleCase() {
            leftIndex = rightIndex
        } else {
            input[leftIndex] = nil
            input[rightIndex] = nil
            while leftIndex >= 0 && input[leftIndex] == nil { leftIndex -= 1 }
            if leftIndex < 0 { leftIndex = rightIndex }
        }
        rightIndex += 1
    }
    
    return input.compactMap{ $0 }.count
}


func remove( input: String, type: Character ) -> String {
    let output = input.replacingOccurrences( of: String( type ), with: "" )
    let upper = String( type ).uppercased()
    
    return output.replacingOccurrences( of: upper, with: "" )
}


func part1( input: AOCinput ) -> String {
    return "\(react(input.line))"
}


func part2( input: AOCinput ) -> String {
    let result = "abcdefghijklmnopqrstuvwxyz".reduce( input.line.count ) {
        min( $0, react( remove(input: input.line, type: $1) ) )
    }
    return "\(result)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
