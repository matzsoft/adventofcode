//
//         FILE: main.swift
//  DESCRIPTION: day04 - High-Entropy Passphrases
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/15/21 14:29:34
//

import Foundation


func parse( input: AOCinput ) -> [[String]] {
    return input.lines.map { $0.split( separator: " " ).map { String( $0 ) } }
}


func part1( input: AOCinput ) -> String {
    let lines = parse( input: input )
    let validCount = lines.filter { $0.count == Set( $0 ).count }.count
    return "\(validCount)"
}


func part2( input: AOCinput ) -> String {
    let lines = parse( input: input )
    let validCount = lines.filter { $0.count == Set( $0.map { $0.sorted() } ).count }.count
    return "\(validCount)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
