//
//         FILE: main.swift
//  DESCRIPTION: day09 -
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/18/21 20:14:25
//

import Foundation

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


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
