//
//         FILE: main.swift
//  DESCRIPTION: day01 - Not Quite Lisp
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/03/21 16:38:15
//

import Foundation


func part1( input: AOCinput ) -> String {
    let up = input.line.filter { $0 == "(" }.count
    let down = input.line.filter { $0 == ")" }.count
    
    return "\( up - down )"
}


func part2( input: AOCinput ) -> String {
    var floor = 0
    
    for ( position, direction ) in input.line.enumerated() {
        switch direction {
        case "(":
            floor += 1
        case ")":
            floor -= 1
            if floor == -1 { return "\( position + 1 )" }
        default:
            return "Invalid input \(direction) at position \( position + 1 )"
        }
    }
    
    return "Never makes it to the basement"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
