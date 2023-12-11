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

enum Content: Character { case galaxy = "#", space = "." }

struct Universe: CustomStringConvertible {
    let image: [[Content]]
    let expandedRows: [Int]
    let expandedCols: [Int]
    
    var description: String {
        image.map { String( $0.map { $0.rawValue } ) }.joined( separator: "\n" )
    }
    
    init( lines: [String] ) {
        let image = lines.map { $0.map { Content( rawValue: $0 )! } }
        
        self.image = image
        expandedRows = image.indices.filter { image[$0].allSatisfy( { $0 == .space } ) }
        expandedCols = image[0].indices.filter { x in
            image.indices.allSatisfy( { image[$0][x] == .space } )
        }
    }
    
    var galaxies: [ Point2D] {
        image.indices.reduce( into: [Point2D]() ) { galaxies, y in
            image[y].indices.forEach { x in
                if image[y][x] == .galaxy { galaxies.append( Point2D( x: x, y: y ) ) }
            }
        }
    }
    
    func find( expansion: Int, between galaxy1: Point2D, and galaxy2: Point2D ) -> Int {
        let xMin = min( galaxy1.x, galaxy2.x )
        let xMax = max( galaxy1.x, galaxy2.x )
        let yMin = min( galaxy1.y, galaxy2.y )
        let yMax = max( galaxy1.y, galaxy2.y )
        let xExpanse = ( expansion - 1 ) * expandedCols.filter { (xMin ..< xMax).contains( $0 ) }.count
        let yExpanse = ( expansion - 1 ) * expandedRows.filter { (yMin ..< yMax).contains( $0 ) }.count
        
        return xExpanse + yExpanse
    }
    
    func distances( expansion: Int ) -> [Int] {
        let galaxies = self.galaxies
        return ( 1 ..< galaxies.count ).reduce( into: [Int]() ) { distances, index1 in
            ( index1 ..< galaxies.count ).forEach { index2 in
                let base = galaxies[ index1 - 1 ].distance( other: galaxies[index2] )
                let extra = find(
                    expansion: expansion, between: galaxies[ index1 - 1 ], and: galaxies[index2] )

                distances.append( base + extra )
            }
        }
    }
}


func parse( input: AOCinput ) -> Universe {
    return Universe( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let universe = parse( input: input )
    let distances = universe.distances( expansion: 2 )

    return "\( distances.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let universe = parse( input: input )
    let distances = universe.distances( expansion: Int( input.extras[0] )! )

    return "\( distances.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
