//
//         FILE: main.swift
//  DESCRIPTION: day12 - Digital Plumber
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/19/21 16:12:32
//

import Foundation


func parse( input: AOCinput ) -> Array<Set<Int>> {
    let lines = input.lines.map { $0.split( whereSeparator: { " <->,".contains( $0 ) } ).map { Int( $0 )! } }
    let connections = lines.reduce(into: [ Int : Set<Int> ](), { $0[$1[0]] = Set( $1 ) } )
    
    var available = Set( connections.keys )
    var groups = Array<Set<Int>>()
    
    while let base = available.first {
        var group = connections[base]!
        var used = Set( [ base ] )
        
        while let next = group.subtracting( used ).first {
            group.formUnion( connections[next]! )
            used.insert( next )
        }
        
        available.subtract( group )
        groups.append( group )
    }
    
    return groups
}


func part1( input: AOCinput ) -> String {
    let groups = parse( input: input )
    let zeroGroup = groups.first( where: { $0.contains( 0 ) } )!
    return "\(zeroGroup.count)"
}


func part2( input: AOCinput ) -> String {
    let groups = parse( input: input )
    return "\(groups.count)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
