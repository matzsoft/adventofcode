//
//         FILE: day01.swift
//  DESCRIPTION: Advent of Code 2025 Day 1: Secret Entrance
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/30/25 21:00:01
//

import Foundation
import Library

let clicks = 100

struct Movement {
    enum Direction: String { case left = "L", right = "R" }
    let direction: Direction
    let count: Int
       
    init( line: String ) {
        self.direction = Direction( rawValue: String( line.first! ) )!
        self.count = Int( line.dropFirst() )!
    }
    
    func move( from position: Int ) -> Int {
        switch direction {
        case .left: return ( position + clicks - count ) % clicks
        case .right: return ( position + count ) % clicks
        }
    }
    
    func smartMove( from position: Int ) -> ( position: Int, passes: Int ) {
        switch direction {
        case .left:
            let newPos = ( ( position - count ) % clicks + clicks ) % clicks
            let altPosition = position == 0 ? 0 : clicks - position
            let passes = ( altPosition + count ) / clicks
            return ( newPos, passes )
        case .right:
            let newPos = ( position + count ) % clicks
            let passes = ( position + count ) / clicks
            return ( newPos, passes )
        }
    }
}

func part1( input: AOCinput ) -> String {
    let movements = input.lines.map( Movement.init )
    var position = 50
    var password = 0
    
    for move in movements {
        position = move.move( from: position )
        if position == 0 { password += 1 }
    }
    return "\(password)"
}


func part2( input: AOCinput ) -> String {
    let movements = input.lines.map( Movement.init )
    var position = 50
    var password = 0
    
    for move in movements {
        let results = move.smartMove( from: position )
        position = results.position
        password += results.passes
    }
    return "\(password)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
