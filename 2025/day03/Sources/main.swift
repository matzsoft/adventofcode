//
//         FILE: day03.swift
//  DESCRIPTION: Advent of Code 2025 Day 3: Lobby
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/25 21:00:01
//

import Foundation
import Library


func bestJolts( bank: [Int], size: Int ) -> [Int] {
    guard size > 0 else { return [] }
    
    let big = bank.max()!
    let bigIndex = bank.firstIndex( of: big )!
    
    if bank.count - bigIndex >= size {
        let nextBank = bank[(bigIndex + 1)...]
        return [big] + bestJolts( bank: Array( nextBank ), size: size - 1 )
    }
    
    for next in stride( from: big - 1, to: 0, by: -1 ) {
        if let index = bank[..<bigIndex].firstIndex( of: next ) {
            if bank.count - index >= size {
                let nextBank = Array( bank[(index + 1)...] )
                return [next] + bestJolts( bank: nextBank, size: size - 1 )
            }
        }
    }
    fatalError( "Argh!" )
}


func maxJoltage( bank: [Int], size: Int ) -> Int {
    let joltages = bestJolts( bank: bank, size: size )
    let biggest = joltages.map { String( $0 ) }.joined()
    return Int( biggest )!
}


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map { Array( $0 ).map { Int( String( $0 ) )! } }
}


func part1( input: AOCinput ) -> String {
    let banks = parse( input: input )
    let totalJolts = banks
        .map { maxJoltage( bank: $0, size: 2 ) }.reduce( 0, + )
    return "\(totalJolts)"
}


func part2( input: AOCinput ) -> String {
    let banks = parse( input: input )
    let totalJolts = banks
        .map { maxJoltage( bank: $0, size: 12 ) }.reduce( 0, + )
    return "\(totalJolts)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
