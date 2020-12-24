//
//  main.swift
//  day24
//
//  Created by Mark Johnson on 12/24/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

enum Direction: String, CaseIterable {
    case e, se, sw, w, nw, ne
    
    var vector: Position {
        switch self {
        case .e:
            return Position( x: 2, y: 0 )
        case .se:
            return Position( x: 1, y: -1 )
        case .sw:
            return Position( x: -1, y: -1 )
        case .w:
            return Position( x: -2, y: 0 )
        case .nw:
            return Position( x: -1, y: 1 )
        case .ne:
            return Position( x: 1, y: 1 )
        }
    }
}


struct Position: Hashable {
    let x: Int
    let y: Int
    
    func step( direction: Direction ) -> Position {
        return Position( x: x + direction.vector.x, y: y + direction.vector.y )
    }
}

struct StepList {
    let steps: [Direction]
    let vector: Position
    
    init( input: Substring ) {
        var last: Character?
        var steps: [Direction] = []
        
        for character in input {
            if let previous = last {
                steps.append( Direction( rawValue: String( previous ) + String( character ) )! )
                last = nil
            } else if let direction = Direction( rawValue: String( character ) ) {
                steps.append( direction )
            } else {
                last = character
            }
        }
        
        self.steps = steps
        vector = steps.reduce( into: Position( x: 0, y: 0 ), { $0 = $0.step( direction: $1 ) } )
    }
}


func part1( tileList: [StepList] ) -> Set<Position> {
    var blacks = Set<Position>()
    
    for tile in tileList {
        if blacks.contains( tile.vector ) {
            blacks.remove( tile.vector )
        } else {
            blacks.insert( tile.vector )
        }
    }
    return blacks
}


func countNeighbors( blacks: Set<Position>, position: Position ) -> Int {
    return Direction.allCases.reduce( 0 ) {
        $0 + ( blacks.contains( position.step( direction: $1 ) ) ? 1 : 0 )
    }
}


func findWhites( blacks: Set<Position> ) -> [Position] {
    var results: [Position] = []
    let minX = blacks.min { $0.x < $1.x }!.x - 2
    let maxX = blacks.max { $0.x < $1.x }!.x + 2
    let minY = blacks.min { $0.y < $1.y }!.y - 1
    let maxY = blacks.max { $0.y < $1.y }!.y + 1
    
    for x in minX ... maxX {
        for y in minY ... maxY {
            let tile = Position.init( x: x, y: y )
            
            if !blacks.contains( tile ) { results.append( tile ) }
        }
    }
    return results
}


func part2( initial: Set<Position> ) -> Int {
    var thisDay = initial
    
    for _ in 1 ... 100 {
        var nextDay = thisDay
        
        for tile in thisDay {
            let neighbors = countNeighbors( blacks: thisDay, position: tile )
            
            if neighbors == 0 || neighbors > 2 { nextDay.remove( tile ) }
        }
        
        for tile in findWhites( blacks: thisDay ) {
            let neighbors = countNeighbors( blacks: thisDay, position: tile )
            
            if neighbors == 2 { nextDay.insert( tile ) }
        }
        thisDay = nextDay
    }
    
    return thisDay.count
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day24.txt"
let tileList = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { StepList( input: $0 ) }
var blacks = part1( tileList: tileList )


print( "Part 1: \( blacks.count )" )
print( "Part 2: \( part2( initial: blacks ) )" )
