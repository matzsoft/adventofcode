//
//         FILE: main.swift
//  DESCRIPTION: day21 - Dirac Dice
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/20/21 22:27:40
//

import Foundation

struct DeterministicDie {
    let sides: Int
    var next: Int
    var count = 0
    
    mutating func roll() -> Int {
        let roll = next + 1
        next = roll % sides
        count += 1
        return roll
    }
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0.split( separator: " " )[4] )! - 1 }
}


func part1( input: AOCinput ) -> String {
    var players = parse( input: input )
    var scores = Array( repeating: 0, count: players.count )
    var die = DeterministicDie( sides: 100, next: 0 )
    
    while true {
        players[0] = ( players[0] + die.roll() + die.roll() + die.roll() ) % 10
        scores[0] += players[0] + 1
        if scores[0] >= 1000 { break }
        
        players[1] = ( players[1] + die.roll() + die.roll() + die.roll() ) % 10
        scores[1] += players[1] + 1
        if scores[0] >= 1000 { break }
    }
    
    scores.sort()
    return "\( die.count * scores[0] )"
}


func part2( input: AOCinput ) -> String {
    let players = parse( input: input )
    var multiverses = Array( repeating: Array( repeating: Array( repeating: Array( repeating: Array( repeating: 0, count: 30 ), count: 10 ), count: 30 ), count: 10 ), count: 2 )
    
    multiverses[0][players[0]][0][players[1]][0] = 1
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
