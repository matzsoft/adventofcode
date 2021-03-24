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

let size = 2
var position = Point2D( x: 1, y: 1 )
var current: Character = "5"

let movement: [ Character : () -> Void ] = [
    "U" : { () -> Void in position = Point2D( x: position.x, y: max( 0, position.y - 1 ) ) },
    "D" : { () -> Void in position = Point2D( x: position.x, y: min( size, position.y + 1 ) ) },
    "L" : { () -> Void in position = Point2D( x: max( 0, position.x - 1 ), y: position.y ) },
    "R" : { () -> Void in position = Point2D( x: min( size, position.x + 1 ), y: position.y ) }
]
let mapping: [ Character : [ Character : () -> Void ] ] = [
    "1" : [
        "D" : { () -> Void in current = "3" } ],
    "2" : [
        "R" : { () -> Void in current = "3" },
        "D" : { () -> Void in current = "6" } ],
    "3" : [
        "U" : { () -> Void in current = "1" },
        "L" : { () -> Void in current = "2" },
        "R" : { () -> Void in current = "4" },
        "D" : { () -> Void in current = "7" }, ],
    "4" : [
        "L" : { () -> Void in current = "3" },
        "D" : { () -> Void in current = "8" }, ],
    "5" : [
        "R" : { () -> Void in current = "6" }, ],
    "6" : [
        "U" : { () -> Void in current = "2" },
        "L" : { () -> Void in current = "5" },
        "R" : { () -> Void in current = "7" },
        "D" : { () -> Void in current = "A" }, ],
    "7" : [
        "U" : { () -> Void in current = "3" },
        "L" : { () -> Void in current = "6" },
        "R" : { () -> Void in current = "8" },
        "D" : { () -> Void in current = "B" }, ],
    "8" : [
        "U" : { () -> Void in current = "4" },
        "L" : { () -> Void in current = "7" },
        "R" : { () -> Void in current = "9" },
        "D" : { () -> Void in current = "C" }, ],
    "9" : [
        "L" : { () -> Void in current = "8" }, ],
    "A" : [
        "U" : { () -> Void in current = "6" },
        "R" : { () -> Void in current = "B" }, ],
    "B" : [
        "U" : { () -> Void in current = "7" },
        "L" : { () -> Void in current = "A" },
        "R" : { () -> Void in current = "C" },
        "D" : { () -> Void in current = "D" }, ],
    "C" : [
        "U" : { () -> Void in current = "8" },
        "L" : { () -> Void in current = "B" }, ],
    "D" : [
        "U" : { () -> Void in current = "B" }, ]
]


func parse( input: AOCinput ) -> [String] {
    return input.lines
}


func part1( input: AOCinput ) -> String {
    let lines = parse( input: input )
    var result = ""
    
    for line in lines {
        for move in line {
            movement[move]?()
        }
        result.append( Character( String( position.y * ( size + 1 ) + position.x + 1 ) ) )
    }
    return result
}


func part2( input: AOCinput ) -> String {
    let lines = parse( input: input )
    var result = ""
    
    for line in lines {
        for move in line {
            mapping[current]?[move]?()
        }
        result.append( current )
    }
    return result
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
