//
//         FILE: day18.swift
//  DESCRIPTION: Advent of Code 2024 Day 18: RAM Run
//        NOTES: Credit to Prior-Cut-2448 from the subreddit. I couldn't figure out why
//               my original algortithm was so slow. So I converted Prior-Cut-2448's
//               into crude Swift and then made it more Swifty. That got the part1
//               runtime from 1350ms to 9ms.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/24 21:50:41
//

import Foundation
import Library

struct Node {
    let position: Point2D
    let distance: Int
    
    func move( direction: DirectionUDLR ) -> Node {
        Node( position: position + direction.vector, distance: distance + 1 )
    }
}


struct MemorySpace: CustomStringConvertible {
    let bounds: Rect2D
    let bytes: [Point2D]
    let corrupted: [Point2D]
    
    var description: String {
        var buffer: [[Character]] = Array( repeating: Array(
            repeating: ".", count: bounds.width
        ), count: bounds.height )
        
        corrupted.forEach { buffer[$0.y][$0.x] = "#" }
        return buffer.map { String( $0 ) }.joined( separator: "\n" )
    }
    
    init( bounds: Rect2D, bytes: [Point2D], corrupted: [Point2D] ) {
        self.bounds = bounds
        self.bytes = bytes
        self.corrupted = corrupted
    }
    
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
    
    var quick: Int? {
        var queue = Set( bounds.points ).subtracting( corrupted )
        var dist = queue.reduce( into: [Point2D : Int ]() ) { queue, point in
            queue[point] = Int.max
        }
        var prev = queue.reduce( into: [ Point2D : Point2D? ]() ) { prev, point in
            prev[point] = nil
        }
        dist[bounds.min] = 0
        
        while !queue.isEmpty {
            let u = queue.min { dist[$0]! < dist[$1]! }!
            if u == bounds.max { return dist[u] }
            if dist[u] == Int.max { return nil }
            queue.remove( u )
            
            let neighbors = DirectionUDLR.allCases
                .map { u + $0.vector }
                .filter { queue.contains( $0 ) }
                .filter { !corrupted.contains( $0 ) }
            
            for neighbor in neighbors {
                let alt = dist[u]! + 1
                if alt < dist[neighbor]! {
                    dist[neighbor] = alt
                    prev[neighbor] = u
                }
            }
        }
        
        return dist[bounds.max]
    }
    
    var shortestPath: Int? {
        var unavailable = Array(
            repeating: Array( repeating: 0, count: bounds.width ),
            count: bounds.height
        )
        var nodes = [ Node( position: Point2D( x: 0, y: 0), distance: 0 ) ]
        var nextIndex = 0
        
        for corrupt in corrupted {
            unavailable[corrupt.y][corrupt.x] = 1
        }
        
        while true {
            if nextIndex >= nodes.count { return nil }
            let node = nodes[nextIndex]
            nextIndex += 1
            if node.position == bounds.max {
                return node.distance
            }
            for trial in DirectionUDLR.allCases.map( { node.move( direction: $0 ) } ) {
                if trial.position.x >= 0 && trial.position.x < bounds.width {
                    if trial.position.y >= 0 && trial.position.y < bounds.height {
                        if unavailable[trial.position.y][trial.position.x] != 1 {
                            unavailable[trial.position.y][trial.position.x] = 1
                            nodes.append( trial )
                        }
                    }
                }
            }
        }
    }

// My original version which runs way too slow.
//    var shortestPath: Int? {
//        var queue = [ Node( position: bounds.min, distance: 0 ) ]
//        var seen = Set( [ bounds.min ] )
//        
//        while !queue.isEmpty {
//            let current = queue.removeFirst()
//        
//            let neighbors = DirectionUDLR.allCases
//                .map { current.move( direction: $0 ) }
//                .filter { bounds.contains( point: $0.position ) }
//                .filter { !corrupted.contains( $0.position ) }
//            for next in neighbors {
//                if next.position == bounds.max {
//                    return next.distance
//                } else if seen.insert( next.position ).inserted {
//                    queue.append( next )
//                }
//            }
//        }
//        
//        return nil
//    }
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
