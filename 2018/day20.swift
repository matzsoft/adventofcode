//
//         FILE: main.swift
//  DESCRIPTION: day20 - A Regular Map
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/28/21 15:55:59
//

import Foundation

func parse( input: AOCinput ) -> [Int] {
    var current = Point2D( x: 0, y: 0 )
    var seen    = [ current : 0 ]
    var stack   = [ Point2D ]()
    let directions: [ Character : Point2D ] = [
        "N" : Direction4.north.vector,
        "E" : Direction4.east.vector,
        "S" : Direction4.south.vector,
        "W" : Direction4.west.vector
    ]

    let line = input.line
    for char in line[ line.index( after: line.startIndex ) ..< line.index( before: line.endIndex ) ] {
        switch char {
        case "N", "E", "S", "W":
            let nextCount = seen[current]! + 1

            current = current + directions[char]!
            if let oldCount = seen[current] {
                seen[current] = min( oldCount, nextCount )
            } else {
                seen[current] = nextCount
            }
        case "(":
            stack.append( current )
        case ")":
            stack.removeLast()
        case "|":
            current = stack.last!
        default:
            print( "Invalid character '\(char)' in input" )
            exit(1)
        }
    }
    return Array( seen.values )
}


func part1( input: AOCinput ) -> String {
    let counts = parse( input: input )
    return "\(counts.max()!)"
}


func part2( input: AOCinput ) -> String {
    let counts = parse( input: input )
    return "\(counts.filter { $0 >= 1000 }.count)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
