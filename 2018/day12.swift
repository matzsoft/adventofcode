//
//         FILE: main.swift
//  DESCRIPTION: day12 - Subterranean Sustainability
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/20/21 13:30:47
//

import Foundation

class Pots {
    var pots = [Character]()
    var range = 0 ..< 0
    
    var potBase: Int { range.startIndex }
    
    init( initial: String ) {
        pots = Array( initial )
        range = 0 ..< initial.count
    }
    
    init( from other: Pots ) {
        pots = other.pots
        range = other.range
    }
    
    func copy( from other: Pots ) {
        pots = other.pots
        range = other.range
    }

    subscript( index: Int ) -> Character {
        get {
            guard range.contains( index ) else { return "." }
            return pots[ index - range.startIndex ]
        }
        set( newValue ) {
            if range.contains( index ) { pots[ index - range.startIndex ] = newValue }
        }
    }

    func hashKey() -> String {
        return String( pots )
    }
    
    func extendOnRight( count: Int ) -> Void {
        pots.append( contentsOf: Array( repeating: ".", count: count ) )
        range = range.startIndex ..< range.endIndex + count
    }
    
    func extendOnLeft( count: Int ) -> Void {
        pots.insert( contentsOf: Array( repeating: ".", count: count ), at: 0 )
        range = range.startIndex - count ..< range.endIndex
    }
    
    func potIsLive( potNumber: Int ) -> Bool {
        return self[potNumber] == "#"
    }
    
    func normalize() -> Void {
        guard let newLeft = pots.firstIndex( where: { $0 == "#" } ) else {
            self.copy( from: Pots( initial: "" ) )
            return
        }
        
        let newRight = pots.lastIndex( where: { $0 == "#" } )!
        let newRange = newLeft + range.startIndex ..< newRight + range.startIndex + 1
        
        pots.removeFirst( newRange.startIndex - range.startIndex )
        pots.removeLast( range.endIndex - newRange.endIndex )
        range = newRange
    }
    
    func region( potNumber: Int ) -> String {
        return String( ( potNumber - 2 ... potNumber + 2 ).map { self[$0] } )
    }
    
    func sumLive() -> Int {
        return range.filter { potIsLive( potNumber: $0 ) }.reduce( 0, + )
    }
    
    func printGeneration( generation: Int ) -> Void {
        let representation = range.map { potIsLive( potNumber: $0 ) ? "#" : "." }.joined()

        print("    \(range.startIndex) - \(range.endIndex - 1)")
        print( String( format: "%2d: \(representation)", arguments: [generation] ) )
    }
}


func generations( pots: Pots, rules: Set<String>, count: Int ) -> Int {
    var seen = [ pots.hashKey() : ( generation: 0, potBase: pots.potBase ) ]
    
    for generation in 1 ... count {
        pots.extendOnLeft( count: 2 )
        pots.extendOnRight( count: 2 )
        
        let nextGeneration = Pots( from: pots )

        for potNumber in pots.range {
            let region = pots.region( potNumber: potNumber )
            
            nextGeneration[potNumber] = rules.contains( region ) ? "#" : "."
        }
        nextGeneration.normalize()
        
        pots.copy( from: nextGeneration )
        // if generation > 152 { pots.printGeneration( generation: generation ) }

        if let last = seen[ pots.hashKey() ] {
            let cycle = generation - last.generation
            let deltaPotBase = pots.potBase - last.potBase
            let generationsRemaing = count - generation
            let cycles = generationsRemaing / cycle
            let residual = generationsRemaing % cycle
            let delta = cycles * deltaPotBase
            
            if residual != 0 {
                print( "Can't handle partial cycles!" )
                exit( 1 )
            }
            pots.range = pots.range.startIndex + delta ..< pots.range.endIndex + delta
            break
            
        } else {
            seen[ pots.hashKey() ] = ( generation: generation, potBase: pots.potBase )
        }
    }

    return pots.sumLive()
}


func parse( input: AOCinput ) -> ( pots: Pots, rules: Set<String> ) {
    let words = input.lines[0].components( separatedBy: " " )
    let pots = Pots( initial: words[2] )
    var rules = Set<String>()

    for line in input.lines[2...] {
        let words = line.components( separatedBy: " " )
        
        if words[2] == "#" {
            rules.insert( words[0] )
        }
    }
    
    return ( pots: pots, rules: rules )
}


func part1( input: AOCinput ) -> String {
    let ( pots, rules ) = parse( input: input )
    return "\(generations( pots: pots, rules: rules, count: 20 ))"
}


func part2( input: AOCinput ) -> String {
    let ( pots, rules ) = parse( input: input )
    return "\(generations( pots: pots, rules: rules, count: 50000000000 ))"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
