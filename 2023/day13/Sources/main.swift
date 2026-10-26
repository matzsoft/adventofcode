//
//         FILE: day13.swift
//  DESCRIPTION: Advent of Code 2023 Day 13: Point of Incidence
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/12/23 21:00:00
//

import Foundation
import Library

func mirrors( lines: [String] ) -> [Int] {
    return ( 1 ..< lines.count )
        .map { line in
            let range = min( line, lines.count - line )
            for index in 0 ..< range {
                if lines[ line - 1 - index ] != lines[ line + index ] { return 0 }
            }
            return line
        }
        .filter { $0 != 0 }
}


func rotate( lines: [String] ) -> [String] {
    lines[0].indices.reduce( into: [String]() ) { rotated, x in
        rotated.append( String( lines.indices.map { y in lines[y][x] } ) )
    }
}


func toggle( lines: [String], x: String.Index, y: Int ) -> [String] {
    var copy = lines
    copy[y] = lines[y].replacingCharacters( in: x ... x, with: lines[y][x] == "." ? "#" : "." )
    return copy
}


func lookForSmudge( lines: [String] ) -> Int {
    let original = mirrors( lines: lines ).first ?? 0
    for y in lines.indices {
        for x in lines[y].indices {
            let toggled = toggle( lines: lines, x: x, y: y )
            let score = mirrors( lines: toggled )
            
            let different = score.filter { $0 != original }
            if !different.isEmpty { return different[0] }
        }
    }
    return 0
}


func findSmudge( lines: [String] ) -> Int {
    let vscore = lookForSmudge( lines: lines )
    if vscore != 0 { return 100 * vscore }
    return lookForSmudge( lines: rotate( lines: lines ) )
}


func part1( input: AOCinput ) -> String {
    let scores = input.paragraphs.map {
        100 * ( mirrors( lines: $0 ).first ?? 0 ) + ( mirrors( lines: rotate( lines: $0 ) ).first ?? 0 )
    }
    
    return "\( scores.reduce( 0, + ) )"
}

func part2( input: AOCinput ) -> String {
    let scores = input.paragraphs.map { findSmudge( lines: $0 ) }
    
    return "\( scores.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
