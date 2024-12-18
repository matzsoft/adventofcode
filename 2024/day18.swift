//
//         FILE: day18.swift
//  DESCRIPTION: Advent of Code 2024 Day 18: RAM Run
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/24 21:50:41
//

import Foundation
import Library

enum Byte: Character { case safe = ".", corrupted = "#" }

struct Node {
    let position: Point2D
    let distance: Int
    
    func move( direction: DirectionUDLR ) -> Node {
        Node(position: position + direction.vector, distance: distance + 1 )
    }
}


struct MemorySpace {
    init( bounds: Rect2D, bytes: [Point2D], corrupted: [Point2D] ) {
        self.bounds = bounds
        self.bytes = bytes
        self.corrupted = corrupted
    }
    
    let bounds: Rect2D
    let bytes: [Point2D]
    let corrupted: [Point2D]
    
    init( lines: [String], extra: String ) {
        let fields = extra.split( separator: "," ).map { Int( $0 )! }
        
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0), width: fields[0], height: fields[1]
        )!
        bytes = lines.map {
            let fields = $0.split( separator: "," ).map { Int( $0 )! }
            return Point2D( x: fields[0], y: fields[1] )
        }
        corrupted = Array( bytes[..<fields[2]] )
    }
    
    var another: MemorySpace {
        return MemorySpace(
            bounds: bounds, bytes: bytes,
            corrupted: corrupted + [ bytes[corrupted.count] ]
        )
    }
    
    var shortestPath: Int? {
        var queue = [ Node( position: bounds.min, distance: 0 ) ]
        var seen = [ bounds.min : 0 ]
        var best = Int.max
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            for direction in DirectionUDLR.allCases {
                let next = current.move( direction: direction )
                guard bounds.contains( point: next.position ) else { continue }
                if corrupted.contains( next.position ) { continue }
                
                if next.position == bounds.max {
                    if best > next.distance {
                        best = next.distance
                    }
                } else if seen[next.position] == nil {
                    seen[next.position] = next.distance
                    queue.append( next )
                } else if seen[next.position]! > next.distance {
                    seen[next.position] = next.distance
                    queue.append( next )
                }
            }
        }
        
        return best < Int.max ? best : nil
    }
}
    
func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let space = MemorySpace( lines: input.lines, extra: input.extras[0] )
    return "\(space.shortestPath!)"
}


func part2( input: AOCinput ) -> String {
    var original = MemorySpace( lines: input.lines, extra: input.extras[0] )
    
    while true {
        original = original.another
        if original.shortestPath == nil {
            return "\(original.corrupted.last!.x),\(original.corrupted.last!.y)"
        }
    }
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
