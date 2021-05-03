//
//         FILE: main.swift
//  DESCRIPTION: day06 - Chronal Coordinates
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/01/21 15:14:58
//

import Foundation

extension Array where Element == Point2D {
    var boundingBox: Rect2D {
        guard !isEmpty else { return Rect2D( min: Point2D( x: 0, y: 0 ), max: Point2D(x: 0, y: 0 ) ) }
        
        let minX = self.min { $0.x < $1.x }!.x
        let minY = self.min { $0.y < $1.y }!.y
        let maxX = self.max { $0.x < $1.x }!.x
        let maxY = self.max { $0.y < $1.y }!.y
        
        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }
}


func parse( input: AOCinput ) -> [Point2D] {
    let lines = input.lines.map  { $0.split( whereSeparator: { ", ".contains($0) } ).map { Int($0)! } }
    return lines.map { Point2D( x: $0[0], y: $0[1] ) }
}


func part1( input: AOCinput ) -> String {
    let coordinates = parse( input: input )
    let bounds = coordinates.boundingBox
    let grid = ( bounds.min.y ... bounds.max.y ).map { y in
        ( bounds.min.x ... bounds.max.x ).map { ( x ) -> Int? in
            let distances = coordinates.map { $0.distance( other: Point2D( x: x, y: y ) ) }
            let minDistance = distances.min()!
            let closest = distances.enumerated().filter { $0.element == minDistance }.map { $0.offset }
            
            return closest.count == 1 ? closest[0] : nil
        }
    }
    let topAndBottom = grid[0] + grid.last!
    let edges = ( 1 ..< grid.count - 1 ).flatMap { [ grid[$0][0], grid[$0][grid[$0].count-1] ] }
    let borders = Set( ( topAndBottom + edges ).compactMap { $0 } )
    let histogram = grid.reduce( into: [Int:Int]() ) { dict, row in
        row.forEach {
            if let closest = $0, !borders.contains( closest ) { dict[closest] = ( dict[closest] ?? 0 ) + 1 }
        }
    }

    return "\(histogram.max( by: { $0.value < $1.value } )!.value )"
}


func part2( input: AOCinput ) -> String {
    let coordinates = parse( input: input )
    let bounds = coordinates.boundingBox
    let grid = ( bounds.min.y ... bounds.max.y ).map { y in
        ( bounds.min.x ... bounds.max.x ).map { ( x ) -> Int in
            let distances = coordinates.map { $0.distance( other: Point2D( x: x, y: y ) ) }
            
            return distances.reduce( 0, + )
        }
    }
    return "\(grid.flatMap { $0 }.filter { $0 < 10000 }.count)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
