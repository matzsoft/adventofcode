//
//         FILE: main.swift
//  DESCRIPTION: day03 - Crossed Wires
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 15:55:02
//

import Foundation

struct Line {
    let bounds: Rect2D

    var vertical: Bool { bounds.min.x == bounds.max.x }
    var horizontal: Bool { bounds.min.y == bounds.max.y }

    init( start: Point2D, end: Point2D ) {
        bounds = Rect2D( min: start, max: end )
    }

    func contains( x: Int ) -> Bool {
        return bounds.min.x <= x && x <= bounds.max.x
    }
    
    func contains( y: Int ) -> Bool {
        return bounds.min.y <= y && y <= bounds.max.y
    }
    
    func contains( point: Point2D ) -> Bool {
        return bounds.contains( point: point )
    }

    func intersection( other: Line ) -> Point2D? {
        guard bounds.min.x != other.bounds.min.x || bounds.min.y != other.bounds.min.y else { return nil }

        if vertical && other.horizontal {
            if contains( y: other.bounds.min.y ) && other.contains( x: bounds.min.x ) {
                let result = Point2D( x: bounds.min.x, y: other.bounds.min.y )
                return result
            }
        } else if horizontal && other.vertical {
            if contains( x: other.bounds.min.x ) && other.contains( y: bounds.min.y ) {
                let result = Point2D( x: other.bounds.min.x, y: bounds.min.y )
                return result
            }
        }

        return nil
    }
}


struct Wire {
    let moves: [Point2D]
    
    init( from: String ) {
        moves = from.split( separator: "," ).map {
            let direction = DirectionUDLR( rawValue: String( $0.first! ) )!
            let distance = Int( $0.dropFirst() )!
            
            return distance * direction.vector
        }
    }
    
    func steps( point: Point2D ) -> Int {
        var currentP = Point2D( x: 0, y: 0 )
        var count = 0
        
        for move in moves {
            let nextP = currentP + move
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


func parse( input: AOCinput ) -> ( [Wire], [Point2D] ) {
    let wires = input.lines.map { Wire( from: $0 ) }
    var current1 = Point2D( x: 0, y: 0 )
    let intersections = wires[0].moves.flatMap { move1 -> [Point2D] in
        let next1 = current1 + move1
        let line1 = Line( start: current1, end: next1 )
        var current2 = Point2D( x: 0, y: 0 )
        
        current1 = next1
        return wires[1].moves.compactMap { move2 -> Point2D? in
            let next2 = current2 + move2
            let line2 = Line( start: current2, end: next2 )
            
            current2 = next2
            return line1.intersection( other: line2 )
        }
    }

    return ( wires, intersections )
}


func part1( input: AOCinput ) -> String {
    let origin = Point2D( x: 0, y: 0 )
    let ( _, intersections ) = parse( input: input )
    let closest = intersections.filter { $0 != origin }.min {
        $0.distance( other: Point2D( x: 0, y: 0) ) < $1.distance( other: Point2D( x: 0, y: 0 ) )
    }!
    
    return "\(closest.magnitude)"
}


func part2( input: AOCinput ) -> String {
    let origin = Point2D( x: 0, y: 0 )
    let ( wires, intersections ) = parse( input: input )
    let steps = intersections.filter { $0 != origin }.map {
        wires[0].steps( point: $0 ) + wires[1].steps( point: $0 )
    }.sorted()
    
    return "\(steps[0])"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
