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

enum Card: Character, CaseIterable {
    case two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8"
    case nine = "9", ten = "T", jack = "J", queen = "Q", king = "K", ace = "A"
    
    func strength( wildcards: Bool = false ) -> Int {
        if !wildcards { return Self.allCases.firstIndex { $0 == self }! }
        
        return self == .jack ? 0 : Self.allCases.firstIndex { $0 == self }! + 1
    }
    
    var strength: Int {
        Self.allCases.firstIndex { $0 == self }!
    }
}

enum HandType: Int, CaseIterable {
    case highCard, onePair, twoPair, threeOfOneKind, fullHouse, fourOfOneKind, fiveOfOneKind
}


struct Hand {
    let cards: [Card]
    let bid: Int
    
    init( line: String ) {
        let words = line.split( separator: " " )
        
        cards = Array( words[0] ).map { Card( rawValue: $0 )! }
        bid = Int( words[1] )!
    }
    
    static func areIncreasing( lhs: Hand, rhs: Hand, wildcards: Bool = false ) -> Bool {
        let different = lhs.cards.indices.first { lhs.cards[$0].strength != rhs.cards[$0].strength }!
        let leftStrength = lhs.cards[different].strength( wildcards: wildcards )
        let rightStrength = rhs.cards[different].strength( wildcards: wildcards )
        return leftStrength < rightStrength
    }
    
    func type( wildcards: Bool = false ) -> HandType {
        let histogram = cards.reduce(into: [ Card : Int ]() ) { $0[ $1, default: 0 ] += 1 }

        switch histogram.count {
        case 1:
            return .fiveOfOneKind
        case 2:
            let values = Array( histogram.values )
            guard wildcards else {
                return values.contains( where: { $0 == 4 } ) ? .fourOfOneKind : .fullHouse
            }
            if values.contains( where: { $0 == 4 } ) {
                return histogram[.jack] == nil ? .fourOfOneKind : .fiveOfOneKind
            }
            return histogram[.jack] == nil ? .fullHouse : .fiveOfOneKind
        case 3:
            let values = Array( histogram.values )
            guard wildcards else {
                return values.contains( where: { $0 == 3 } ) ? .threeOfOneKind : .twoPair
            }
            if values.contains( where: { $0 == 3 } ) {
                return histogram[.jack] == nil ? .threeOfOneKind : .fourOfOneKind
            }
            if histogram[.jack] == nil { return .twoPair }
            return histogram[.jack] == 1 ? .fullHouse : .fourOfOneKind
        case 4:
            return !wildcards || histogram[.jack] == nil ? .onePair : .threeOfOneKind
        case 5:
            return !wildcards || histogram[.jack] == nil ? .highCard : .onePair
        default:
            fatalError( "Bogus hand." )
        }
    }
}


func parse( input: AOCinput ) -> [Hand] {
    return input.lines.map { Hand( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let hands = parse( input: input )
    let initial = Array( repeating: [Hand](), count: HandType.allCases.count )
    let types = hands
        .reduce( into: initial ) { $0[ $1.type().rawValue ].append( $1 ) }
        .filter { !$0.isEmpty }
        .map { $0.sorted( by: { Hand.areIncreasing( lhs: $0, rhs: $1 ) } ) }
        .flatMap { $0 }
    
    return "\( types.indices.reduce( 0 ) { $0 + ( $1 + 1 ) * types[$1].bid } )"
}


func part2( input: AOCinput ) -> String {
    let hands = parse( input: input )
    let initial = Array( repeating: [Hand](), count: HandType.allCases.count )
    let types = hands
        .reduce( into: initial ) { $0[ $1.type( wildcards: true ).rawValue ].append( $1 ) }
        .filter { !$0.isEmpty }
        .map { $0.sorted( by: { Hand.areIncreasing( lhs: $0, rhs: $1, wildcards: true ) } ) }
        .flatMap { $0 }
    
    return "\( types.indices.reduce( 0 ) { $0 + ( $1 + 1 ) * types[$1].bid } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
