//
//         FILE: day13.swift
//  DESCRIPTION: Advent of Code 2024 Day 13: Claw Contraption
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/12/24 21:00:00
//

import Foundation
import Library

struct Machine {
    let aButton: Point2D
    let bButton: Point2D
    let prize:   Point2D
    
    static func parse(
        line: String, delimiters: String, xIndex: Int, yIndex: Int ) -> Point2D
    {
        let fields = line.split( whereSeparator: { delimiters.contains( $0 ) } )
        return Point2D( x: Int( fields[xIndex] )!, y: Int( fields[yIndex] )! )
    }
    
    init( lines: [String], prizeIncrement: Int = 0 ) {
        aButton = Machine.parse(
            line: lines[0], delimiters: " ,+", xIndex: 3, yIndex: 5 )
        bButton = Machine.parse(
            line: lines[1], delimiters: " ,+", xIndex: 3, yIndex: 5 )
        
        let prize = Machine.parse(
            line: lines[2], delimiters: "=,", xIndex: 1, yIndex: 3 )
        let increment = Point2D( x: prizeIncrement, y: prizeIncrement )

        self.prize = prize + increment
    }

    var prizeCost: Int {
        let factor = gcd( aButton.x, aButton.y )
        let xmultiplier = aButton.y / factor
        let ymultiplier = aButton.x / factor
        
        let xprize = prize.x * xmultiplier
        let yprize = prize.y * ymultiplier
        let xb = bButton.x * xmultiplier
        let yb = bButton.y * ymultiplier
        
        let cdiff = xprize - yprize
        let bdiff = xb - yb
        
        guard cdiff % bdiff == 0 else { return 0 }
        
        let bvalue = cdiff / bdiff
        let numerator = prize.x - bvalue * bButton.x
        
        guard numerator % aButton.x == 0 else { return 0 }
        let avalue = numerator / aButton.x
        
        return 3 * avalue + bvalue
    }
}


func part1( input: AOCinput ) -> String {
    let machines = input.paragraphs.map { Machine( lines: $0 ) }
    return "\( machines.map { $0.prizeCost }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let machines = input.paragraphs.map {
        Machine( lines: $0, prizeIncrement: 10000000000000 )
    }
    return "\( machines.map { $0.prizeCost }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
