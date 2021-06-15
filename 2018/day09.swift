//
//         FILE: main.swift
//  DESCRIPTION: day09 - Marble Mania
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/15/21 12:47:58
//

import Foundation

class Marble {
    let value: Int
    var left: Marble?
    var right: Marble?
    
    init() {
        value = 0
        left = nil
        right = nil
    }
    
    init( value: Int, after: Marble ) {
        let before = after.right
        
        self.value = value
        left = after
        right = before
        after.right = self
        before?.left = self
    }
    
    func remove() -> Void {
        left?.right = right
        right?.left = left
    }
    
    func moveLeft( count: UInt ) -> Marble {
        var current = self
        
        ( 0 ..< count ).forEach { _ in current = current.left! }
        return current
    }
    
    func moveRight( count: UInt ) -> Marble {
        var current = self
        
        ( 0 ..< count ).forEach { _ in current = current.right! }
        return current
    }
}


func parse( input: AOCinput ) -> ( numPlayers: Int, lastMarble: Int ) {
    let words = input.line.split( separator: " " )

    return ( numPlayers: Int( words[0] )!, lastMarble: Int( words[6] )! )
}


func play( numPlayers: Int, until: Int ) -> Int {
    var current = Marble()
    var players = Array( repeating: 0, count: numPlayers )
    
    current.left = current
    current.right = current
    for next in 1 ... until {
        if next % 23 != 0 {
            current = current.moveRight( count: 1 )
            current = Marble( value: next, after: current )
        } else {
            let player = ( next - 1 ) % numPlayers
            let removed = current.moveLeft( count: 7 )
            let score = next + removed.value
            
            removed.remove()
            current = removed.right!
            players[player] += score
            // print( "next: \(next), current: \(current.value), removed: \(removed.value), score: \(score)")
        }
    }
    
    return players.max()!
}


func part1( input: AOCinput ) -> String {
    let ( numPlayers, lastMarble ) = parse( input: input )
    return "\(play( numPlayers: numPlayers, until: lastMarble ))"
}


func part2( input: AOCinput ) -> String {
    let ( numPlayers, lastMarble ) = parse( input: input )
    return "\(play( numPlayers: numPlayers, until: 100 * lastMarble ))"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
