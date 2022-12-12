//
//         FILE: main.swift
//  DESCRIPTION: day12 - Hill Climbing Algorithm
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/22 21:12:08
//

import Foundation


func parse( input: AOCinput ) -> ( [[Int]], Point2D, Point2D ) {
    var start = Point2D( x: 0, y: 0 )
    var target = start
    let map = input.lines.enumerated().map { rowIndex, row in
        row.enumerated().map { colIndex, character in
            if character == "S" {
                start = Point2D( x: colIndex, y: rowIndex )
                return 0
            } else if character == "E" {
                target = Point2D( x: colIndex, y: rowIndex )
                return 25
            }
            return Int( character.asciiValue! - Character( "a" ).asciiValue! )
        }
    }
    return ( map, start, target )
}


struct Position {
    let position: Point2D
    let distance: Int
}

func shortestPath( map: [[Int]], start: Point2D, target: Point2D ) -> Int? {
    var visited = Set( [ start ] )
    let bounds = Rect2D( min: Point2D(x: 0, y: 0), width: map[0].count, height: map.count )!
    var queue = [ Position( position: start, distance: 0 ) ]
    
    while !queue.isEmpty {
        let position = queue.removeFirst()
        if position.position == target { return position.distance }
        
        for direction in DirectionUDLR.allCases {
            let next = position.position.move( direction: direction )
            if !visited.contains( next ) && bounds.contains( point: next ) {
                if map[next.y][next.x] < map[position.position.y][position.position.x] + 2 {
                    queue.append( Position( position: next, distance: position.distance + 1 ) )
                    visited.insert( next )
                }
            }
        }
        
    }
    return nil
}


func part1( input: AOCinput ) -> String {
    let ( map, start, target ) = parse( input: input )
    if let distance = shortestPath( map: map, start: start, target: target ) { return "\(distance)" }
        
    return "Not found"
}


func part2( input: AOCinput ) -> String {
    let ( map, _, target ) = parse( input: input )
    let startPoints = map.indices.flatMap { row in
        map[row].indices.compactMap { col in
            return map[row][col] == 0 ? Point2D( x: col, y: row ) : nil
        }
    }
    let distance = startPoints.compactMap { shortestPath( map: map, start: $0, target: target ) }.min()!
    return "\(distance)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
