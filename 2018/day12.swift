//
//  main.swift
//  day12
//
//  Created by Mark Johnson on 12/11/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
initial state: ##.#############........##.##.####..#.#..#.##...###.##......#.#..#####....##..#####..#.#.##.#.##

###.# => #
.#### => #
#.### => .
.##.. => .
##... => #
##.## => #
.#.## => #
#.#.. => #
#...# => .
...## => #
####. => #
#..## => .
#.... => .
.###. => .
..#.# => .
..### => .
#.#.# => #
..... => .
..##. => .
##.#. => #
.#... => #
##### => .
###.. => #
..#.. => .
##..# => #
#..#. => #
#.##. => .
....# => .
.#..# => #
.#.#. => #
.##.# => .
...#. => .
"""
let testInput = """
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
"""
let lines = input.split(separator: "\n")

class Pots {
    var pots: [UInt] = []
    var range = 0
    var potBase = 0
    
    init() {
        pots = []
        range = 0
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
        return pots.map( { String($0) } ).joined(separator: ",")
    }
    
    func parse( initial: Substring ) -> Void {
        pots = []
        range = 0
        initial.reversed().forEach { extendOnRight( value: ( $0 == "#" ) ? 1 : 0 ) }
        potBase = 0
    }
    
    func extendOnRight( value: UInt ) -> Void {
        shiftLeft(count: 1)
        pots[0] |= value & 1
    }
    
    func extendOnLeft( count: Int ) -> Void {
        if range % UInt.bitWidth == 0 || range % UInt.bitWidth + count > UInt.bitWidth {
            pots.append(0)
        }
        range += count
    }
    
    func shiftLeft( count: Int ) -> Void {
        extendOnLeft(count: count)
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
            pots.append(0)
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
            exit(1)
        }
        
        let index = potNumber / UInt.bitWidth
        let bit = potNumber % UInt.bitWidth
        let mask = UInt(1) << bit
        let value = ( to & 1 ) << bit
        
        pots[index] = pots[index] & ~mask | value
    }
    
    func normalize() -> Void {
        if let potNumber = ( 0 ..< range ).first( where: { potIsLive( potNumber: $0) } ) {
            shiftRight(count: potNumber)
        } else {
            pots = []
            range = 0
            potBase = 0
            return
        }
        
        if let potNumber = ( 0 ..< range ).reversed().first( where: { potIsLive( potNumber: $0) } ) {
            range = potNumber + 1
        }
    }
    
    func region( potNumber: Int ) -> UInt {
        var region: UInt = 0
        
        for pot in ( potNumber - 2 ... potNumber + 2 ).reversed() {
            region <<= 1
            region |= potIsLive(potNumber: pot) ? 1 : 0
        }
        
        return region
    }
    
    func sumLive() -> Int {
        let live = ( 0 ..< range ).filter { potIsLive( potNumber: $0 ) }
        
        return live.reduce( 0, { $0 + $1 + potBase } )
    }
    
    func printGeneration( generation: Int ) -> Void {
        var representation = ( -5 ..< range + 5 ).map { potIsLive(potNumber: $0) ? "#" : "." }.joined()
        
        if potBase < 0 {
            representation.removeFirst(-potBase)
        } else if potBase > 0 {
            representation = String(repeating: ".", count: potBase) + representation
        }
        print( String( format: "%2d: \(representation)", arguments: [generation] ) )
    }
}

func parseInitial( lines: [Substring] ) -> Pots {
    let words = lines[0].split(separator: " ")
    let pots = Pots()
    
    pots.parse( initial: words[2] )
    return pots
}

func parseRules( lines: [Substring] ) -> Set<UInt> {
    var rules = Set<UInt>()
    
    for line in lines[1...] {
        let words = line.split(separator: " ")
        var pattern: UInt = 0
        
        for pot in words[0].reversed() {
            pattern <<= 1
            if pot == "#" { pattern |= 1 }
        }
        
        if words[2] == "#" {
            rules.insert(pattern)
        }
    }
    
    return rules
}

let generations1 = 20
let generations2 = 50000000000
let frequency    =   100000000
let header = """
                   1         2         3
         0         0         0         0
"""

let pots = parseInitial(lines: lines)
let rules = parseRules(lines: lines)
var seen = [ pots.hashKey() : ( generation: 0, potBase: pots.potBase) ]

//print(header)
//pots.printGeneration(generation: 0)
for generation in 1 ... generations2 {
    let nextGeneration = Pots(from: pots)
    
    // Process existing range and extend range to the right
    nextGeneration.extendOnLeft(count: 2)
    for potNumber in 0 ..< pots.range + 2 {
        let region = pots.region(potNumber: potNumber)
        
        nextGeneration.potSet( potNumber: potNumber, to: rules.contains(region) ? 1 : 0 )
    }
    
    // Extend range to the left
    let regionLeft1 = pots.region(potNumber: -1)
    let regionLeft2 = pots.region(potNumber: -2)
    
    nextGeneration.extendOnRight(value: rules.contains(regionLeft1) ? 1 : 0)
    nextGeneration.extendOnRight(value: rules.contains(regionLeft2) ? 1 : 0)

    nextGeneration.normalize()
    pots.copy(from: nextGeneration)
//    if generation > 152 { pots.printGeneration(generation: generation) }
    
    if generation == generations1 {
        print( "Part1:", pots.sumLive() )
    }
    if let last = seen[ pots.hashKey() ] {
        let cycle = generation - last.generation
        let deltaPotBase = pots.potBase - last.potBase
        let generationsRemaing = generations2 - generation
        let cycles = generationsRemaing / cycle
        let residual = generationsRemaing % cycle
        
        if residual != 0 {
            print( "Can't handle partial cycles!" )
            exit(1)
        }
        pots.potBase += cycles * deltaPotBase
        break
        
    } else {
        seen[ pots.hashKey() ] = ( generation: generation, potBase: pots.potBase )
    }
}

print( "Part2:", pots.sumLive() )
