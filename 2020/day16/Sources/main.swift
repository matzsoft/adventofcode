//
//         FILE: main.swift
//  DESCRIPTION: day16 - Ticket Translation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/26/21 17:06:30
//

import Foundation
import Library

struct Rule {
    let name: String
    let first: ClosedRange<Int>
    let second: ClosedRange<Int>

    init( input: String ) {
        let bones = input.split( separator: ":" )
        let fields = bones[1].split( whereSeparator: { " -".contains( $0 ) } )
        name = String( bones[0] )
        first = Int( fields[0] )! ... Int( fields[1] )!
        second = Int( fields[3] )! ... Int( fields[4] )!
    }
    
    func isValid( field: Int ) -> Bool {
        return first.contains( field ) || second.contains( field )
    }
}

struct RuleSet {
    let rules: [Rule]
    
    func invalidScore( ticket: Ticket ) -> Int? {
        let badOnes = ticket.values.filter { value in rules.allSatisfy { !$0.isValid( field: value ) } }
        
        if badOnes.count == 0 { return nil }
        return badOnes.reduce( 0, + )
    }
    
    func part2( myTicket: Ticket, tickets: [Ticket] ) -> Int {
        let validTickets = tickets.filter { invalidScore( ticket: $0 ) == nil }
        let allRules = Set( rules.map { $0.name } )
        let reverseMapping = validTickets.reduce( into: [ Int : Set<String> ]() ) { dict, ticket in
            ticket.values.enumerated().forEach { field in
                rules.forEach { rule in if !rule.isValid( field: field.element ) {
                    dict[ field.offset ] =
                        dict[ field.offset, default: allRules ].subtracting( [ rule.name ] )
                } }
            }
        }.sorted { $0.value.count < $1.value.count }
        let forwardMapping = reverseMapping.reduce( into: [ String : Int ]() ) { dict, selected in
            let name = selected.value.first( where: { dict[$0] == nil } )!
            dict[name] = selected.key
        }
        
        return forwardMapping.filter { $0.key.hasPrefix( "departure" ) }.reduce( 1 ) {
            $0 * myTicket.values[$1.value]
        }
    }
}

struct Ticket {
    let values: [Int]
    
    init( input: String ) {
        values = input.split( separator: "," ).map { Int( $0 )! }
    }
}


func parse( input: AOCinput ) -> ( RuleSet, Ticket, [Ticket] ) {
    let rules = RuleSet( rules: input.paragraphs[0].map { Rule( input: $0 ) } )
    let myTicket = Ticket( input: input.paragraphs[1].last! )
    let tickets = input.paragraphs[2].dropFirst().map { Ticket( input: $0 ) }

    return ( rules, myTicket, tickets )
}


func part1( input: AOCinput ) -> String {
    let ( rules, _, tickets ) = parse( input: input )
    return "\( tickets.reduce( 0 ) { $0 + ( rules.invalidScore( ticket: $1 ) ?? 0 ) } )"
}


func part2( input: AOCinput ) -> String {
    let ( rules, myTicket, tickets ) = parse( input: input )
    return "\( rules.part2( myTicket: myTicket, tickets: tickets ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
