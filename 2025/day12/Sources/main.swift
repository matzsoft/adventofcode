//
//         FILE: day12.swift
//  DESCRIPTION: Advent of Code 2025 Day 12: Christmas Tree Farm
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/25 21:00:04
//

import Foundation
import Library

struct Shape: Hashable, CustomStringConvertible {
    let map: [Set<Point2D>]
    let usedCount: Int
    
    var description: String {
        var lines = [ "usedCount: \(usedCount)", "", "", "" ]
        for map in self.map {
            var buffer = Array(
                repeating: Array( repeating: Character( "." ), count: 3 ), count: 3
            )
            for point in map {
                buffer[point.y][point.x] = "#"
            }
            lines[1].append( "\(String( buffer[0] )) " )
            lines[2].append( "\(String( buffer[1] )) " )
            lines[3].append( "\(String( buffer[2] )) " )
        }
        return lines.joined( separator: "\n" )
    }
    
    static func rotate( _ map: Set<Point2D> ) -> Set<Point2D> {
        map.reduce( into: Set<Point2D>() ) { $0.insert( Point2D( x: 2 - $1.y, y: $1.x ) ) }
    }
    
    static func flip( _ map: Set<Point2D> ) -> Set<Point2D> {
        map.reduce( into: Set<Point2D>() ) { $0.insert( Point2D( x: 2 - $1.x, y: $1.y ) ) }
    }
    
    init( lines: [String] ) {
        let characters = lines.dropFirst().map { Array( $0 ) }
        let original = ( 0 ..< characters.count ).reduce( into: Set<Point2D>() ) { map, y in
            for x in 0 ..< characters[y].count {
                if characters[y][x] == "#" { map.insert( Point2D( x: x, y: y ) ) }
            }
        }
        
        var seen = Set<Set<Point2D>>( [original] )
        var current = original
        var map = [original]

        while true {
            let rotated = Shape.rotate( current )
            if !seen.insert( rotated ).inserted {
                break
            }
            map.append( rotated )
            current = rotated
        }
        
        current = Self.flip( original )
        while true {
            if !seen.insert( current ).inserted { break }
            map.append( current )
            current = Shape.rotate( current )
        }
        
        self.map = map
        self.usedCount = original.count
    }
}

struct Region: Hashable {
    let bounds: Rect2D
    let shapes: [Int]
    
    init( line: String ) {
        let fields = line.split( whereSeparator: { "x: ".contains( $0 ) } )
            .map { Int( String( $0 ) )! }
        bounds = Rect2D( min: Point2D.origin, width: fields[0], height: fields[1] )!
        shapes = Array( fields[2...] )
        
    }
}


func parse( input: AOCinput ) -> ( [Shape], [Region] ) {
    let shapes = Array( input.paragraphs.dropLast() ).map { Shape( lines: $0 ) }
    let regions = input.paragraphs.last!.map { Region( line: $0 ) }
    return ( shapes, regions )
}


func part1( input: AOCinput ) -> String {
    let ( shapes, regions ) = parse( input: input )
    let pruned = regions.filter { region in
        let minArea = region.shapes.indices.reduce( 0 ) {
            $0 + shapes[ $1 ].usedCount * region.shapes[ $1 ]
        }
        return minArea <= region.bounds.area
    }
    
    return "\(pruned.count)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
