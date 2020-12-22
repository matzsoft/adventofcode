//
//  main.swift
//  day20
//
//  Created by Mark Johnson on 12/19/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Configuration {
    let top: String
    let right: String
    let bottom: String
    let left: String
    
    init( top: String, right: String, bottom: String, left: String ) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
    
    init( image: [String] ) {
        top = image.first!
        bottom = image.last!
        right = image.map { String( $0.last! ) }.joined()
        left = image.map { String( $0.first! ) }.joined()
    }
    
    var rotated: Configuration {
        return Configuration(
            top: String( left.reversed() ),
            right: top,
            bottom: String( right.reversed() ),
            left: bottom
        )
    }
    
    var flipped: Configuration {
        return Configuration(
            top: String( top.reversed() ),
            right: left,
            bottom: String( bottom.reversed() ),
            left: right
        )
    }
}


struct Tile: Equatable {
    let id: Int
    let image: [String]
    let configurations: [Configuration]
    let top: Set<String>
    let right: Set<String>
    let bottom: Set<String>
    let left: Set<String>

    init( input: String ) {
        let lines = input.split( separator: "\n" )
        var configurations: [Configuration] = []
        
        id = Int( lines[0].dropFirst( 5 ).dropLast() )!
        image = lines.dropFirst().map { String( $0 ) }
        
        configurations.append( Configuration( image: image ) )      // As input, no flip, no rotation
        configurations.append( configurations.first!.rotated )      // No flip, rotatated right once
        configurations.append( configurations.last!.rotated )       // No flip, rotatated right twice
        configurations.append( configurations.last!.rotated )       // No flip, rotatated right three times
        configurations.append( configurations.first!.flipped )      // Flipped, no rotation
        configurations.append( configurations.last!.rotated )       // Flipped, rotatated right once
        configurations.append( configurations.last!.rotated )       // Flipped, rotatated right twice
        configurations.append( configurations.last!.rotated )       // Flipped, rotatated right three times
        self.configurations = configurations
        
        top = configurations.reduce( into: Set<String>(), { $0.insert( $1.top ) } )
        right = configurations.reduce( into: Set<String>(), { $0.insert( $1.right ) } )
        bottom = configurations.reduce( into: Set<String>(), { $0.insert( $1.bottom ) } )
        left = configurations.reduce( into: Set<String>(), { $0.insert( $1.left ) } )
    }
    
    static func == ( lhs: Tile, rhs: Tile ) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Node {
    let tile: Tile
    let top: Set<Int>
    let right: Set<Int>
    let bottom: Set<Int>
    let left: Set<Int>
    
    init( tile: Tile, tiles: [Tile] ) {
        let others = tiles.filter { $0.id != tile.id }
        
        self.tile = tile
        top = others.reduce( into: Set<Int>(), { set, other in
            if !tile.top.intersection( other.bottom ).isEmpty { set.insert( other.id ) }
        } )
        right = others.reduce( into: Set<Int>(), { set, other in
            if !tile.right.intersection( other.left ).isEmpty { set.insert( other.id ) }
        } )
        bottom = others.reduce( into: Set<Int>(), { set, other in
            if !tile.bottom.intersection( other.top ).isEmpty { set.insert( other.id ) }
        } )
        left = others.reduce( into: Set<Int>(), { set, other in
            if !tile.left.intersection( other.right ).isEmpty { set.insert( other.id ) }
        } )
    }
}


func part1( nodes: [ Int: Node ] ) -> Int {
    let corners = nodes.values.filter { $0.top.count == 2 }

    return corners.reduce( 1 ) { $0 * $1.tile.id }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day20.txt"
let tiles =  try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" ).map {
    Tile( input: $0 )
}
var nodes = tiles.reduce(into: [ Int : Node ](), { $0[$1.id] = Node( tile: $1, tiles: tiles ) } )

//for id in tiles.map( { $0.id } ).sorted() {
//    let node = nodes[id]
//
//    print( "Tile \(id):" )
//    print( "    top = \(node!.top)" )
//    print( "    right = \(node!.right)" )
//    print( "    bottom = \(node!.bottom)" )
//    print( "    left = \(node!.left)" )
//}

print( "Part 1: \( part1( nodes: nodes ) )" )
//print( "Part 2: \( part2( rules: rules, messages: messages ) )" )
