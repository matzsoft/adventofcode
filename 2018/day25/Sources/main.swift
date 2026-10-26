//
//         FILE: main.swift
//  DESCRIPTION: day25 - Four-Dimensional Adventure
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 13:24:31
//

import Foundation
import Library


func parse( input: AOCinput ) -> [Point4D] {
    return input.lines.map { line -> Point4D in
        let numbers = line.split( separator: "," ).map { Int( $0 )! }
        return Point4D( x: numbers[0], y: numbers[1], z: numbers[2], t: numbers[3] )
    }
}


func part1( input: AOCinput ) -> String {
    let points = parse( input: input )
    var neighbors = Array( repeating: Set<Int>(), count: points.count )
    var constellations: [ Set<Int> ] = []
    var unassigned = Set( 0 ..< points.count )
    
    for i in 0 ..< points.count {
        neighbors[i].insert( i )
        for j in i + 1 ..< points.count {
            if points[i].distance( other: points[j] ) <= 3 {
                neighbors[i].insert( j )
                neighbors[j].insert( i )
            }
        }
    }
    
    while let next = unassigned.first {
        var constellation = neighbors[next]
        var accumulator = constellation.subtracting( [next] )
        
        while accumulator.count > 0 {
            var nextRound = Set<Int>()
            
            for current in accumulator {
                nextRound.formUnion( neighbors[current] )
            }
            
            nextRound.subtract( constellation )
            constellation.formUnion( nextRound )
            accumulator = nextRound
        }
        
        constellations.append( constellation )
        unassigned.subtract( constellation )
    }
    
    return "\(constellations.count)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
