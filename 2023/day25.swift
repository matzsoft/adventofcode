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

extension Array {
    func pairwise() -> [ ( Element, Element ) ]? {
        guard count > 1 else { return nil }
        return ( 1 ..< count )
            .reduce( into: [ ( Element, Element ) ]() ) { $0.append( ( self[$1-1], self[$1] ) ) }
    }
}


struct Network {
    let components: [ String : Set<String> ]
    let dist: [ String : [ String : Int ] ]
    
    init( components: [String : Set<String>], dist: [String : [String : Int]] ) {
        self.components = components
        self.dist = dist
    }
    
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
    
    func randomPair() -> ( String, String )? {
        guard components.count > 1 else { return nil }
        guard let first = components.keys.randomElement() else { return nil }
        while true {
            guard let second = components.keys.randomElement() else { return nil }
            if first != second { return ( first, second ) }
        }
    }
    
    func shortestPath( start: String, end: String ) -> [ String ]? {
        var seen = Set( [ start ] )
        var queue = [ ( start, [start] ) ]
        
        while !queue.isEmpty {
            let ( current, path ) = queue.removeFirst()
            
            for neighbor in components[current]!.filter( { !seen.contains( $0 ) } ) {
                let newPath = path + [neighbor]
                if neighbor == end { return newPath }
                seen.insert( neighbor )
                queue.append( ( neighbor, newPath ) )
            }
        }
        
        return nil
    }
    
    func cut( edge: Edge ) -> Network {
        var components = self.components
        components[ edge.start ]!.remove( edge.end )
        components[ edge.end ]!.remove( edge.start )
        return Network( components: components, dist: dist )
    }
    
    func reachableCount( from: String ) -> Int {
        var seen = Set<String>()
        var queue = [from]
        
        while !queue.isEmpty {
            let current = queue
            
            queue = []
            for node in current {
                if !seen.contains( node ) {
                    seen.insert( node )
                    queue.append( contentsOf: components[node]! )
                }
            }
        }
        
        return seen.count
    }
}


struct Edge: Hashable {
    let start: String
    let end: String
    
    init( start: String, end: String ) {
        if start < end {
            self.start = start
            self.end = end
        } else {
            self.start = end
            self.end = start
        }
    }
}


func part1( input: AOCinput ) -> String {
    let network = Network( lines: input.lines )
    var histogram = [ Edge : Int ]()
    
    for _ in 1 ... 100 {
        let ( start, end ) = network.randomPair()!
        let path = network.shortestPath( start: start, end: end )!
        
        for ( left, right ) in path.pairwise()! {
            histogram[ Edge( start: left, end: right ), default: 0 ] += 1
        }
    }
    
    let sorted = histogram.sorted { $0.value > $1.value }
    var splitNetwork = network
    for index in 0 ..< 3 {
        splitNetwork = splitNetwork.cut( edge: sorted[index].key )
    }
    
    let leftCount = splitNetwork.reachableCount( from: sorted[0].key.start )
    return "\( leftCount * ( network.components.count - leftCount ) )"
}


func oldPart1( input: AOCinput ) -> String {
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
