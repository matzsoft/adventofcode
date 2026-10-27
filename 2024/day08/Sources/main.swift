//
//         FILE: day08.swift
//  DESCRIPTION: Advent of Code 2024 Day 8: Resonant Collinearity
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/07/24 22:04:09
//

import Foundation
import Library

struct Map {
    let antennas: [ Character : [Point2D] ]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0), width: lines[0].count, height: lines.count )!
        
        let characters = lines.map { Array<Character>( $0 ) }
        antennas = characters.indices.reduce( into: [ Character : [Point2D] ]() ) {
            antennas, y in
            
            for x in characters[y].indices {
                if characters[y][x] != "." {
                    antennas[ characters[y][x], default: [] ]
                        .append( Point2D(x: x, y: y ) )
                }
            }
        }
    }
    
    var antinodes: Set<Point2D> {
        antennas.keys.reduce( into: Set<Point2D>() ) { antinodes, key in
            let list = antennas[key]!
            for index1 in list.indices.dropLast() {
                for index2 in ( index1 + 1 ... list.indices.last! ) {
                    let vector = list[index1] - list[index2]
                    let first = list[index1] + vector
                    let second = list[index2] - vector
                    if bounds.contains( point: first ) { antinodes.insert( first ) }
                    if bounds.contains( point: second ) { antinodes.insert( second ) }
                }
            }
        }
    }
    
    var harmonics: Set<Point2D> {
        antennas.keys.reduce( into: Set<Point2D>() ) { antinodes, key in
            let list = antennas[key]!
            for index1 in list.indices.dropLast() {
                for index2 in ( index1 + 1 ... list.indices.last! ) {
                    let vector = list[index1] - list[index2]
                    var next = list[index1] - vector
                    
                    while bounds.contains( point: next ) {
                        antinodes.insert( next )
                        next = next - vector
                    }
                    
                    next = list[index2] + vector
                    while bounds.contains( point: next ) {
                        antinodes.insert( next )
                        next = next + vector
                    }
                }
            }
        }
    }
}


func part1( input: AOCinput ) -> String {
    "\(Map( lines: input.lines ).antinodes.count)"
}


func part2( input: AOCinput ) -> String {
    "\(Map( lines: input.lines ).harmonics.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
