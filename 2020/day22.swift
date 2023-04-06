//
//         FILE: main.swift
//  DESCRIPTION: day22 - Crab Combat
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/30/21 23:23:37
//

import Foundation
import Library

struct Deck {
    let title: String
    var cards: [Int]
    
    init( title: String, cards: [Int] ) {
        self.title = title
        self.cards = cards
    }
    
    init( lines: [String] ) {
        title = String( lines.first! )
        cards = lines.dropFirst().map { Int( $0 )! }
    }
    
    var score: Int {
        return cards.reversed().enumerated().reduce( 0 ) { $0 + ( $1.offset + 1 ) * $1.element }
    }
}


func playRecursive( decks: [Deck] ) -> [Int] {
    var decks = decks
    var states = Set<String>()
    
    while decks.allSatisfy( { !$0.cards.isEmpty } ) {
        let state = decks.map {
            $0.cards.map { String( $0 ) }.joined(separator: ",")
        }.joined(separator: "|" )
        
        if !states.insert( state ).inserted { return [ decks[0].score, 0 ] }
        
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


func parse( input: AOCinput ) -> [Deck] {
    return input.paragraphs.map { Deck( lines: $0 ) }
}


func part1( input: AOCinput ) -> String {
    var decks = parse( input: input )
    
    while decks.allSatisfy( { !$0.cards.isEmpty } ) {
        let draws = [ decks[0].cards.removeFirst(), decks[1].cards.removeFirst() ]
        
        if draws[0] > draws[1] {
            decks[0].cards.append( contentsOf: draws )
        } else {
            decks[1].cards.append( contentsOf: draws.reversed() )
        }
    }
    
    return "\( decks.map { $0.score }.max()! )"
}


func part2( input: AOCinput ) -> String {
    let decks = parse( input: input )
    
    return "\( playRecursive( decks: decks ).max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
