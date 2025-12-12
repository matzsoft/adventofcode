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

struct Canvas: Hashable {
    let bounds: Rect2D
    var buffer: [[Character]]
    
    init( rect: Rect2D ) {
        bounds = rect
        buffer = Array(
            repeating: Array( repeating: ".", count: rect.width ),
            count: rect.height
        )
    }
    
    mutating func draw( line: Line2D, char: Character, ends: Character? = nil ) {
        for x in line.xRange {
            for y in line.yRange {
                buffer[y - bounds.min.y][x - bounds.min.x] = char
            }
        }
        if let ends = ends {
            buffer[line.start.y - bounds.min.y][line.start.x - bounds.min.x] = ends
            buffer[line.end.y - bounds.min.y][line.end.x - bounds.min.x] = ends
        }
    }
    
    func print() {
        buffer.forEach { Swift.print( String( $0 ) ) }
    }
}

struct Line2D: Hashable {
    enum Direction: Hashable { case up, down, left, right }
    
    let start: Point2D
    let end: Point2D
    let direction: Direction
    let length: Int
    
    var isHorizontal: Bool { start.y == end.y }
    var isVertical: Bool { start.x == end.x }
    
    var xRange: ClosedRange<Int> {
        return min( start.x, end.x ) ... max( start.x, end.x )
    }
    
    var yRange: ClosedRange<Int> {
        return min( start.y, end.y ) ... max( start.y, end.y )
    }
    
    internal init( start: Point2D, end: Point2D ) {
        self.start = start
        self.end = end
        
        if start.x == end.x {
            direction = start.y < end.y ? .down : .up
            length = abs( start.y - end.y ) + 1
        } else {
            direction = start.x < end.x ? .right : .left
            length = abs( start.x - end.x ) + 1
        }
    }
}


extension Rect2D {
    var lowerLeft: Point2D { .init( x: min.x, y: max.y ) }
    var upperRight: Point2D { .init( x: max.x, y: min.y ) }
    var lines: [Line2D] {
        return [
            Line2D( start: min,        end: upperRight ),
            Line2D( start: upperRight, end: max ),
            Line2D( start: lowerLeft,  end: max ),
            Line2D( start: min,        end: lowerLeft ),
        ]
    }
}

struct Shape {
    let lines: [Line2D]
    let bounds: Rect2D
    let vertical: [Line2D]
    let horizontal: [Line2D]

    init( points: [Point2D] ) {
        lines = ( 0 ..< points.count ).reduce( into: [Line2D]() ) {
            let this = points[$1]
            let next = points[ ( $1 + 1 ) % points.count ]
            $0.append( Line2D( start: this, end: next ) )
        }
        
        bounds = Rect2D( points: points )
        vertical = lines.filter { $0.isVertical }
        horizontal = lines.filter { $0.isHorizontal }
    }
    
    func contains( _ point: Point2D ) -> Bool {
        if lines.contains( where: {
            $0.xRange.contains( point.x ) && $0.yRange.contains( point.y )
        } ) {
            return true
        }
        
        let crosses = vertical.filter {
            $0.yRange.contains( point.y ) && $0.start.x > point.x
        }.sorted( by: { $0.start.x < $1.start.x } )
        if crosses.isEmpty { return false }

        let firstCross = crosses.min( by: { $0.start.x < $1.start.x } )!
        return firstCross.direction == .down
    }
    
    func contains( right line: Line2D, direction: Line2D.Direction ) -> Bool {
        if horizontal.contains( where: { $0.xRange.contains( line.xRange ) } ) {
            return true
        }
        let crosses = vertical.filter {
            $0.yRange.contains( line.start.y ) &&
            $0.start.x > line.start.x && $0.start.x < line.end.x
        }
        if crosses.isEmpty { return true }
        let sorted = crosses
            .filter( { $0.direction != .up } )
            .sorted( by: { $0.start.x < $1.start.x } )
        return sorted.allSatisfy { line.end.y == $0.end.y }
    }
    
    func contains( down line: Line2D, direction: Line2D.Direction ) -> Bool {
        if vertical.contains( where: { $0.yRange.contains( line.yRange ) } ) {
            return true
        }
        let crosses = horizontal.filter {
            $0.xRange.contains( line.start.x ) &&
            $0.start.y > line.start.y && $0.start.y < line.end.y
        }
        if crosses.isEmpty { return true }
        let sorted = crosses
            .filter( { $0.direction != .left } )
            .sorted( by: { $0.start.y < $1.start.y } )
        return sorted.allSatisfy { line.end.x == $0.end.x }
    }
    
    func contains( _ rect: Rect2D ) -> Bool {
        guard contains( rect.min )        else { return false }
        guard contains( rect.max )        else { return false }
        guard contains( rect.lowerLeft )  else { return false }
        guard contains( rect.upperRight ) else { return false }
        
        let rectLines = rect.lines
        guard contains( right: rectLines[0], direction: .up )    else { return false }
        guard contains( down:  rectLines[1], direction: .right ) else { return false }
        guard contains( right: rectLines[2], direction: .down )  else { return false }
        guard contains( down:  rectLines[3], direction: .left )  else { return false }
        
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
    let areas = ( 0 ..< tiles.count - 1 ).reduce( into: [Int]() ) {
        areas, index1 in
        for index2 in ( index1 + 1 ) ..< tiles.count {
            let rect = Rect2D( min: tiles[index1], max: tiles[index2] )
            areas.append( rect.area )
        }
    }
    return "\(areas.max()!)"
}

//                 1644094530
//                 2553538104
//                 4636745093
// 114207960 < x < 4584599609
func part2( input: AOCinput ) -> String {
    let tiles = parse( input: input )
    let shape = Shape( points: tiles )
        
//    let outerRect = Rect2D( points: tiles )
//    let boundingBox = outerRect.pad( byMinX: 2, byMaxX: 2, byMinY: 1, byMaxY: 1 )
//    for y in boundingBox.min.y ... boundingBox.max.y {
//        let line = ( boundingBox.min.x ... boundingBox.max.x )
//            .reduce( into: "" ) {
//                $0.append( shape.isOnLine( Point2D( x: $1, y: y ) ) ? "#" : "." )
//        }
//        print( line )
//    }
    
    let areas = ( 0 ..< tiles.count - 1 ).reduce( into: [Rect2D]() ) {
        areas, index1 in
        for index2 in ( index1 + 1 ) ..< tiles.count {
            let rect = Rect2D( min: tiles[index1], max: tiles[index2] )
            
            if shape.contains( rect ) {
                areas.append( rect )
            }
        }
    }
    
    let biggest = areas.max { $0.area < $1.area }!
//    let bounds = shape.bounds.pad( byMinX: 2, byMaxX: 1, byMinY: 1, byMaxY: 2 )
//    let danger = shape.lines.map { $0.length }.min()!
//    var canvas = Canvas( rect: bounds )
//    
//    biggest.lines.forEach( { canvas.draw( line: $0, char: "O" ) } )
//    shape.lines.forEach( { canvas.draw( line: $0, char: "X", ends: "#" ) } )
//    canvas.print()
//    
    return "\(biggest.area)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
