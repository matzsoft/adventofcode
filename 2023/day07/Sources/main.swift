//
//         FILE: day07.swift
//  DESCRIPTION: Advent of Code 2023 Day 7: Camel Cards
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/23 21:00:01
//

import Foundation
import Library

struct Hand {
    enum Card: Character, CaseIterable {
        case two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8"
        case nine = "9", ten = "T", jack = "J", queen = "Q", king = "K", ace = "A"
        
        func strength( wildcards: Bool ) -> Int {
            return wildcards && self == .jack ? -1 : Self.allCases.firstIndex { $0 == self }!
        }
    }

    enum HandType: Int, CaseIterable {
        case highCard, onePair, twoPair, threeOfOneKind, fullHouse, fourOfOneKind, fiveOfOneKind
    }

    let cards: [Card]
    let bid: Int
    
    init( line: String ) {
        let words = line.split( separator: " " )
        
        cards = Array( words[0] ).map { Card( rawValue: $0 )! }
        bid = Int( words[1] )!
    }
    
    static func areIncreasing( lhs: Hand, rhs: Hand, wildcards: Bool ) -> Bool {
        let different = lhs.cards.indices.first {
            lhs.cards[$0].strength( wildcards: wildcards ) != rhs.cards[$0].strength( wildcards: wildcards )
        }!
        let leftStrength = lhs.cards[different].strength( wildcards: wildcards )
        let rightStrength = rhs.cards[different].strength( wildcards: wildcards )
        return leftStrength < rightStrength
    }
    
    func type( wildcards: Bool ) -> HandType {
        let histogram = cards.reduce(into: [ Card : Int ]() ) { $0[ $1, default: 0 ] += 1 }

        switch histogram.count {
        case 1:
            return .fiveOfOneKind
        case 2:
            if histogram.values.contains( where: { $0 == 4 } ) {
                return !wildcards || histogram[.jack] == nil ? .fourOfOneKind : .fiveOfOneKind
            } else {
                return !wildcards || histogram[.jack] == nil ? .fullHouse : .fiveOfOneKind
            }
        case 3:
            if histogram.values.contains( where: { $0 == 3 } ) {
                return !wildcards || histogram[.jack] == nil ? .threeOfOneKind : .fourOfOneKind
            } else {
                return !wildcards || histogram[.jack] == nil
                    ? .twoPair
                    : histogram[.jack] == 1 ? .fullHouse : .fourOfOneKind
            }
        case 4:
            return !wildcards || histogram[.jack] == nil ? .onePair : .threeOfOneKind
        case 5:
            return !wildcards || histogram[.jack] == nil ? .highCard : .onePair
        default:
            fatalError( "Bogus hand." )
        }
    }
}


func totalWinnings( input: AOCinput, wildcards: Bool ) -> Int {
    let initial = Array( repeating: [Hand](), count: Hand.HandType.allCases.count )
    let ranked = input.lines
        .map { Hand( line: $0 ) }
        .reduce( into: initial ) { $0[ $1.type( wildcards: wildcards ).rawValue ].append( $1 ) }
        .filter { !$0.isEmpty }
        .map { $0.sorted( by: { Hand.areIncreasing( lhs: $0, rhs: $1, wildcards: wildcards ) } ) }
        .flatMap { $0 }
    
    return ranked.indices.reduce( 0 ) { $0 + ( $1 + 1 ) * ranked[$1].bid }
}

func part1( input: AOCinput ) -> String {
    return String( totalWinnings( input: input, wildcards: false ) )
}


func part2( input: AOCinput ) -> String {
    return String( totalWinnings( input: input, wildcards: true ) )
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
