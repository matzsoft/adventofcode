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

    var cost: Int {
        let aNumerator = bButton.y * prize.x - bButton.x * prize.y
        let aDenominator = aButton.x * bButton.y - aButton.y * bButton.x
        
        guard aNumerator % aDenominator == 0 else { return 0 }

        let bNumerator = aButton.y * prize.x - aButton.x * prize.y
        let bDenominator = bButton.x * aButton.y - aButton.x * bButton.y
        
        guard bNumerator % bDenominator == 0 else { return 0 }
        
        let a = aNumerator / aDenominator
        let b = bNumerator / bDenominator
        
        return 3 * a + b
    }
}


func part1( input: AOCinput ) -> String {
    let machines = input.paragraphs.map { Machine( lines: $0 ) }
    return "\( machines.map { $0.cost }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let machines = input.paragraphs.map {
        Machine( lines: $0, prizeIncrement: 10000000000000 )
    }
    return "\( machines.map { $0.cost }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
