//
//         FILE: day07.swift
//  DESCRIPTION: Advent of Code 2025 Day 7: Laboratories
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/25 21:00:45
//

import Foundation
import Library


func parse( input: AOCinput ) -> ( [Set<Int>], [Set<Int>] ) {
    let beams = [
        Set( arrayLiteral: Array( input.lines[0] ).firstIndex( of: "S" )! )
    ]
    let splitters = input.lines.map {
        let row = Array( $0 )
        return Set( row.indices.filter { row[$0] == "^" } )
    }
    return ( beams, splitters )
}


func process( input: AOCinput ) -> ( Int, Int ) {
    let ( initialBeams, splitters ) = parse( input: input )
    var paths = initialBeams.map {
        $0.reduce( into: [Int:Int]() ) { paths, beam in paths[beam] = 1 }
    }
    var splitCount = 0

    for index in 1 ..< splitters.count {
        if splitters[index].isEmpty {
            paths.append( paths[index-1] )
        } else {
            let newPaths = paths[index-1].reduce( into: [Int:Int]() ) {
                newPaths, beam in
                if !splitters[index].contains( beam.key ) {
                    newPaths[ beam.key, default: 0 ] += beam.value
                } else {
                    splitCount += 1
                    newPaths[ beam.key - 1, default: 0 ] += beam.value
                    newPaths[ beam.key + 1, default: 0 ] += beam.value
                }
            }
            paths.append( newPaths )
        }
    }
    return ( splitCount, paths.last!.values.reduce( 0, + ) )
}


func part1( input: AOCinput ) -> String {
    let ( splitCount, _ ) = process( input: input )
    return "\( splitCount )"
}

func part2( input: AOCinput ) -> String {
    let ( _, timelines ) = process( input: input )
    return "\(timelines)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
