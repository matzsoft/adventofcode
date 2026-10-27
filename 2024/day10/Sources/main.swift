//
//         FILE: day10.swift
//  DESCRIPTION: Advent of Code 2024 Day 10: Hoof It
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/24 21:00:27
//

import Foundation
import Library

struct Map {
    struct Ratings {
        var ratings: [[Int]]
        
        init( bounds: Rect2D ) {
            ratings = Array(
                repeating: Array( repeating: 0, count: bounds.width ),
                count: bounds.height
            )
        }
        
        subscript( point: Point2D ) -> Int {
            get { ratings[point.y][point.x] }
            set { ratings[point.y][point.x] = newValue }
        }
    }
    
    let positions: [[Int]]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        let positions = lines.map { $0.map { Int( String( $0 ) )! } }
        self.positions = positions
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ),
            width: positions[0].count, height: positions.count
        )!
    }
    
    subscript( point: Point2D ) -> Int {
        positions[point.y][point.x]
    }
    
    func findAll( value: Int ) -> [Point2D] {
        positions.indices.reduce( into: [Point2D]() ) { all, y in
            positions[y].indices.forEach { x in
                if positions[y][x] == value { all.append( Point2D( x: x, y: y ) ) }
            }
        }
    }
    
    func countNines( trailhead: Point2D ) -> Int {
        var queue = [ trailhead ]
        var seen = Set<Point2D>( queue )
        
        while !queue.isEmpty {
            let point = queue.removeFirst()
            let neighbors = Direction4.allCases.map { point + $0.vector }.filter {
                bounds.contains( point: $0 )
                && !seen.contains( $0 )
                && self[point] + 1 == self[$0]
            }
            seen.formUnion( neighbors )
            queue.append( contentsOf: neighbors )
        }
        return seen.filter { self[$0] == 9 }.count
    }
    
    func countAll() -> Int {
        findAll( value: 0 ).reduce( 0 ) { $0 + countNines( trailhead: $1 ) }
    }
    
    func sumRatings() -> Int {
        var ratings = Ratings( bounds: bounds )
        
        findAll( value: 9 ).forEach { ratings[$0] = 1 }
        ( 0 ..< 9 ).reversed().forEach { value in
            findAll( value: value ).forEach { point in
                let neighbors = Direction4.allCases.map { point + $0.vector }.filter {
                    bounds.contains( point: $0 )
                    && self[point] + 1 == self[$0]
                }
                ratings[point] = neighbors.reduce( 0 ) { $0 + ratings[$1] }
            }
        }
        return findAll( value: 0 ).reduce( 0 ) { $0 + ratings[$1] }
    }
}


func part1( input: AOCinput ) -> String {
    return "\(Map( lines: input.lines ).countAll())"
}


func part2( input: AOCinput ) -> String {
    return "\(Map( lines: input.lines ).sumRatings())"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
