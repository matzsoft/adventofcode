//
//         FILE: main.swift
//  DESCRIPTION: day01 - The Tyranny of the Rocket Equation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 14:18:25
//

import Foundation

func fuel( mass: Int ) -> Int {
    var total = 0
    var current = mass
    
    while true {
        let next = current / 3 - 2
        
        guard next > 0 else { break }
        total += next
        current = next
    }
    
    return total
}


func part1( input: AOCinput ) -> String {
    let modules = input.lines.map { Int( $0 )! }
    return "\(modules.map { $0 / 3 - 2 }.reduce( 0, + ))"
}


func part2( input: AOCinput ) -> String {
    let modules = input.lines.map { Int( $0 )! }
    return "\(modules.map { fuel( mass: $0 ) }.reduce( 0, + ))"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
