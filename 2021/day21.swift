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

struct Player: Hashable {
    var location: Int
    var score: Int
    var isWinner: Bool { score >= 21 }
}


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


struct State: Hashable {
    let players: [Player]
}


func parse( input: AOCinput ) -> [Player] {
    return input.lines.map { Player( location: Int( $0.split( separator: " " )[4] )! - 1, score: 0 ) }
}


func part1( input: AOCinput ) -> String {
    var players = parse( input: input )
    var die = DeterministicDie( sides: 100, next: 0 )
    
    while true {
        players[0].location = ( players[0].location + die.roll() + die.roll() + die.roll() ) % 10
        players[0].score += players[0].location + 1
        if players[0].score >= 1000 { break }
        
        players[1].location = ( players[1].location + die.roll() + die.roll() + die.roll() ) % 10
        players[1].score += players[1].location + 1
        if players[1].score >= 1000 { break }
    }
    
    let scores = players.map { $0.score }.sorted()
    return "\( die.count * scores[0] )"
}


let diracDieRoll = [ ( 3, 1 ), ( 4, 3 ), ( 5, 6 ), ( 6, 7 ), ( 7, 6 ), ( 8, 3 ), ( 9, 1 ) ]


func part2( input: AOCinput ) -> String {
    let players = parse( input: input )
    var wins = Array( repeating: 0, count: players.count )
    var turn1 = [ State : Int ]()
    var turn2 = turn1

    turn1[ State( players: players ) ] = 1
    
    while !turn1.isEmpty {
        for state in turn1 {
            for ( roll, count ) in diracDieRoll {
                let newLocation = ( state.key.players[0].location + roll ) % 10
                let newScore = state.key.players[0].score + newLocation + 1
                let newPlayer = Player( location: newLocation, score: newScore )
                let newCount = state.value * count
                let newState = State( players: [ newPlayer, state.key.players[1] ] )
                
                if newPlayer.isWinner {
                    wins[0] += newCount
                } else {
                    turn2[ newState, default: 0 ] += newCount
                }
            }
        }
        turn1.removeAll()
            
        for state in turn2 {
            for ( roll, count ) in diracDieRoll {
                let newLocation = ( state.key.players[1].location + roll ) % 10
                let newScore = state.key.players[1].score + newLocation + 1
                let newPlayer = Player( location: newLocation, score: newScore )
                let newCount = state.value * count
                let newState = State( players: [ state.key.players[0], newPlayer ] )
                
                if newPlayer.isWinner {
                    wins[1] += newCount
                } else {
                    turn1[ newState, default: 0 ] += newCount
                }
            }
        }
        turn2.removeAll()
    }
    
    return "\( wins.max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
