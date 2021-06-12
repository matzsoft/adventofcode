//
//         FILE: main.swift
//  DESCRIPTION: day01 - Find the Easter Bunny Headquarters.
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/23/21 12:54:23
//

import Foundation

struct Step {
    let turn: Turn
    let distance: Int
    
    init( value: Substring ) {
        turn = value.first! == "R" ? Turn.right : Turn.left
        distance = Int( value.dropFirst() )!
    }
}


func parse( input: AOCinput ) -> [Point2D] {
    let steps = input.line.split() { ", ".contains( $0 ) }.map { Step( value: $0 ) }
    var path = [ Point2D( x: 0, y: 0 ) ]
    var direction = Direction4.north
    
    for step in steps {
        direction = direction.turn( direction: step.turn )
        for _ in ( 0 ..< step.distance ) {
            path.append( path.last! + direction.vector )
        }
    }
    return path
}


func part1( input: AOCinput ) -> String {
    let path = parse( input: input )
    return "\(path.last!.magnitude)"
}


func part2( input: AOCinput ) -> String {
    let path = parse( input: input )
    var seen = Set<Point2D>()
    
    guard let point = path.first( where: { !seen.insert( $0 ).inserted } ) else { return "" }

    return "\(abs(point.x) + abs(point.y))"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
