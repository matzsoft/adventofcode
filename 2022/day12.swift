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

func parse( input: AOCinput ) -> ( [ Point2D : Int ], Point2D, Point2D ) {
    let raw = input.lines.enumerated().reduce( into: [ Point2D : Character ]()) { dict, tuple in
        let ( rowIndex, row ) = tuple
        dict = row.enumerated().reduce( into: dict ) { dict, tuple in
            let ( colIndex, character ) = tuple
            dict[ Point2D( x: colIndex, y: rowIndex ) ] = character
        }
    }
    let map = raw.mapValues { character in
        switch character {
        case "S":
            return 0
        case "E":
            return 25
        default:
            return Int( character.asciiValue! - Character( "a" ).asciiValue! )
        }
    }
    let start = raw.first( where: { $1 == "S" } )!.key
    let target = raw.first( where: { $1 == "E" } )!.key
    return ( map, start, target )
}


struct Position {
    let position: Point2D
    let distance: Int
}

func shortestPath( map: [ Point2D : Int ], start: Point2D, target: Point2D ) -> Int? {
    var visited = Set( [ start ] )
    var queue = [ Position( position: start, distance: 0 ) ]
    
    while !queue.isEmpty {
        let position = queue.removeFirst()
        if position.position == target { return position.distance }
        
        for direction in DirectionUDLR.allCases {
            let next = position.position.move( direction: direction )
            if !visited.contains( next ) && map[next] != nil {
                if map[next]! < map[position.position]! + 2 {
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
    let startPoints = map.filter { $0.value == 0 }.map { $0.key }
    let distance = startPoints.compactMap { shortestPath( map: map, start: $0, target: target ) }.min()!
    return "\(distance)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
