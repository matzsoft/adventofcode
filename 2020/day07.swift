//
//  main.swift
//  day07
//
//  Created by Mark Johnson on 12/06/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct BagRule {
    struct Content {
        let color: String
        let quantity: Int
    }
    
    let color: String
    let contents: [Content]
    
    init( input: Substring ) {
        let words = input.split( separator: " " )
        
        color = "\(words[0]) \(words[1])"
        if words[4] == "no" {
            contents = []
        } else {
            var contents = Array<Content>()
            
            for startIndex in stride( from: 4, to: words.count, by: 4 ) {
                let color = "\(words[startIndex+1]) \(words[startIndex+2])"
                contents.append( Content( color: color, quantity: Int( words[startIndex] )! ) )
            }
            self.contents = contents
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


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day07.txt"
let rules = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { BagRule( input: $0 ) }
let children = rules.reduce( into: [ String : [BagRule.Content] ]() ) { $0[$1.color] = $1.contents }
let parents = rules.reduce( into: [String : Set<String>]() ) { dict, rule in
    rule.contents.forEach { content in
        if dict[content.color] == nil {
            dict[content.color] = Set<String>( [ rule.color ] )
        } else {
            dict[content.color]?.insert( rule.color )
        }
    }
}

print( "Part 1: \(ancestors( parents: parents, color: "shiny gold" ).count)" )
print( "Part 2: \(containsCount( children: children, color: "shiny gold" ))" )
