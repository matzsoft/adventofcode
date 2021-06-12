//
//         FILE: main.swift
//  DESCRIPTION: day06 - Chronal Coordinates
//        NOTES: part3 and part4 are an attempt to improve performance by migrating code into the loop.
//               They were only marginally successful but I have left them in for show.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/01/21 15:14:58
//

import Foundation

func parse( input: AOCinput ) -> [Point2D] {
    let lines = input.lines.map  { $0.split( whereSeparator: { ", ".contains($0) } ).map { Int($0)! } }
    return lines.map { Point2D( x: $0[0], y: $0[1] ) }
}


func part1( input: AOCinput ) -> String {
    let coordinates = parse( input: input )
    let bounds = Rect2D( points: coordinates )
    let grid = ( bounds.min.y ... bounds.max.y ).map { y in
        ( bounds.min.x ... bounds.max.x ).map { ( x ) -> Int? in
            let distances = coordinates.map { $0.distance( other: Point2D( x: x, y: y ) ) }
            let minDistance = distances.min()!
            let closest = distances.enumerated().filter { $0.element == minDistance }.map { $0.offset }
            
            return closest.count == 1 ? closest[0] : nil
        }
    }
    let leftEdge = ( 1 ..< grid.count - 1 ).map { grid[$0][0] }
    let rightEdge = ( 1 ..< grid.count - 1 ).map { grid[$0].last }
    let borders = Set( ( grid[0] + grid.last! + leftEdge + rightEdge ).compactMap { $0 } )
    let histogram = grid.reduce( into: [Int:Int]() ) { dict, row in
        row.forEach {
            if let closest = $0, !borders.contains( closest ) { dict[closest] = ( dict[closest] ?? 0 ) + 1 }
        }
    }

    return "\(histogram.max( by: { $0.value < $1.value } )!.value )"
}


func part2( input: AOCinput ) -> String {
    let coordinates = parse( input: input )
    let bounds = Rect2D( points: coordinates )
    let grid = ( bounds.min.y ... bounds.max.y ).map { y in
        ( bounds.min.x ... bounds.max.x ).map { ( x ) -> Int in
            let distances = coordinates.map { $0.distance( other: Point2D( x: x, y: y ) ) }
            
            return distances.reduce( 0, + )
        }
    }
    return "\(grid.flatMap { $0 }.filter { $0 < 10000 }.count)"
}


func part3( input: AOCinput ) -> String {
    let points = parse( input: input )
    let bounds = Rect2D( points: points )
    var hitsEdge = Set<Int>();
    let grid = ( bounds.min.y ... bounds.max.y ).map { ( y ) ->[Int?] in
        let onEdge = y == bounds.min.y || y == bounds.max.y
        return ( bounds.min.x ... bounds.max.x ).map { ( x ) -> Int? in
            let distances = points.map { $0.distance( other: Point2D( x: x, y: y ) ) }
            let minDistance = distances.min()!
            let closest = distances.enumerated().filter { $0.element == minDistance }.map { $0.offset }
            
            if closest.count > 1 { return nil }
            if onEdge || x == bounds.min.x || x == bounds.max.x { hitsEdge.insert( closest[0] ) }
            return closest[0]
        }
    }
    let histogram = grid.reduce( into: [Int:Int]() ) { dict, row in
        row.forEach {
            if let closest = $0, !hitsEdge.contains( closest ) {
                dict[closest] = ( dict[closest] ?? 0 ) + 1
            }
        }
    }

    return "\(histogram.max( by: { $0.value < $1.value } )!.value )"
}


func part4( input: AOCinput ) -> String {
    let coordinates = parse( input: input )
    let bounds = Rect2D( points: coordinates )
    var size = 0
    
    for y in ( bounds.min.y ... bounds.max.y ) {
        for x in ( bounds.min.x ... bounds.max.x ) {
            let distance = coordinates.map { $0.distance( other: Point2D( x: x, y: y ) ) }.reduce( 0, + )
            
            if distance < 10000 { size += 1 }
        }
    }

    return "\(size)"
}


try runTestsPart1( part1: part1 )
try runTestsPart1( part1: part3, label: "Experimental" )
try runTestsPart2( part2: part2 )
try runTestsPart2( part2: part4, label: "Experimental" )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
try runPart1( part1: part3, label: "Experimental" )
try runPart2( part2: part4, label: "Experimental" )
