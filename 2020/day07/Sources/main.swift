//
//         FILE: main.swift
//  DESCRIPTION: day07 - Handy Haversacks
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/24/21 18:01:36
//

import Foundation
import Library

struct BagRule {
    struct Content {
        let color: String
        let quantity: Int
    }
    
    let color: String
    let contents: [Content]
    
    init( input: String ) {
        let words = input.split( separator: " " )
        
        color = "\(words[0]) \(words[1])"
        if words[4] == "no" {
            contents = []
        } else {
            contents = stride( from: 4, to: words.count, by: 4 ).map {
                Content( color: "\(words[$0+1]) \(words[$0+2])", quantity: Int( words[$0] )! )
            }
        }
    }
}


func ancestors( parents: [String : Set<String>], color: String ) -> Set<String> {
    guard let results = parents[color] else { return Set() }
    
    return results.reduce( into: results ) { $0.formUnion( ancestors( parents: parents, color: $1 ) ) }
}


func containsCount( children: [ String : [BagRule.Content] ], color: String ) -> Int {
    guard let kids = children[color] else { return 0 }
    
    return  kids.reduce( 0 ) {
        $0 + $1.quantity * ( 1 + containsCount( children: children, color: $1.color ) )
    }
}


func parse( input: AOCinput ) -> [BagRule] {
    return input.lines.map { BagRule( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let rules = parse( input: input )
    let parents = rules.reduce( into: [ String : Set<String> ]() ) { dict, rule in
        rule.contents.forEach { dict[ $0.color, default: Set() ].insert( rule.color ) }
    }

    return "\( ancestors( parents: parents, color: "shiny gold" ).count )"
}


func part2( input: AOCinput ) -> String {
    let rules = parse( input: input )
    let children = rules.reduce( into: [ String : [BagRule.Content] ]() ) { $0[$1.color] = $1.contents }
    
    return "\( containsCount( children: children, color: "shiny gold" ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
