//
//         FILE: day09.swift
//  DESCRIPTION: Advent of Code 2025 Day 9: Movie Theater
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/08/25 21:00:01
//

import Foundation
import Library

struct Line2D: Hashable {
    enum Direction: Hashable { case up, down, left, right }
    
    let start: Point2D
    let end: Point2D
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let direction: Direction
    let isHorizontal: Bool
    let isVertical: Bool
    
    init( start: Point2D, end: Point2D ) {
        self.start = start
        self.end = end
        self.xRange = min( start.x, end.x ) ... max( start.x, end.x )
        self.yRange = min( start.y, end.y ) ... max( start.y, end.y )
        
        if start.x == end.x {
            direction = start.y < end.y ? .down : .up
            isHorizontal = false
            isVertical = true
        } else {
            direction = start.x < end.x ? .right : .left
            isHorizontal = true
            isVertical = false
        }
    }
    
    func normalized() -> Line2D {
        switch direction {
        case .right, .down:
            return self
        case .up, .left:
            return Line2D( start: end, end: start )
        }
    }
}


struct Shape {
    let lines: [Line2D]
    let vertical: [Line2D]
    let horizontal: [Line2D]

    init( points: [Point2D] ) {
        lines = ( 0 ..< points.count ).reduce( into: [Line2D]() ) {
            let this = points[$1]
            let next = points[ ( $1 + 1 ) % points.count ]
            $0.append( Line2D( start: this, end: next ) )
        }
        
        vertical = lines.filter { $0.isVertical }
        horizontal = lines.filter { $0.isHorizontal }
    }
    
    func contains( _ point: Point2D ) -> Bool {
        let onLine = lines.contains( where: {
            $0.xRange.contains( point.x ) && $0.yRange.contains( point.y )
        } )
        if onLine { return true }
        
        let crosses = vertical.filter {
            $0.yRange.contains( point.y ) && $0.start.x > point.x
        }
        if crosses.isEmpty { return false }

        let firstCross = crosses.min( by: { $0.start.x < $1.start.x } )!
        return firstCross.direction == .down
    }
    
    func contains( right line: Line2D ) -> Bool {
        let crosses = vertical.filter {
            $0.yRange.contains( line.start.y ) &&
            $0.start.x > line.start.x && $0.start.x < line.end.x
        }
        if crosses.isEmpty { return true }
        let downs = crosses.filter( { $0.direction == .down } )
        return downs.allSatisfy { line.end.y == $0.end.y }
    }
    
    func contains( down line: Line2D ) -> Bool {
        let crosses = horizontal.filter {
            $0.xRange.contains( line.start.x ) &&
            $0.start.y > line.start.y && $0.start.y < line.end.y
        }
        if crosses.isEmpty { return true }
        let rights = crosses.filter( { $0.direction == .right } )
        return rights.allSatisfy { line.end.x == $0.end.x }
    }
    
    func contains( corner1: Point2D, corner2: Point2D ) -> Bool {
        let corner3 = Point2D( x: corner2.x, y: corner1.y )
        let corner4 = Point2D( x: corner1.x, y: corner2.y )

        guard contains( corner3 ) && contains( corner4 ) else { return false }
        
        let line13 = Line2D( start: corner1, end: corner3 ).normalized()
        let line14 = Line2D( start: corner1, end: corner4 ).normalized()
        let line23 = Line2D( start: corner2, end: corner3 ).normalized()
        let line24 = Line2D( start: corner2, end: corner4 ).normalized()
        
        guard contains( right: line13 ) else { return false }
        guard contains( down:  line14 ) else { return false }
        guard contains( right: line24 ) else { return false }
        guard contains( down:  line23 ) else { return false }
        
        return true
    }
}

func parse( input: AOCinput ) -> [Point2D] {
    input.lines.map {
        let numbers = $0.split( separator: "," ).map { Int( $0 )! }
        return Point2D( x: numbers[0], y: numbers[1] )
    }
}


func part1( input: AOCinput ) -> String {
    let tiles = parse( input: input )
    let areas = ( 0 ..< tiles.count - 1 ).reduce( into: [Int]() ) { areas, index1 in
        for index2 in ( index1 + 1 ) ..< tiles.count {
            let rect = Rect2D( min: tiles[index1], max: tiles[index2] )
            areas.append( rect.area )
        }
    }
    return "\(areas.max()!)"
}

func part2( input: AOCinput ) -> String {
    let tiles = parse( input: input )
    let shape = Shape( points: tiles )
        
    let areas = ( 0 ..< tiles.count - 1 ).reduce( into: [Int]() ) { areas, index1 in
        for index2 in ( index1 + 1 ) ..< tiles.count {
            if shape.contains( corner1: tiles[index1], corner2: tiles[index2] ) {
                let rect = Rect2D( min: tiles[index1], max: tiles[index2] )
                areas.append( rect.area )
            }
        }
    }
    
    return "\(areas.max()!)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
