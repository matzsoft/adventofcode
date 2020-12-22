//
//  main.swift
//  day20
//
//  Created by Mark Johnson on 12/19/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Tile {
    let id: Int
    let image: [String]
    let borders: Set<String>

    static func rotated( by: Int, image: [String ] ) -> String {
        let by = by % 4
        
        switch by {
        case 0:
            return image.first!
        case 1:
            return String( image.map { String( $0.first! ) }.joined().reversed() )
        case 2:
            return String( image.last!.reversed() )
        case 3:
            return image.map { String( $0.last! ) }.joined()
        default:
            return ""
        }
    }
    
    init( input: String ) {
        let lines = input.split( separator: "\n" )
        var tops: [String] = []
        
        id = Int( lines[0].dropFirst( 5 ).dropLast() )!
        image = lines.dropFirst().map { String( $0 ) }
        
        tops.append( Tile.rotated( by: 0, image: image ) )
        tops.append( Tile.rotated( by: 1, image: image ) )
        tops.append( Tile.rotated( by: 2, image: image ) )
        tops.append( Tile.rotated( by: 3, image: image ) )
        
        let flipped = image.map { String( $0.reversed() ) }
        
        tops.append( Tile.rotated( by: 0, image: flipped ) )
        tops.append( Tile.rotated( by: 1, image: flipped ) )
        tops.append( Tile.rotated( by: 2, image: flipped ) )
        tops.append( Tile.rotated( by: 3, image: flipped ) )
        
        borders = Set( tops )
    }
}

struct Node {
    let tile: Tile
    let neighbors: Set<Int>
    
    init( tile: Tile, tiles: [Tile] ) {
        let others = tiles.filter { $0.id != tile.id }
        
        self.tile = tile
        neighbors = others.reduce( into: Set<Int>(), { set, other in
            if !tile.borders.intersection( other.borders ).isEmpty { set.insert( other.id ) }
        } )
    }
    
    var isCorner: Bool { neighbors.count == 2 }
    var isEdge: Bool { neighbors.count == 3 }
    var isMiddle: Bool { neighbors.count == 4 }
}


func part1( nodes: [ Int: Node ] ) -> Int {
    let corners = nodes.values.filter { $0.isCorner }

    return corners.reduce( 1 ) { $0 * $1.tile.id }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day20.txt"
let groups =  try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" )
let tiles =  groups.map { Tile( input: $0 ) }
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
