//
//         FILE: day12.swift
//  DESCRIPTION: Advent of Code 2024 Day 12: Garden Groups
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/24 21:36:35
//

import Foundation
import Library

struct Plot {
    let type: Character
    var region: Int?
}

struct Region {
    let type: Character
    let area: Int
    let perimeter: Int
}

struct Garden {
    var plots: [[Plot]]
    var regionCount: Int
    let bounds: Rect2D
    
    init( lines: [String] ) {
        plots = lines.map { $0.map { Plot( type: $0, region: nil ) } }
        regionCount = 0
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: plots[0].count, height: plots.count
        )!
    }
    
    subscript( point: Point2D ) -> Plot {
        get { plots[point.y][point.x] }
        set { plots[point.y][point.x] = newValue }
    }

    mutating func regions() -> Int {
        var regions = [Region]()
        var unexamined = Set( bounds.points )
        
        while !unexamined.isEmpty {
            var queue = [unexamined.removeFirst()]
            var region = Set<Point2D>()
            var perimeter = 0
            let type = self[queue[0]].type
            
            while !queue.isEmpty {
                let next = queue.removeFirst()
                unexamined.remove( next )
                if region.insert( next ).inserted {
                    let neighbors = Direction4.allCases
                        .map { next + $0.vector }
                        .filter {
                            bounds.contains( point: $0 ) && self[$0].type == type
                        }
                    perimeter += 4 - neighbors.count
                    let remaining = neighbors.filter { unexamined.contains( $0 ) }
                    queue.append( contentsOf: remaining )
                }
            }
            regions.append(
                Region( type: type, area: region.count, perimeter: perimeter )
            )
        }
        
        let price = regions.map { $0.area * $0.perimeter }.reduce( 0, + )

        return price
    }
}

func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var garden = Garden( lines: input.lines )
    return "\(garden.regions())"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
