//
//  main.swift
//  day01
//
//  Created by Mark Johnson on 11/25/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

enum Direction {
    case North
    case South
    case East
    case West
}

struct Point {
    var x: Int
    var y: Int
}

struct Vector {
    let start: Point
    let end: Point
    let isNorthSouth: Bool
    
    init(start: Point, end: Point) {
        self.start = start
        self.end = end
        isNorthSouth = start.x == end.x
    }
    
    func contains(x: Int) -> Bool {
        return min( start.x, end.x ) <= x && x <= max( start.x, end.x )
    }
    
    func contains(y: Int) -> Bool {
        return min( start.y, end.y ) <= y && y <= max( start.y, end.y )
    }
    
    // This function assumes all vectors are orthoganl, i.e. either North-South or East-West
    func intersection(other: Vector) -> Point? {
        if self.isNorthSouth && !other.isNorthSouth {
            if other.contains(x: start.x) && contains(y: other.start.y) {
                return Point( x: start.x, y: other.start.y )
            }
        } else if !self.isNorthSouth && other.isNorthSouth {
            if other.contains(y: start.y) && contains(x: other.start.x) {
                return Point( x: other.start.x, y: start.y )
            }
        } else if self.isNorthSouth && other.isNorthSouth {
            if start.x == other.start.x {
                if contains(y: other.start.y) {
                    return other.start
                } else if other.start.y <= min(start.y, end.y) {
                    if other.end.y >= min(start.y, end.y) {
                        return Point(x: start.x, y: min(start.y, end.y))
                    }
                } else {
                    if other.end.y <= max(start.y, end.y) {
                        return Point(x: start.x, y: max(start.y, end.y))
                    }
                }
            }
        } else {
            // Both are East-West
            if start.y == other.start.y {
                if contains(x: other.start.x) {
                    return other.start
                } else if other.start.x <= min(start.x, end.x) {
                    if other.end.x >= min(start.x, end.x) {
                        return Point(x: min(start.x, end.x), y: start.y)
                    }
                } else {
                    if other.end.x <= max(start.x, end.x) {
                        return Point(x: max(start.x, end.x), y: start.y)
                    }
                }
            }
        }
        
        return nil
    }
}

var direction = Direction.North
var position = Point( x: 0, y: 0 )
var path: [Vector] = []


let leftChange = [
    Direction.North : Direction.West,
    Direction.South : Direction.East,
    Direction.East : Direction.North,
    Direction.West : Direction.South
]
let rightChange = [
    Direction.North : Direction.East,
    Direction.South : Direction.West,
    Direction.East : Direction.South,
    Direction.West : Direction.North
]
let modify = [
    Direction.North : { ( blocks: Int ) -> Void in position.y += blocks },
    Direction.South : { ( blocks: Int ) -> Void in position.y -= blocks },
    Direction.East : { ( blocks: Int ) -> Void in position.x += blocks },
    Direction.West : { ( blocks: Int ) -> Void in position.x -= blocks }
]

let seperator = ", "
let input = """
L2, L3, L3, L4, R1, R2, L3, R3, R3, L1, L3, R2, R3, L3, R4, R3, R3, L1, L4, R4, L2, R5, R1, L5, R1, R3, L5, R2, L2, R2, R1, L1, L3, L3, R4, R5, R4, L1, L189, L2, R2, L5, R5, R45, L3, R4, R77, L1, R1, R194, R2, L5, L3, L2, L1, R5, L3, L3, L5, L5, L5, R2, L1, L2, L3, R2, R5, R4, L2, R3, R5, L2, L2, R3, L3, L2, L1, L3, R5, R4, R3, R2, L1, R2, L5, R4, L5, L4, R4, L2, R5, L3, L2, R4, L1, L2, R2, R3, L2, L5, R1, R1, R3, R4, R1, R2, R4, R5, L3, L5, L3, L3, R5, R4, R1, L3, R1, L3, R3, R3, R3, L1, R3, R4, L5, L3, L1, L5, L4, R4, R1, L4, R3, R3, R5, R4, R3, R3, L1, L2, R1, L4, L4, L3, L4, L3, L5, R2, R4, L2
"""
let steps = input.split() { seperator.contains($0) }

for step in steps {
    if step.first == "L" {
        direction = leftChange[direction]!
    } else if step.first == "R" {
        direction = rightChange[direction]!
    }
    
    let index = step.index(step.startIndex, offsetBy: 1)
    let string = step.suffix(from: index)
    let blocks = Int( string )
    let start = position
    
    modify[direction]!( blocks! )
    path.append( Vector( start: start, end: position ) )
}

print( "Part1:", abs(position.x) + abs(position.y) )

OUTER:
for j in 1 ..< path.count {
    for i in 0 ..< j - 1 {
        if let hq = path[i].intersection(other: path[j]) {
            print( "Part2:", abs(hq.x) + abs(hq.y) )
            break OUTER
        }
    }
}
