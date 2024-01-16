//
//         FILE: day25.swift
//  DESCRIPTION: Advent of Code 2023 Day 25: Snowverload
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/24/23 21:00:02
//

import Foundation
import Library

struct Network {
    let components: [ String : Set<String> ]
    let dist: [ String : [ String : Int ] ]
    
    init( lines: [String] ) {
        var components = [ String : Set<String> ]()
        for line in lines {
            let words = line.split( whereSeparator: { ": ".contains( $0 ) } ).map { String( $0 ) }
            components[ words[0], default: Set<String>() ].formUnion( words[1...] )
            for word in words[1...] {
                components[ word, default: Set<String>() ].insert( words[0] )
            }
        }
        self.components = components
        self.dist = [:]
    }
    
    init( network: Network ) {
        let components = network.components
        
        // Floyd–Warshall algorithm
        var dist = Dictionary(
            uniqueKeysWithValues: components.keys.map {
                ( $0, Dictionary( uniqueKeysWithValues: components.keys.map { ( $0, components.count ) } ) )
            } )

        components.keys.forEach { component in
            components[component]!.forEach { dist[component]![$0] = 1 }
        }
        components.keys.forEach { dist[$0]![$0] = 0 }

        for k in components.keys {
            for i in components.keys {
                for j in components.keys {
                    if dist[i]![j]! > dist[i]![k]! + dist[k]![j]! {
                        dist[i]![j] = dist[i]![k]! + dist[k]![j]!
                    }
                }
            }
        }
        
        self.components = components
        self.dist = dist
    }
}


func part1( input: AOCinput ) -> String {
    let network = Network( network: Network( lines: input.lines ) )
    let components = network.components.keys.map { String( $0 ) }.sorted()

//    network.components.sorted { $0.key < $1.key }.forEach {
//        print( "\($0.key) connects to \($0.value.sorted())." )
//    }
    
    let maxDistance = network.dist.map { $0.value.values.max()! }.max()!
    
    var antipodes = [ ( String, String ) ]()
    for i in components {
        for j in components {
            if network.dist[i]![j] == maxDistance {
                antipodes.append( ( i, j ) )
            }
        }
    }

    var solutions = [Int]()
    for ( anchor1, anchor2 ) in antipodes {
        var firstGroup = Set<String>()
        var secondGroup = Set<String>()
        var neutralZone = Set<String>()
        
        for i in components {
            let g1Distance = network.dist[anchor1]![i]!
            let g2Distance = network.dist[anchor2]![i]!
            
            if g1Distance < g2Distance {
                firstGroup.insert( i )
            } else if g1Distance > g2Distance {
                secondGroup.insert( i )
            } else {
                neutralZone.insert( i )
            }
        }
        
        if neutralZone.count == 3 {
            let zonies = neutralZone.map {
                let g1Count = network.components[$0]!.reduce( 0 ) {
                    $0 + ( firstGroup.contains( $1 ) ? 1 : 0 ) }
                let g2Count = network.components[$0]!.reduce( 0 ) {
                    $0 + ( secondGroup.contains( $1 ) ? 1 : 0 ) }
                return ( $0, g1Count, g2Count )
            }
            if zonies.allSatisfy( { $0.1 == 1 } ) {
                solutions.append( firstGroup.count * ( secondGroup.count + 3 ) )
            }
            if zonies.allSatisfy( { $0.2 == 1 } ) {
                solutions.append( ( firstGroup.count + 3 ) * secondGroup.count )
            }
        }
    }
    
    return "\(solutions.max()!)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
