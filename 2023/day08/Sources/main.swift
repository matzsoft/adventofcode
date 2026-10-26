//
//         FILE: day08.swift
//  DESCRIPTION: Advent of Code 2023 Day 8: Haunted Wasteland
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/07/23 21:00:00
//

import Foundation
import Library

enum Instruction: Character { case right = "R", left = "L" }

struct Node {
    let name: String
    let left: String
    let right: String
    
    init( line: String ) {
        let words = line.split( whereSeparator: { " =(,)".contains( $0 ) } )
        name = String( words[0] )
        left = String( words[1] )
        right = String( words[2] )
    }
}


func parse( input: AOCinput ) -> ( [Instruction], [ String : Node ] ) {
    let instructions = input.line.map { Instruction( rawValue: $0 )! }
    let network = input.paragraphs[1]
        .map { Node( line: $0 ) }
        .reduce( into: [ String : Node ]() ) { $0[$1.name] = $1 }
        
    return ( instructions, network )
}


func findCycle( node: Node, instructions: [Instruction], network: [ String : Node ] ) -> Int {
    var count = 0
    var node = node
    
    while node.name.last != "Z" {
        switch instructions[ count % instructions.count ] {
        case .left:
            node = network[node.left]!
        case .right:
            node = network[node.right]!
        }
        count += 1
    }
    
    return count
}


func part1( input: AOCinput ) -> String {
    let ( instructions, network ) = parse( input: input )
    
    return "\( findCycle( node: network["AAA"]!, instructions: instructions, network: network ) )"
}


func part2( input: AOCinput ) -> String {
    let ( instructions, network ) = parse( input: input )
    let nodes = network.filter { $0.key.last == "A" }
    let cycles = nodes.map { findCycle( node: $0.value, instructions: instructions, network: network ) }

    return "\( cycles.reduce( 1 ) { lcm( $0, $1 ) } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
