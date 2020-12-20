//
//  main.swift
//  day19
//
//  Created by Mark Johnson on 12/19/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Rule {
    let label: Int
    let alternatives: [[Int]]
    let references: Set<Int>
    let expansions: [Substring]
    
    init( input: Substring ) {
        let fields = input.split( whereSeparator: { ":|".contains( $0 ) } )
        
        label = Int( fields[0] )!
        if fields.count == 2 && fields[1].hasPrefix( " \"" ) {
            alternatives = []
            references = Set()
            expansions = [ fields[1].dropFirst( 2 ).dropLast() ]
        } else {
            alternatives = fields.dropFirst().map { $0.split(separator: " " ).map { Int( $0 )! } }
            references = alternatives.reduce( into: Set<Int>(), { refs, list in
                list.forEach { refs.insert( $0 ) }
            } )
            expansions = []
        }
    }
    
    init( oldRule: Rule, expansions: [Substring] ) {
        label = oldRule.label
        alternatives = oldRule.alternatives
        references = oldRule.references
        self.expansions = expansions
    }
    
    init( oldRule: Rule, addAlternative: [Int] ) {
        label = oldRule.label
        alternatives = oldRule.alternatives + [ addAlternative ]
        references = addAlternative.reduce( into: oldRule.references, { $0.insert( $1 ) } )
        expansions = oldRule.expansions
    }
}

func expandAlternative( rules: [Rule], alternative: [Int] ) -> [Substring] {
    var alternative = alternative
    let first = alternative.removeFirst()
    
    if alternative.isEmpty {
        return rules[first].expansions
    }
    
    let rhs = expandAlternative( rules: rules, alternative: alternative )
    return rules[first].expansions.flatMap { first in rhs.map { first + $0 } }
}

func expandRules( rules: [Rule] ) -> [Rule] {
    var rules = rules
    var complete = rules.reduce( into: Set<Int>(), { if $1.expansions.count > 0 { $0.insert( $1.label ) } } )

    while complete.count < rules.count {
        let candidates = rules.filter {
            !complete.contains( $0.label ) && $0.references.isSubset( of: complete ) }

        guard candidates.count > 0 else { break }
        for candidate in candidates {
            var expansions: [Substring] = []
            for alternative in candidate.alternatives {
                expansions.append( contentsOf: expandAlternative( rules: rules, alternative: alternative ) )
            }
            rules[candidate.label] = Rule( oldRule: candidate, expansions: expansions )
            complete.insert( candidate.label )
        }
    }
    
    return rules
}


func countSuffixes( rules: [Rule], ruleNumber: Int, message: Substring ) -> ( Int, Int ) {
    var mutable = message
    var count = 0
    
    repeat {
        let matches = rules[ruleNumber].expansions.filter { mutable.hasSuffix( $0 ) }
        
        guard matches.count > 0 else { break }
        guard matches.count == 1 else {
            print("\(mutable) has \(matches.count) \(ruleNumber) suffix matches")
            return ( 0, 0 )
        }
        
        mutable.removeLast( matches[0].count )
        count += 1
    } while true
    
    return ( message.count - mutable.count, count )
}


func validate( rules: [Rule], message: Substring ) -> Bool {
    let ( suffixCount, count31 ) = countSuffixes( rules: rules, ruleNumber: 31, message: message )
        
    guard count31 > 0 else { return false }
    
    let revised = message.dropLast( suffixCount )
    let ( prefixCount, count42 ) = countSuffixes( rules: rules, ruleNumber: 42, message: revised )
    
    return count42 > count31 && prefixCount == revised.count
}


func part1( rules: [Rule], messages: [Substring] ) -> Int {
    let rules = expandRules( rules: rules )
    let acceptable = Set( rules[0].expansions )
    
    return messages.filter { acceptable.contains( $0 ) }.count
}


func part2( rules: [Rule], messages: [Substring] ) -> Int {
    var rules = rules
    
    rules[8] = Rule( oldRule: rules[8], addAlternative: [ 42, 8 ] )
    rules[11] = Rule( oldRule: rules[11], addAlternative: [ 42, 11, 31 ] )
    rules = expandRules( rules: rules )
    
    return messages.reduce( 0 ) { $0 + ( validate( rules: rules, message: $1 ) ? 1 : 0 ) }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day19.txt"
let groups =  try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" )
let rules = groups[0].split(separator: "\n" ).map { Rule( input: $0 ) }.sorted { $0.label < $1.label }
let messages = groups[1].split(separator: "\n" )


print( "Part 1: \( part1( rules: rules, messages: messages ) )" )
print( "Part 2: \( part2( rules: rules, messages: messages ) )" )
