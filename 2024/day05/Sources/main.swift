//
//         FILE: day05.swift
//  DESCRIPTION: Advent of Code 2024 Day 5: Print Queue
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/24 22:52:49
//

import Foundation
import Library

struct Rule {
    let before: Int
    let after: Int
    
    init( line: String ) {
        let numbers = line.split( separator: "|" ).map { Int( $0 )! }
        before = numbers[0]
        after = numbers[1]
    }
}


struct Update {
    let pages: [Int]
    
    init( pages: [Int] ) {
        self.pages = pages
    }
    
    init( line: String ) {
        pages = line.split( separator: "," ).map { Int( $0 )! }
    }
    
    func swap( index1: Int, index2: Int ) -> Update {
        var newPages = pages
        
        newPages[index1] = pages[index2]
        newPages[index2] = pages[index1]
        return Update( pages: newPages )
    }
}


func order( update: Update, ruleBook: [ Int : Set<Int> ] ) -> Update {
    var updated = update
    
    for index1 in updated.pages.indices.dropLast() {
        for index2 in index1 + 1 ..< updated.pages.count {
            let afterSet = ( ruleBook[ update.pages[index2] ] ?? Set<Int>() )
            if afterSet.contains( updated.pages[index1] ) {
                updated = updated.swap( index1: index1, index2: index2 )
                return order( update: updated, ruleBook: ruleBook )
            }
        }
    }
    
    return update
}


func parse( input: AOCinput ) -> ( [ Int : Set<Int> ], [Update] ) {
    let rules = input.paragraphs[0].map { Rule( line: $0 ) }
    let updates = input.paragraphs[1].map { Update( line: $0 ) }
    let ruleBook = rules.reduce( into: [ Int : Set<Int> ]() ) { ruleBook, rule in
        ruleBook[ rule.before, default: Set<Int>() ].insert( rule.after )
    }

    return ( ruleBook, updates )
}


func part1( input: AOCinput ) -> String {
    let ( ruleBook, updates ) = parse( input: input )
    let ordered = updates.filter { update in
        update.pages.indices.dropLast().allSatisfy { index in
            let afterSet = ( ruleBook[ update.pages[index+1] ] ?? Set<Int>() )
            return !afterSet.contains( update.pages[index] )
        }
    }
    let result = ordered.reduce( 0 ) { $0 + $1.pages[ $1.pages.count / 2 ] }

    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let ( ruleBook, updates ) = parse( input: input )
    let unordered = updates.filter { update in
        update.pages.indices.dropLast().contains { index in
            let afterSet = ( ruleBook[ update.pages[index+1] ] ?? Set<Int>() )
            return afterSet.contains( update.pages[index] )
        }
    }
    let ordered = unordered.map { order( update: $0, ruleBook: ruleBook ) }
    let result = ordered.reduce( 0 ) { $0 + $1.pages[ $1.pages.count / 2 ] }

    return "\(result)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
