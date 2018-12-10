//
//  main.swift
//  day09
//
//  Created by Mark Johnson on 12/8/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test0 = "9 players; last marble is worth 63 points: high score is 63"
let test1 = "9 players; last marble is worth 32 points: high score is 32"
let test2 = "10 players; last marble is worth 1618 points: high score is 8317"
let test3 = "13 players; last marble is worth 7999 points: high score is 146373"
let test4 = "17 players; last marble is worth 1104 points: high score is 2764"
let test5 = "21 players; last marble is worth 6111 points: high score is 54718"
let test6 = "30 players; last marble is worth 5807 points: high score is 37305"
let input = "411 players; last marble is worth 71170 points"

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

class Circle {
    var head: Marble
    var current: Marble
    
    init() {
        head = Marble()
        head.left = head
        head.right = head
        current = head
    }
    
    func play( numPlayers: Int, until: Int ) -> Int {
        var players = Array(repeating: 0, count: numPlayers )

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
//                print( "next: \(next), current: \(current.value), removed: \(removed.value), score: \(score)")
           }
        }
        
        return players.max()!
    }
}

func parse( input: String ) -> ( numPlayers: Int, lastMarble: Int ) {
    let words = input.split(separator: " ")

    return ( numPlayers: Int( words[0] )!, lastMarble: Int( words[6] )! )
}


let ( numPlayers, lastMarble ) = parse(input: input)
let circle1 = Circle()
let circle2 = Circle()

print( "Part1:", circle1.play( numPlayers: numPlayers, until: lastMarble ) )
print( "Part2:", circle2.play( numPlayers: numPlayers, until: 100 * lastMarble ) )
