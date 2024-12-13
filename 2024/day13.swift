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
    
    init( lines: [String], prizeIncrement: Int = 0 ) {
        let aInfo = lines[0].split( whereSeparator: { " ,+".contains( $0 ) } )
        let bInfo = lines[1].split( whereSeparator: { " ,+".contains( $0 ) } )
        let pInfo = lines[2].split( whereSeparator: { "=,".contains( $0 ) } )
        
        aButton = Point2D( x: Int( aInfo[3] )!, y: Int( aInfo[5] )! )
        bButton = Point2D( x: Int( bInfo[3] )!, y: Int( bInfo[5] )! )
        prize   = Point2D(
            x: Int( pInfo[1] )! + prizeIncrement,
            y: Int( pInfo[3] )! + prizeIncrement
        )
    }

    var prizeCost: Int {
        let factor = gcd( aButton.x, aButton.y )
        let xmultiplier = aButton.y / factor
        let ymultiplier = aButton.x / factor
        
        let xprize = prize.x * xmultiplier
        let yprize = prize.y * ymultiplier
        let xb = bButton.x * xmultiplier
        let yb = bButton.y * ymultiplier
        
        let cdiff = abs( xprize - yprize )
        let bdiff = abs( xb - yb )
        
        guard cdiff % bdiff == 0 else { return 0 }
        
        let bvalue = cdiff / bdiff
        let numerator = prize.x - bvalue * bButton.x
        
        guard numerator % aButton.x == 0 else { return 0 }
        let avalue = ( prize.x - bvalue * bButton.x ) / aButton.x
        
        return 3 * avalue + bvalue
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let machines = input.paragraphs.map { Machine( lines: $0 ) }
    let costs = machines.map { $0.prizeCost }
    return "\( costs.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let machines = input.paragraphs.map {
        Machine( lines: $0, prizeIncrement: 10000000000000 )
    }
    let costs = machines.map { $0.prizeCost }
    return "\( costs.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
