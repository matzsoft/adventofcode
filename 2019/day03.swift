//
//  main.swift
//  day03
//
//  Created by Mark Johnson on 12/2/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

struct Point {
    let x: Int
    let y: Int
    
    init( x: Int, y: Int ) {
        self.x = x
        self.y = y
    }
    
    init( from: String ) {
        let direction = from[from.startIndex]
        let distanceString = from[ from.index( after: from.startIndex ) ..< from.endIndex ]
        
        guard let distance = Int( distanceString ) else {
            print( "Invalid input \(from)" )
            exit( 1 )
        }

        switch direction {
        case "L":
            x = -distance
            y = 0
        case "R":
            x = distance
            y = 0
        case "U":
            x = 0
            y = distance
        case "D":
            x = 0
            y = -distance
        default:
            print( "Invalid input \(from)" )
            exit(1)
        }
    }
    
    func move( vector: Point ) -> Point {
        return Point( x: x + vector.x, y: y + vector.y )
    }
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
}

struct Line {
    let start: Point
    let end: Point
    
    var vertical: Bool { start.x == end.x }
    var horizontal: Bool { start.y == end.y }
    
    func containsX( value: Int ) -> Bool {
        let minX = min( start.x, end.x )
        let maxX = max( start.x, end.x )
        
        return minX <= value && value <= maxX
    }
    
    func containsY( value: Int ) -> Bool {
        let minY = min( start.y, end.y )
        let maxY = max( start.y, end.y )
        
        return minY <= value && value <= maxY
    }
    
    func contains( point: Point ) -> Bool {
        return containsX( value: point.x ) && containsY( value: point.y )
    }
    
    func intersection( other: Line ) -> Point? {
        guard start.x != other.start.x || start.y != other.start.y else { return nil }
        
        if vertical && other.horizontal {
            if other.containsX( value: start.x ) {
                if containsY( value: other.start.y ) {
                    let result = Point( x: start.x, y: other.start.y )
                    return result
                }
            }
        } else if horizontal && other.vertical {
            if other.containsY( value: start.y ) {
                if containsX( value: other.start.x ) {
                    let result = Point( x: other.start.x, y: start.y )
                    return result
                }
            }
        }
        
        return nil
    }
}

struct Wire {
    let moves: [Point]
    
    init( from: String ) {
        moves = from.split( separator: "," ).map { Point( from: String( $0 ) ) }
    }
    
    func steps( point: Point ) -> Int {
        var currentP = Point( x: 0, y: 0 )
        var count = 0
        
        for move in moves {
            let nextP = currentP.move( vector: move )
            let line = Line( start: currentP, end: nextP )
            
            if line.contains( point: point ) {
                return count + point.distance( other: currentP )
            } else {
                count += currentP.distance( other: nextP )
            }
            currentP = nextP
        }
        
        return count
    }
}

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day03.txt"
let wires = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Wire( from: String( $0 ) ) }
var intersections: [Point] = []
var current1 = Point( x: 0, y: 0 )

for move in wires[0].moves {
    let next1 = current1.move( vector: move )
    let line1 = Line( start: current1, end: next1 )
    var current2 = Point( x: 0, y: 0 )
    
    for move in wires[1].moves {
        let next2 = current2.move( vector: move )
        let line2 = Line( start: current2, end: next2 )
        
        if let intersection = line1.intersection( other: line2 ) {
            intersections.append( intersection )
        }
        current2 = next2
    }
    current1 = next1
}

intersections.sort { $0.distance( other: Point( x: 0, y: 0) ) < $1.distance( other: Point( x: 0, y: 0 ) ) }
print( "Part 1: \( intersections[0].distance( other: Point( x: 0, y: 0 ) ) )" )

let steps = intersections.map { wires[0].steps( point: $0 )  + wires[1].steps( point: $0 ) }.sorted()

print( "Part 2: \(steps[0])" )
