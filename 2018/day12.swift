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
    var pots: [UInt] = []
    var range = 0
    var potBase = 0
    
    init( initial: String ) {
        pots = []
        range = 0
        potBase = 0
        initial.reversed().forEach { extendOnRight( value: ( $0 == "#" ) ? 1 : 0 ) }
        potBase = 0
    }
    
    init( from other: Pots ) {
        pots = other.pots
        range = other.range
        potBase = other.potBase
    }
    
    func copy( from other: Pots ) {
        pots = other.pots
        range = other.range
        potBase = other.potBase
    }
    
    func hashKey() -> String {
        return pots.map( { String( $0 ) } ).joined( separator: "," )
    }
    
    func extendOnRight( value: UInt ) -> Void {
        shiftLeft( count: 1 )
        pots[0] |= value & 1
    }
    
    func extendOnLeft( count: Int ) -> Void {
        if range % UInt.bitWidth == 0 || range % UInt.bitWidth + count > UInt.bitWidth {
            pots.append( 0 )
        }
        range += count
    }
    
    func shiftLeft( count: Int ) -> Void {
        extendOnLeft( count: count )
        if pots.count > 1 {
            for i in ( 1 ..< pots.count ).reversed() {
                pots[i] = ( pots[i] << count ) | ( pots[i-1] >> ( UInt.bitWidth - count ) )
            }
        }
        pots[0] <<= count
        potBase -= count
    }
    
    func shiftRight( count: Int ) -> Void {
        if range % UInt.bitWidth == 0 || range % UInt.bitWidth + count > UInt.bitWidth {
            pots.append( 0 )
        }
        if pots.count > 1 {
            for i in 0 ..< pots.count - 1 {
                pots[i] = ( pots[i] >> count ) | ( pots[i+1] << ( UInt.bitWidth - count ) )
            }
        }
        pots[ pots.count - 1 ] >>= count
        range -= count
        if range / UInt.bitWidth < pots.count - 1 {
            pots.removeLast()
        }
        potBase += count
    }
    
    func potIsLive( potNumber: Int ) -> Bool {
        guard 0 <= potNumber && potNumber < range else { return false }
        
        let index = potNumber / UInt.bitWidth
        let bit = potNumber % UInt.bitWidth
        
        return ( pots[index] >> bit ) & 1 == 1
    }
    
    func potSet( potNumber: Int, to: UInt ) -> Void {
        guard -2 <= potNumber && potNumber < range + 2 else {
            print( "Pot number \(potNumber) is out of range" )
            exit( 1 )
        }
        
        let index = potNumber / UInt.bitWidth
        let bit = potNumber % UInt.bitWidth
        let mask = UInt( 1 ) << bit
        let value = ( to & 1 ) << bit
        
        pots[index] = pots[index] & ~mask | value
    }
    
    func normalize() -> Void {
        if let potNumber = ( 0 ..< range ).first( where: { potIsLive( potNumber: $0 ) } ) {
            shiftRight( count: potNumber )
        } else {
            pots = []
            range = 0
            potBase = 0
            return
        }
        
        if let potNumber = ( 0 ..< range ).reversed().first( where: { potIsLive( potNumber: $0 ) } ) {
            range = potNumber + 1
        }
    }
    
    func region( potNumber: Int ) -> UInt {
        var region: UInt = 0
        
        for pot in ( potNumber - 2 ... potNumber + 2 ).reversed() {
            region <<= 1
            region |= potIsLive( potNumber: pot ) ? 1 : 0
        }
        
        return region
    }
    
    func sumLive() -> Int {
        let live = ( 0 ..< range ).filter { potIsLive( potNumber: $0 ) }
        
        return live.reduce( 0, { $0 + $1 + potBase } )
    }
    
    func printGeneration( generation: Int ) -> Void {
        var representation = ( -5 ..< range + 5 ).map { potIsLive( potNumber: $0 ) ? "#" : "." }.joined()
        
        if potBase < 0 {
            representation.removeFirst( -potBase )
        } else if potBase > 0 {
            representation = String( repeating: ".", count: potBase ) + representation
        }
        print( String( format: "%2d: \(representation)", arguments: [generation] ) )
    }
}


func generations( pots: Pots, rules: Set<UInt>, count: Int ) -> Int {
    var seen = [ pots.hashKey() : ( generation: 0, potBase: pots.potBase ) ]
    
    for generation in 1 ... count {
        let nextGeneration = Pots( from: pots )
        
        // Process existing range and extend range to the right
        nextGeneration.extendOnLeft( count: 2 )
        for potNumber in 0 ..< pots.range + 2 {
            let region = pots.region( potNumber: potNumber )
            
            nextGeneration.potSet( potNumber: potNumber, to: rules.contains( region ) ? 1 : 0 )
        }
        
        // Extend range to the left
        let regionLeft1 = pots.region( potNumber: -1 )
        let regionLeft2 = pots.region( potNumber: -2 )
        
        nextGeneration.extendOnRight( value: rules.contains( regionLeft1 ) ? 1 : 0 )
        nextGeneration.extendOnRight( value: rules.contains( regionLeft2 ) ? 1 : 0 )

        nextGeneration.normalize()
        pots.copy( from: nextGeneration )
        // if generation > 152 { pots.printGeneration( generation: generation ) }
        
        if let last = seen[ pots.hashKey() ] {
            let cycle = generation - last.generation
            let deltaPotBase = pots.potBase - last.potBase
            let generationsRemaing = count - generation
            let cycles = generationsRemaing / cycle
            let residual = generationsRemaing % cycle
            
            if residual != 0 {
                print( "Can't handle partial cycles!" )
                exit( 1 )
            }
            pots.potBase += cycles * deltaPotBase
            break
            
        } else {
            seen[ pots.hashKey() ] = ( generation: generation, potBase: pots.potBase )
        }
    }

    return pots.sumLive()
}


func parse( input: AOCinput ) -> ( pots: Pots, rules: Set<UInt> ) {
    let words = input.lines[0].components( separatedBy: " " )
    let pots = Pots( initial: words[2] )
    var rules = Set<UInt>()

    for line in input.lines[2...] {
        let words = line.split( separator: " " )
        
        if words[2] == "#" {
            var pattern: UInt = 0

            for pot in words[0].reversed() {
                pattern <<= 1
                if pot == "#" { pattern |= 1 }
            }
            rules.insert( pattern )
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
