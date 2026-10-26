//
//         FILE: main.swift
//  DESCRIPTION: day19 - Monster Messages
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/29/21 13:43:36
//

import Foundation
import Library

struct Rule {
    let label: Int
    let alternatives: [[Int]]
    let references: Set<Int>
    let expansions: [String]
    
    init( input: String ) {
        let fields = input.split( whereSeparator: { ":|".contains( $0 ) } )
        
        label = Int( fields[0] )!
        if fields.count == 2 && fields[1].hasPrefix( " \"" ) {
            alternatives = []
            references = Set()
            expansions = [ String( fields[1].dropFirst( 2 ).dropLast() ) ]
        } else {
            alternatives = fields.dropFirst().map { $0.split(separator: " " ).map { Int( $0 )! } }
            references = alternatives.reduce( into: Set<Int>() ) { refs, list in
                list.forEach { refs.insert( $0 ) }
            }
            expansions = []
        }
    }
    
    init( oldRule: Rule, expansions: [String] ) {
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


func expandAlternative( rules: [ Int : Rule ], alternative: [Int] ) -> [String] {
    var alternative = alternative
    let first = alternative.removeFirst()
    
    if alternative.isEmpty {
        return rules[first]!.expansions
    }
    
    let rhs = expandAlternative( rules: rules, alternative: alternative )
    return rules[first]!.expansions.flatMap { first in rhs.map { first + $0 } }
}


func expandRules( rules: [ Int : Rule ] ) -> [ Int : Rule ] {
    var rules = rules
    var complete = rules.reduce( into: Set<Int>() ) {
        if $1.value.expansions.count > 0 { $0.insert( $1.value.label ) }
    }

    while complete.count < rules.count {
        let candidates = rules.filter {
            !complete.contains( $0.value.label ) && $0.value.references.isSubset( of: complete )
        }

        guard candidates.count > 0 else { break }
        for candidate in candidates {
            var expansions: [String] = []
            for alternative in candidate.value.alternatives {
                expansions.append( contentsOf: expandAlternative( rules: rules, alternative: alternative ) )
            }
            rules[candidate.value.label] = Rule( oldRule: candidate.value, expansions: expansions )
            complete.insert( candidate.value.label )
        }
    }
    
    return rules
}


func countSuffixes( rules: [ Int : Rule ], ruleNumber: Int, message: String ) -> ( Int, Int ) {
    var mutable = message
    var count = 0
    
    repeat {
        let matches = rules[ruleNumber]!.expansions.filter { mutable.hasSuffix( $0 ) }
        
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


func validate( rules: [ Int : Rule ], message: String ) -> Bool {
    let ( suffixCount, count31 ) = countSuffixes( rules: rules, ruleNumber: 31, message: message )
        
    guard count31 > 0 else { return false }
    
    let revised = String( message.dropLast( suffixCount ) )
    let ( prefixCount, count42 ) = countSuffixes( rules: rules, ruleNumber: 42, message: revised )
    
    return count42 > count31 && prefixCount == revised.count
}


func parse( input: AOCinput ) -> ( [ Int : Rule ], [String] ) {
    let rules = input.paragraphs[0].reduce( into: [ Int : Rule ]() ) { dict, line in
        let rule = Rule( input: line )
        dict[rule.label] = rule
    }
    
    return ( rules, input.paragraphs[1] )
}


func part1( input: AOCinput ) -> String {
    let ( rules, messages ) = parse( input: input )
    let expandedRules = expandRules( rules: rules )
    let acceptable = Set( expandedRules[0]!.expansions )
    
    return "\( messages.filter { acceptable.contains( $0 ) }.count )"
}


func part2( input: AOCinput ) -> String {
    let ( originalRules, messages ) = parse( input: input )
    var rules = originalRules
    
    rules[8] = Rule( oldRule: rules[8]!, addAlternative: [ 42, 8 ] )
    rules[11] = Rule( oldRule: rules[11]!, addAlternative: [ 42, 11, 31 ] )
    rules = expandRules( rules: rules )
    
    return "\( messages.reduce( 0 ) { $0 + ( validate( rules: rules, message: $1 ) ? 1 : 0 ) } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
