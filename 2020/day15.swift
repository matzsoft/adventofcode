//
//         FILE: main.swift
//  DESCRIPTION: day15 - Rambunctious Recitation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/26/21 13:24:38
//

import Foundation

func speak( starting: [Int], limit: Int ) -> Int {
    var spoken = Array( starting.dropLast() )
    var already = Dictionary( zip( spoken, spoken.indices ), uniquingKeysWith: { (_, last) in last } )
    var speakNext = starting.last!

    for index in spoken.count ..< limit {
        let speakNow = speakNext
        spoken.append( speakNext )
        
        if let prevIndex = already[speakNow] {
            speakNext = index - prevIndex
        } else {
            speakNext = 0
        }
        already[speakNow] = index
    }
    
    return spoken.last!
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let starting = parse( input: input )
    return "\( speak( starting: starting, limit: 2020 ) )"
}


func part2( input: AOCinput ) -> String {
    let starting = parse( input: input )
    return "\( speak( starting: starting, limit: 30000000 ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
