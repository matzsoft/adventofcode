//
//         FILE: day19.swift
//  DESCRIPTION: Advent of Code 2023 Day 19: Aplenty
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/18/23 21:00:02
//

import Foundation
import Library

struct Condition {
    let category: Character
    let operation: Character
    let value: Int
    
    init( string: any StringProtocol ) {
        let characters = Array( string )
        
        category = characters[0]
        operation = characters[1]
        
        guard let value = Int( String( characters[2...] ) ) else {
            fatalError( "Condition '\(string)' failed to recognize." )
        }
        self.value = value
    }
}


struct Rule {
    let condition: Condition?
    let destination: String
    
    init( condition: Condition?, destination: String ) {
        self.condition = condition
        self.destination = destination
    }
    
    init( string: any StringProtocol ) {
        let words = string.split( separator: ":" )
        
        if words.count == 1 {
            condition = nil
            destination = String( words[0] )
        } else {
            condition = Condition(string: words[0] )
            destination = String( words[1] )
        }
    }
    
    func process( part: Part ) -> String? {
        guard let condition = condition else { return destination }
        if condition.operation == "<" {
            if part.ratings[condition.category]! < condition.value { return destination }
        } else if condition.operation == ">" {
            if part.ratings[condition.category]! > condition.value { return destination }
        } else {
            fatalError( "Bad operation \(condition.operation) in condition")
        }
        
        return nil
    }
    
    func replacing( _ old: String, with new: String ) -> Rule {
        guard destination == old else { return self }
        return Rule( condition: condition, destination: new )
    }
}


struct Workflow {
    let name: String
    let rules: [Rule]
    let from: Set<String>
    let to: Set<String>
    
    init( name: String, rules: [Rule], from: Set<String>, to: Set<String> ) {
        self.name = name
        self.rules = rules
        self.from = from
        self.to = to
    }
    
    init( line: String ) {
        let words = line.split( whereSeparator: { "{,}".contains( $0 ) } )
        
        name = String( words[0] )
        rules = words[1...].map { Rule( string: $0 ) }
        from = []
        to = Set( rules.map { $0.destination } )
    }
    
    func process( part: Part ) -> String {
        for rule in rules {
            if let destination = rule.process( part: part ) { return destination }
        }
        fatalError( "No destination for workflow." )
    }
    
    func replacing( _ old: String, with new: String ) -> Workflow {
        let newRules = rules.map { $0.replacing( old, with: new ) }
        let newTo = to.subtracting( [ old ] ).union( [ new ] )
        return Workflow( name: name, rules: newRules, from: from, to: newTo )
    }
    
    func insert( from: String ) -> Workflow {
        let newFrom = self.from.union( [ from ] )
        return Workflow( name: name, rules: rules, from: newFrom, to: to )
    }
}


struct Part {
    let ratings: [ Character : Int ]
    
    var rating: Int { ratings.values.reduce( 0, + ) }
    
    init( line: String ) {
        let ratings = line.split( whereSeparator: { "{,}".contains( $0 ) } ).map { Array( $0 ) }
        
        self.ratings = ratings.reduce( into: [ Character : Int ]() ) {
            $0[ $1[0] ] = Int( String( $1[2...] ) )
        }
    }
    
    func isAccepted( workflows: [ String : Workflow ] ) -> Bool {
        var next = "in"
        
        while next != "A" && next != "R" {
            next = workflows[next]!.process( part: self )
        }
        
        return next == "A"
    }
}


struct Node {
    var from: Set<String>
    var to: Set<String>
}


func parse( input: AOCinput ) -> ( [ String : Workflow ], [Part] ) {
    let parts = input.paragraphs[1].map { Part( line: $0 ) }
    let workflows = input.paragraphs[0].map { Workflow( line: $0 ) } + [
        Workflow( name: "A", rules: [], from: [], to: [] ),
        Workflow( name: "R", rules: [], from: [], to: [] ),
    ]
    var wfDictionary = Dictionary( uniqueKeysWithValues: workflows.map { ( $0.name, $0 ) } )

    for ( name, node ) in wfDictionary {
        for to in node.to {
            wfDictionary[to] = wfDictionary[to]!.insert( from: name )
        }
    }

    while let workflow = wfDictionary.first( where: { $0.value.to.count == 1 } ) {
        for from in workflow.value.from {
            wfDictionary[from] = wfDictionary[from]!.replacing(
                workflow.key, with: workflow.value.to.first! )
        }
        wfDictionary.removeValue( forKey: workflow.key )
    }
    
    return ( wfDictionary, parts )
}


func part1( input: AOCinput ) -> String {
    let ( workflows, parts ) = parse( input: input )
    
    for ( name, node ) in workflows.sorted( by: { $0.key < $1.key } ) {
        print( name )
        print( "   to: \( node.to.sorted().joined(separator: ", " ) )" )
        print( "   from: \( node.from.sorted().joined(separator: ", " ) )" )
    }
    
    let accepted = parts.filter { $0.isAccepted( workflows: workflows ) }
    let ratings = accepted.map { $0.rating }

    return "\( ratings.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let ( workflows, _ ) = parse( input: input )
    let ratingRange = 1 ... 4000
    
    // TODO: transfer this network construction and simplification into parse
    var network = workflows.values.reduce( into: [ String: Node ]() ) { network, workflow in
        network[ workflow.name ] = Node( from: [], to: Set( workflow.rules.map { $0.destination } ) )
    }
    
    network["A"] = Node( from: [], to: [] )
    network["R"] = Node( from: [], to: [] )
    for ( name, node ) in network {
        for to in node.to {
            network[to]!.from.insert( name )
        }
    }
    
    while let workflow = network.first( where: { $0.value.to.count == 1 } ) {
        for from in workflow.value.from {
            network[from]!.to.remove( workflow.key )
            network[from]!.to.insert( workflow.value.to.first! )
        }
        network.removeValue( forKey: workflow.key )
    }
    
    for ( name, node ) in network.sorted( by: { $0.key < $1.key } ) {
        print( name )
        print( "   to: \( node.to.sorted().joined(separator: ", " ) )" )
        print( "   from: \( node.from.sorted().joined(separator: ", " ) )" )
    }
    
    var queue = [ "in" ]
    var seen = Set<String>()
    
    while !queue.isEmpty {
        let workflow = queue.removeFirst()
        let start = Int( pow( Double( ratingRange.upperBound ), 4 ) )
    }
    
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
