//
//         FILE: main.swift
//  DESCRIPTION: day09 - Stream Processing
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/18/21 20:14:25
//

import Foundation
import Library

enum State { case groups, garbage, ignore }

func parse( input: AOCinput ) -> ( Int, Int ) {
    var state = State.groups
    var depth = 0
    var score = 0
    var count = 0
    
    for char in input.line {
        switch state {
        case .groups:
            switch char {
            case "{":
                depth += 1
                score += depth
            case "}":
                depth -= 1
            case "<":
                state = .garbage
            default:
                break
            }
        case .garbage:
            switch char {
            case ">":
                state = .groups
            case "!":
                state = .ignore
            default:
                count += 1
            }
        case .ignore:
            state = .garbage
        }
    }
    
    return ( score, count )
}


func part1( input: AOCinput ) -> String {
    return "\(parse( input: input ).0)"
}


func part2( input: AOCinput ) -> String {
    return "\(parse( input: input ).1)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
