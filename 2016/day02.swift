//
//         FILE: main.swift
//  DESCRIPTION: day02 - Open the Easter Bunny Headquarters bathroom.
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/23/21 20:06:40
//

import Foundation

let pad9: [ Character : [ Character : Character ] ] = [
    "1" : [ "R" : "2", "D" : "4" ],
    "2" : [ "L" : "1", "R" : "3", "D" : "5" ],
    "3" : [ "L" : "2", "D" : "6", ],
    "4" : [ "U" : "1", "R" : "5", "D" : "7", ],
    "5" : [ "U" : "2", "L" : "4", "R" : "6", "D" : "8", ],
    "6" : [ "U" : "3", "L" : "5", "D" : "9", ],
    "7" : [ "U" : "4", "R" : "8", ],
    "8" : [ "U" : "5", "L" : "7", "R" : "9", ],
    "9" : [ "U" : "6", "L" : "8", ],
]

let pad13: [ Character : [ Character : Character ] ] = [
    "1" : [ "D" : "3" ],
    "2" : [ "R" : "3", "D" : "6" ],
    "3" : [ "U" : "1", "L" : "2", "R" : "4", "D" : "7", ],
    "4" : [ "L" : "3", "D" : "8", ],
    "5" : [ "R" : "6", ],
    "6" : [ "U" : "2", "L" : "5", "R" : "7", "D" : "A", ],
    "7" : [ "U" : "3", "L" : "6", "R" : "8", "D" : "B", ],
    "8" : [ "U" : "4", "L" : "7", "R" : "9", "D" : "C", ],
    "9" : [ "L" : "8", ],
    "A" : [ "U" : "6", "R" : "B", ],
    "B" : [ "U" : "7", "L" : "A", "R" : "C", "D" : "D", ],
    "C" : [ "U" : "8", "L" : "B", ],
    "D" : [ "U" : "B", ]
]


func process( input: AOCinput, pad: [ Character: [ Character : Character ] ] ) -> String {
    let lines = parse( input: input )
    var current: Character = "5"
    var result = ""

    for line in lines {
        for move in line {
            current = pad[current]?[move] ?? current
        }
        result.append( current )
    }
    return result
}


func parse( input: AOCinput ) -> [String] {
    return input.lines
}


func part1( input: AOCinput ) -> String {
    return process( input: input, pad: pad9 )
}


func part2( input: AOCinput ) -> String {
    return process( input: input, pad: pad13 )
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
