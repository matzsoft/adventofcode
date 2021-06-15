//
//         FILE: main.swift
//  DESCRIPTION: day13 - Packet Scanners
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/19/21 18:22:00
//

import Foundation

class Layer {
    let depth: Int
    let range: Int
    var period: Int { return 2 * ( range - 1 ) }
    var severity: Int { return depth * range }
    
    init( input: String ) {
        let words = input.split( whereSeparator: { ": ".contains($0) } )
        
        depth = Int( words[0] )!
        range = Int( words[1] )!
    }
}


func severity( layers: [Layer], delay: Int   ) -> Int {
    return layers.reduce( 0 ) { $0 + ( ( $1.depth + delay ) % $1.period == 0 ? $1.severity : 0 ) }
}


class Combo {
    let set: Set<Int>
    let period : Int
    
    init( layer: Layer ) {
        period = layer.period
        set = Set( ( 0 ..< period ).filter { ( $0 + layer.depth ) % layer.period != 0 } )
    }
    
    init( set: Set<Int>, period: Int ) {
        self.set = set
        self.period = period
    }
    
    func expandedSet( limit: Int ) -> Set<Int> {
        return stride( from: 0, to: limit, by: period ).reduce( into: Set<Int>(), {
            for n in set { $0.insert( n + $1 ) }
        } )
    }
    
    func combine( other: Combo ) -> Combo {
        let newPeriod = lcm( period, other.period )
        let newSet = expandedSet( limit: newPeriod ).filter { other.set.contains( $0 % other.period )  }
        
        return Combo( set: newSet, period: newPeriod )
    }
}


func parse( input: AOCinput ) -> [Layer] {
    return input.lines.map { Layer( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let layers = parse( input: input )
    return "\(severity( layers: layers, delay: 0 ))"
}


func part2( input: AOCinput ) -> String {
    let layers = parse( input: input )
    let combo = layers[1...].reduce( Combo( layer: layers[0] ) ) {
        return $0.combine( other: Combo( layer: $1 ) )
    }

    return "\(combo.set.min()!)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
