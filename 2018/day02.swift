//
//         FILE: main.swift
//  DESCRIPTION: day02 - Inventory Management System
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/26/21 17:01:15
//

import Foundation


func parse( input: AOCinput ) -> [String] {
    return input.lines
}


func part1( input: AOCinput ) -> String {
    let lines = parse( input: input )
    let ( twoCount, threeCount ) = lines.reduce( ( 0, 0 ) ) {
        let histogram = $1.reduce( into: [ Character : Int ]() ) { $0[$1] = ( $0[$1] ?? 0 ) + 1 }
        
        return (
            $0.0 + ( histogram.contains( where: { $0.value == 2 } ) ? 1 : 0 ),
            $0.1 + ( histogram.contains( where: { $0.value == 3 } ) ? 1 : 0 )
        )
    }

    return "\(twoCount * threeCount)"
}


func part2( input: AOCinput ) -> String {
    let lines = parse( input: input )
    
    for i in 0 ..< lines.count - 1 {
        var arrayI = Array( lines[i] )
        
        for j in i + 1 ..< lines.count {
            let arrayJ = Array( lines[j] )
            let indices = zip( arrayI, arrayJ ).enumerated().filter { $0.element.0 != $0.element.1 }

            if indices.count == 1 {
                arrayI.remove( at: indices[0].offset )
                return "\(String( arrayI ))"
            }
        }
    }
    
    return "Failure"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
