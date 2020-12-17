//
//  main.swift
//  day16
//
//  Created by Mark Johnson on 12/15/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Rule {
    let name: String
    let first: ClosedRange<Int>
    let second: ClosedRange<Int>

    init( input: Substring ) {
        let bones = input.split( separator: ":" )
        let fields = bones[1].split(whereSeparator: { " -".contains( $0 ) } )
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
        return badOnes.reduce( 0 ) { $0 + $1 }
    }
    
    func part2( myTicket: Ticket, tickets: [Ticket] ) -> Int {
        var forwardMapping = [ String : Int ]()
        var reverseMapping = Array( repeating: Set( rules.map { $0.name } ), count: rules.count )
        
        for ticket in tickets {
            if invalidScore( ticket: ticket ) == nil {
                for ( index, value ) in ticket.values.enumerated() {
                    for rule in rules {
                        if !rule.isValid( field: value ) {
                            reverseMapping[index].remove( rule.name )
                        }
                    }
                }
            }
        }
        
        while let index = reverseMapping.firstIndex( where: { $0.count == 1 } ) {
            let name = reverseMapping[index].first!
            forwardMapping[name] = index
            reverseMapping = reverseMapping.map { $0.subtracting( [ name ] ) }
        }
        
        return forwardMapping.filter { $0.key.hasPrefix( "departure" ) }.reduce( 1 ) {
            $0 * myTicket.values[$1.value]
        }
    }
}

struct Ticket {
    let values: [Int]
    
    init( input: Substring ) {
        values = input.split( separator: "," ).map { Int( $0 )! }
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day16.txt"
let sections = try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" )
let rules = RuleSet( rules: sections[0].split( separator: "\n" ).map { Rule( input: $0 ) } )
let myTicket = Ticket( input: sections[1].split(separator: "\n" ).last! )
let tickets = sections[2].split(separator: "\n" ).dropFirst().map { Ticket( input: $0 ) }

print( "Part 1: \(tickets.reduce( 0 ) { $0 + ( rules.invalidScore( ticket: $1 ) ?? 0 ) })" )
print( "Part 2: \(rules.part2( myTicket: myTicket, tickets: tickets ))" )
