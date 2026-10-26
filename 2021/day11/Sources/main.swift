//
//         FILE: main.swift
//  DESCRIPTION: day11 - Dumbo Octopus
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/10/21 22:48:15
//

import Foundation
import Library

struct Map: CustomStringConvertible {
    var map: [[Int]]
    
    subscript( position: Point2D ) -> Int {
        get { return map[position.y][position.x] }
        set( newValue ) { map[position.y][position.x] = newValue }
    }
    
    var points: [Point2D] {
        ( 1 ..< map.count - 1 ).map {
            row in ( 1 ..< map[0].count - 1 ).map { col in Point2D( x: col, y: row ) }
        }.flatMap { $0 }
    }
    
    var description: String {
        ( 1 ..< map.count - 1 ).map {
            row in ( 1 ..< map[0].count - 1 ).map { col in
                map[row][col] > 9 ? "*" : String( map[row][col] )
            }.joined()
        }.joined( separator: "\n" )
    }
    
    init( lines: [String] ) {
        let map = lines.map { $0.map { Int( String( $0 ) )! } }
        
        self.map =
            [ Array( repeating: 0, count: map[0].count + 2 ) ] +
            map.map { [ 0 ] + $0 + [ 0 ] } +
            [ Array( repeating: 0, count: map[0].count + 2 ) ]
    }
    
    @discardableResult mutating func step() -> Int {
        var stepFlashes = 0
        var flashes = 0

        for position in points { self[position] += 1 }
        repeat {
            flashes = 0
            
            for position in points {
                if self[position] > 9 {
                    self[position] = 0
                    flashes += 1
                    for direction in Direction8.allCases {
                        let neighbor = position + direction.vector
                        
                        if self[neighbor] > 0 { self[neighbor] += 1 }
                    }
                }
            }
            stepFlashes += flashes
        } while flashes > 0
        
        return stepFlashes
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var map = parse( input: input )
    let steps = Int( input.extras[0] )!
    let totalFlashes = ( 1 ... steps ).reduce( 0 ) { sum, _ in sum + map.step() }
    return "\(totalFlashes)"
}


func part2( input: AOCinput ) -> String {
    var map = parse( input: input )
    
    for step in 1 ... Int.max {
        map.step()
        if map.points.allSatisfy( { map[$0] == 0 } ) { return "\(step)"}
    }
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
