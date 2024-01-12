//
//         FILE: day17.swift
//  DESCRIPTION: Advent of Code 2023 Day 17: Clumsy Crucible
//        NOTES: Thanks to 4HbQ in the subreddit for showing me the error of my ways.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/16/23 21:00:01
//

import Foundation
import Library

extension DirectionUDLR {
    var orthogonal: [ DirectionUDLR] {
        switch self {
        case .up, .down:
            return [ .left, .right ]
        case .left, .right:
            return [ .up, .down ]
        }
    }
}


struct SeenNode: Hashable {
    let position: Point2D
    let direction: DirectionUDLR
    
    init( node: QueueNode ) {
        position = node.position
        direction = node.direction
    }
}


struct QueueNode: Comparable {
    let heatLoss: Int
    let position: Point2D
    let direction: DirectionUDLR
    
    static func < ( lhs: QueueNode, rhs: QueueNode ) -> Bool { lhs.heatLoss < rhs.heatLoss }
}


struct City {
    let blocks: [[Int]]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        blocks = lines.map { $0.map { Int( String( $0 ) )! } }
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: blocks[0].count, height: blocks.count )!
    }
    
    subscript( _ point: Point2D ) -> Int {
        blocks[point.y][point.x]
    }
    
    func leastHeatLoss( start: Point2D, end: Point2D, moveRange: ClosedRange<Int> ) -> Int? {
        var seen = Set<SeenNode>()
        var queue = MinHeap( items: [
            QueueNode( heatLoss: 0, position: start, direction: .right ),
            QueueNode( heatLoss: 0, position: start, direction: .down )
        ] )
        
        while let current = queue.poll() {
            if current.position == end { return current.heatLoss }
            if seen.insert( SeenNode( node: current ) ).inserted {
                for direction in current.direction.orthogonal {
                    for index in moveRange {
                        if bounds.contains( point: current.position + index * direction.vector ) {
                            let heat = ( 1 ... index ).reduce( 0 ) {
                                $0 + self[ current.position + $1 * direction.vector ]
                            }
                            queue.add(
                                QueueNode(
                                    heatLoss: current.heatLoss + heat,
                                    position: current.position + index * direction.vector,
                                    direction: direction
                                )
                            )
                        }
                    }
                }
            }
        }
        return nil
    }
}


func part1( input: AOCinput ) -> String {
    let city = City( lines: input.lines )
    let least = city.leastHeatLoss( start: city.bounds.min, end: city.bounds.max, moveRange: 1 ... 3 )!

    return "\( least )"
}


func part2( input: AOCinput ) -> String {
    let city = City( lines: input.lines )
    let least = city.leastHeatLoss( start: city.bounds.min, end: city.bounds.max, moveRange: 4 ... 10 )!

    return "\( least )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
