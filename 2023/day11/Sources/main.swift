//
//         FILE: day11.swift
//  DESCRIPTION: Advent of Code 2023 Day 11: Cosmic Expansion
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/10/23 21:02:10
//

import Foundation
import Library

extension Range {
    init( bounds bound1: Bound, _ bound2: Bound ) {
        let bounds = [ bound1, bound2 ].sorted()
        self = bounds[0] ..< bounds[1]
    }
}

enum Content: Character { case galaxy = "#", space = "." }

struct Universe {
    let galaxies: [Point2D]
    let expandedRows: [Int]
    let expandedCols: [Int]
    
    init( lines: [String] ) {
        let image = lines.map { $0.map { Content( rawValue: $0 )! } }
        
        expandedRows = image.indices.filter { image[$0].allSatisfy( { $0 == .space } ) }
        expandedCols = image[0].indices.filter { x in
            image.indices.allSatisfy( { image[$0][x] == .space } )
        }
        galaxies = image.indices.reduce( into: [Point2D]() ) { galaxies, y in
            image[y].indices.forEach { x in
                if image[y][x] == .galaxy { galaxies.append( Point2D( x: x, y: y ) ) }
            }
        }
    }
    
    func findExpansion( between galaxy1: Point2D, and galaxy2: Point2D ) -> Int {
        let xRange  = Range( bounds: galaxy1.x, galaxy2.x )
        let yRange  = Range( bounds: galaxy1.y, galaxy2.y )
        let xExpanse = expandedCols.filter { xRange.contains( $0 ) }.count
        let yExpanse = expandedRows.filter { yRange.contains( $0 ) }.count
        
        return xExpanse + yExpanse
    }
    
    func distances( expansion: Int ) -> [Int] {
        let galaxies = self.galaxies
        return ( 1 ..< galaxies.count ).reduce( into: [Int]() ) { distances, index1 in
            ( index1 ..< galaxies.count ).forEach { index2 in
                let base = galaxies[ index1 - 1 ].distance( other: galaxies[index2] )
                let extra = findExpansion( between: galaxies[ index1 - 1 ], and: galaxies[index2] )

                distances.append( base + ( expansion - 1 ) * extra )
            }
        }
    }
}


func part1( input: AOCinput ) -> String {
    let distances = Universe( lines: input.lines ).distances( expansion: 2 )

    return "\( distances.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let distances = Universe( lines: input.lines ).distances( expansion: Int( input.extras[0] )! )

    return "\( distances.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
