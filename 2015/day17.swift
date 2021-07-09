//
//         FILE: main.swift
//  DESCRIPTION: day17 - No Such Thing as Too Much
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/09/21 12:58:36
//

import Foundation

func findSolutions( used: Int, amount: Int, available: [Int] ) -> [Int] {
    let first = available.first!
    let rest = Array( available.dropFirst() )
    
    if rest.isEmpty { return first == amount ? [ used + 1 ] : [] }
    if first > amount { return findSolutions( used: used, amount: amount, available: rest ) }
    if first == amount { return [ used + 1 ] + findSolutions( used: used, amount: amount, available: rest ) }
    
    return
        findSolutions( used: used + 1, amount: amount - first, available: rest ) +
        findSolutions( used: used,     amount: amount,         available: rest )
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let containers = parse( input: input )
    let amount = Int( input.extras[0] )!
    let solutions = findSolutions( used: 0, amount: amount, available: containers )
    
    return "\( solutions.count )"
}


func part2( input: AOCinput ) -> String {
    let containers = parse( input: input )
    let amount = Int( input.extras[0] )!
    let solutions = findSolutions( used: 0, amount: amount, available: containers )
    let least = solutions.min()!
    
    return "\( solutions.filter { $0 == least }.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
