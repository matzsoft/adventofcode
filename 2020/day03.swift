//
//  main.swift
//  day03
//
//  Created by Mark Johnson on 12/04/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day03.txt"
let grid = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { $0.map { $0 } }

struct Position {
    let x: Int
    let y: Int

    func move( slope: Position ) -> Position {
        return Position( x: ( x + slope.x ) % grid[0].count, y: y + slope.y )
    }
}

struct Traversal {
    let slope: Position
    var position = Position( x: 0, y: 0 )
    var treeCount = 0
    
    mutating func downhill() -> Void {
        while position.y < grid.count {
            if grid[position.y][position.x] == "#" {
                treeCount += 1
            }
            position = position.move( slope: slope )
        }
    }
}

var traversals = [
    Traversal( slope: Position( x: 1, y: 1 ) ),
    Traversal( slope: Position( x: 3, y: 1 ) ),
    Traversal( slope: Position( x: 5, y: 1 ) ),
    Traversal( slope: Position( x: 7, y: 1 ) ),
    Traversal( slope: Position( x: 1, y: 2 ) ),
]

for index in 0 ..< traversals.count {
    traversals[index].downhill()
}

print( "Part 1: \(traversals[1].treeCount)" )
print( "Part 2: \(traversals.reduce( 1, { $0 * $1.treeCount } ))" )
