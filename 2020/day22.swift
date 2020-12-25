//
//  main.swift
//  day22
//
//  Created by Mark Johnson on 12/22/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Deck {
    let title: String
    var cards: [Int]
    
    init( title: String, cards: [Int] ) {
        self.title = title
        self.cards = cards
    }
    
    init( input: String ) {
        let lines = input.split( separator: "\n" )
        
        title = String( lines.first! )
        cards = lines.dropFirst().map { Int( $0 )! }
    }
    
    var score: Int {
        return cards.reversed().enumerated().reduce( 0 ) { $0 + ( $1.offset + 1 ) * $1.element }
    }
}

func part1( decks: [Deck] ) -> Int {
    var decks = decks
    
    while decks.allSatisfy( { !$0.cards.isEmpty } ) {
        let first = decks[0].cards.removeFirst()
        let second = decks[1].cards.removeFirst()
        
        if first > second {
            decks[0].cards.append( contentsOf: [ first, second ] )
        } else {
            decks[1].cards.append( contentsOf: [ second, first ] )
        }
    }
    
    if decks[0].cards.isEmpty {
        return decks[1].score
    }
    
    return decks[0].score
}


func playRecursive( decks: [Deck] ) -> [Int] {
    var decks = decks
    var states = Set<String>()
    
    while decks.allSatisfy( { !$0.cards.isEmpty } ) {
        let state = decks.map {
            $0.cards.map { String( $0 ) }.joined(separator: ",")
        }.joined(separator: "|" )
        
        if states.contains( state ) { return [ decks[0].score, 0 ] }
        states.insert( state )
        
        let draws = [ decks[0].cards.removeFirst(), decks[1].cards.removeFirst() ]
        
        if decks.indices.allSatisfy( { draws[$0] <= decks[$0].cards.count } ) {
            let newDecks = [
                Deck( title: decks[0].title, cards: Array( decks[0].cards[ 0 ..< draws[0] ] ) ),
                Deck( title: decks[1].title, cards: Array( decks[1].cards[ 0 ..< draws[1] ] ) ),
            ]
            let scores = playRecursive( decks: newDecks )
            
            if scores[0] > scores[1] {
                decks[0].cards.append( contentsOf: draws )
            } else {
                decks[1].cards.append( contentsOf: draws.reversed() )
            }
        } else {
            if draws[0] > draws[1] {
                decks[0].cards.append( contentsOf: draws )
            } else {
                decks[1].cards.append( contentsOf: draws.reversed() )
            }
        }
    }
    
    return decks.map { $0.score }
}


func part2( decks: [Deck] ) -> Int {
    return playRecursive( decks: decks ).max()!
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day22.txt"
let groups =  try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" )
let decks = groups.map { Deck( input: $0 ) }

print( "Part 1: \( part1( decks: decks ) )" )
print( "Part 2: \( part2( decks: decks ) )" )
