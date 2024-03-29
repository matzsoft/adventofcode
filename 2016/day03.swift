//
//         FILE: main.swift
//  DESCRIPTION: day03 - Easter Bunny Valid Triangles
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/24/21 16:56:26
//

import Foundation
import Library


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map( { $0.split(separator: " ").map( { Int($0)! } ) } )
}


func part1( input: AOCinput ) -> String {
    let triangles = parse( input: input ).map( { $0.sorted() { $0 < $1 } } )
    
    return "\(triangles.filter( { $0[0] + $0[1] > $0[2] } ).count)"
}


func part2( input: AOCinput ) -> String {
    let rawData = parse( input: input )
    var triangles: [[Int]] = []

    for index in stride( from: 0, to: rawData.count, by: 3 ) {
        triangles.append( [ rawData[index][0], rawData[index+1][0], rawData[index+2][0] ].sorted() )
        triangles.append( [ rawData[index][1], rawData[index+1][1], rawData[index+2][1] ].sorted() )
        triangles.append( [ rawData[index][2], rawData[index+1][2], rawData[index+2][2] ].sorted() )
    }

    return "\(triangles.filter( { $0[0] + $0[1] > $0[2] } ).count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
