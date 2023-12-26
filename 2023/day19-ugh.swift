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

let ratingRange = 1 ..< 4001
let categories = "xmas"

extension Range<Int> {
    func subtracting( other: Range<Int> ) -> [Range<Int>] {
        if other.contains( self ) { return [] }
        if clamped( to: other ).isEmpty { return [self] }

        var result = [Range<Int>]()
        if lowerBound < other.lowerBound { result.append( lowerBound ..< other.lowerBound ) }
        if upperBound > other.upperBound { result.append( other.upperBound ..< upperBound ) }

        return result
    }
    
    func contains( _ other: Range<Int> ) -> Bool {
        lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }
}


struct Condition {
    let category: Character
    let range: Range<Int>
    
    init( string: any StringProtocol ) {
        let characters = Array( string )
        
        category = characters[0]
        guard let value = Int( String( characters[2...] ) ) else {
            fatalError( "Condition '\(string)' failed to recognize." )
        }

        if characters[1] == "<" {
            range = 1 ..< value
        } else if characters[1] == ">" {
            range = ( value + 1 ..< Int.max ).clamped( to: ratingRange )
        } else {
            fatalError( "Invalid operation '\(characters[1]) in rule.")
        }
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
        if condition.range.contains( part.ratings[condition.category]! ) { return destination }
        
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


struct Precondition {
    let preconditions: [ Character : Range<Int> ]
    
    static var empty: Precondition {
        let dict = Dictionary( uniqueKeysWithValues: Array( categories ).map { ( $0, 1 ..< 1) } )
        return Precondition( preconditions: dict )
    }
    
    static var full: Precondition {
        let dict = Dictionary( uniqueKeysWithValues: Array( categories ).map { ( $0, ratingRange) } )
        return Precondition( preconditions: dict )
    }
    
    subscript( category: Character ) -> Range<Int>? {
        preconditions[category]
    }
    
    var isEmpty: Bool {
        preconditions.values.contains { $0.isEmpty }
    }
    
    func merge( leave: Rule ) -> Precondition {
        guard let condition = leave.condition else { return self }
        guard preconditions[condition.category] != nil else { fatalError( "Invalid category in rule." ) }
        
        let new =  preconditions.merging( [ condition.category : condition.range ] ) {
            if $0.overlaps( $1 ) { return $0.count < $1.count ? $0 : $1 }
            fatalError( "Non overlapping ranges on leave." )
        }
        return Precondition( preconditions: new )
    }
    
    func merge( stay: Rule ) -> Precondition {
        guard let condition = stay.condition else { return self }
        guard preconditions[condition.category] != nil else { fatalError( "Invalid category in rule." ) }

        let reverseRange = ratingRange.subtracting( other: condition.range )
        let new =  preconditions.merging( [ condition.category : reverseRange ] ) {
            if $0.overlaps( $1 ) { return $0.count < $1.count ? $0 : $1 }
            fatalError( "Non overlapping ranges on stay." )
        }
        return Precondition( preconditions: new )
    }
    
    func subtracting( _ other: Precondition ) -> PreconditionList {
        if categories.allSatisfy( { other.preconditions[$0]!.contains( preconditions[$0]! ) } ) {
            return PreconditionList()
        }
        
        var newDict = Dictionary( uniqueKeysWithValues: categories.map { ( $0, [Range<Int>]() ) } )
        for category in categories {
            guard preconditions[category]!.overlaps( other[category]! ) else {
                return PreconditionList( first: self )
            }
            
            if other.preconditions[category]!.contains( preconditions[category]! ) {
                newDict[category] = [ preconditions[category]! ]
            } else {
                newDict[category] =
                    preconditions[category]!.subtracting( other: other.preconditions[category]! )
            }
        }
        
//        guard preconditions.keys.allSatisfy( { preconditions[$0]!.overlaps( other[$0]! ) } ) else {
//            return self
//        }
//        guard let first = preconditions.keys.first( where: { preconditions[$0] != other[$0] } )
//        else { return Precondition.empty }
//        
//        let otherRange = other[first]!
//        let clamped = preconditions[first]!.clamped( to: otherRange )
//        let newRange = {
//            if otherRange.lowerBound == clamped.lowerBound {
//                return clamped.upperBound ..< otherRange.upperBound
//            }
//            return otherRange.lowerBound ..< clamped.lowerBound
//        }()
//        let newDict = other.preconditions.merging( [ first : newRange ] ) { $1 }
//        
//        return Precondition( preconditions: newDict )
    }
}


struct PreconditionList {
    var preconditions: [Precondition]
    
    init() {
        preconditions = []
    }
    
    init( first: Precondition ) {
        preconditions = [ first ]
    }
    
    mutating func add( new: Precondition ) -> Void {
        if preconditions.isEmpty {
            preconditions.append( new )
            return
        }
        
        var new = new
        for old in preconditions {
            new = new.subtracting( old )
            if new.isEmpty { return }
        }
        
        preconditions.append( new )
    }
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
    
//    for ( name, node ) in workflows.sorted( by: { $0.key < $1.key } ) {
//        print( name )
//        print( "   to: \( node.to.sorted().joined(separator: ", " ) )" )
//        print( "   from: \( node.from.sorted().joined(separator: ", " ) )" )
//    }
    
    let accepted = parts.filter { $0.isAccepted( workflows: workflows ) }
    let ratings = accepted.map { $0.rating }

    return "\( ratings.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let ( workflows, _ ) = parse( input: input )
//    let possibles = Int( pow( Double( ratingRange.upperBound ), 4 ) )
    
//    for ( name, node ) in workflows.sorted( by: { $0.key < $1.key } ) {
//        print( name )
//        print( "   to: \( node.to.sorted().joined(separator: ", " ) )" )
//        print( "   from: \( node.from.sorted().joined(separator: ", " ) )" )
//    }
    
    var queue = [ "in" ]
//    var seen = Set<String>()
    var preconditions = [ "in" : PreconditionList( first: Precondition.full ) ]

    while !queue.isEmpty {
        let workflow = workflows[ queue.removeFirst() ]!
        
        guard preconditions[workflow.name]?.preconditions.count == 1 else {
            fatalError( "\(workflow.name) has \(preconditions[workflow.name]!) preconditions" )
        }
        
        var rollingPreconditions = preconditions[workflow.name]!.preconditions[0]
        
        for rule in workflow.rules {
            let leave = rollingPreconditions.merge( leave: rule )
            
            rollingPreconditions = rollingPreconditions.merge( stay: rule )
            preconditions[rule.destination, default: PreconditionList()].add( new: leave )
            if !workflows[rule.destination]!.to.isEmpty {
                queue.append( rule.destination )
            }
        }
    }
    
    let final = preconditions["A"]!
    for ( index, precondition ) in final.preconditions.enumerated() {
        print(
            "\(index). \( Array( categories ).map { "\($0): \(precondition[$0]!)" }.joined(separator: ", " ) )"
        )
    }
    let sums = preconditions["A"]!.preconditions.map { thisPreconditions in
        let keys = Array( categories )
        return keys.reduce( 1 ) { $0 * ( thisPreconditions[$1]?.count ?? ratingRange.upperBound ) }
    }
    return "\( sums.reduce( 0, + ) )"
}


//func part2( input: AOCinput ) -> String {
//    let ( workflows, _ ) = parse( input: input )
//    let possibles = Int( pow( Double( ratingRange.upperBound ), 4 ) )
//    
////    for ( name, node ) in workflows.sorted( by: { $0.key < $1.key } ) {
////        print( name )
////        print( "   to: \( node.to.sorted().joined(separator: ", " ) )" )
////        print( "   from: \( node.from.sorted().joined(separator: ", " ) )" )
////    }
//    
//    var queue = [ "in" ]
//    var seen = Set<String>()
//    var acceptables = [ "in" : possibles ]
//
//    while !queue.isEmpty {
//        let workflow = queue.removeFirst()
//        var remaining = acceptables[workflow]!
//        for rule in workflows[workflow]!.rules {
//            if let condition = rule.condition {
//                let diverted = condition.range.count * remaining / ratingRange.upperBound
//
//                remaining -= diverted
//                acceptables[ rule.destination, default: 0 ] += diverted
//            } else {
//                acceptables[ rule.destination, default: 0 ] += remaining
//            }
//        }
//        queue.append( contentsOf: workflows[workflow]!.to )
//    }
//    
//    return "\( acceptables["A"]! )"
//}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
