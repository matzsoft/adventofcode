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

enum Content: Character { case ash = ".", rock = "#" }

struct Pattern: CustomStringConvertible {
    let original: [[Content]]
    let rotated: [[Content]]

    var score: Int {
        100 * score( field: original ) + score( field: rotated )
    }
    
    var description: String {
        (
            [
                "Original:",
                original.map { String( $0.map { $0.rawValue } ) }.joined( separator: "\n" ),
                "Rotated:",
                rotated.map { String( $0.map { $0.rawValue } ) }.joined( separator: "\n" ),
            ]
        ).joined( separator: "\n" )
    }
    
    init( lines: [String] ) {
        let original = lines.map { $0.map { Content( rawValue: $0 )! } }
        let initial = Array(
            repeating: Array( repeating: Content.ash, count: original.count ),
            count: original[0].count
        )
        rotated = original.indices.reduce( into: initial ) { rotated, y in
            original[y].indices.forEach { x in
                rotated[x][ original.count - 1 - y ] = original[y][x]
            }
        }
        self.original = original
    }
    
    func score( field: [[Content]] ) -> Int {
        func score( line: Int ) -> Int {
            let range = min( line, field.count - line )
            for index in 0 ..< range {
                if field[ line - 1 - index ] != field[ line + index ] { return 0 }
            }
            return line
        }
        
        guard let line = ( 1 ..< field.count ).first( where: { score( line: $0 ) != 0 } ) else {
            return 0
        }
                
        return line
    }
}


func parse( input: AOCinput ) -> [Pattern] {
    return input.paragraphs.map { Pattern( lines: $0 ) }
}

//func part2( input: AOCinput ) -> String {
//    let something = parse( input: input )
//    return ""
//}


func score( lines: [String] ) -> [Int] {
    func score( line: Int ) -> Int {
        let range = min( line, lines.count - line )
        for index in 0 ..< range {
            if lines[ line - 1 - index ] != lines[ line + index ] { return 0 }
        }
        return line
    }
    
    let blarg = ( 1 ..< lines.count ).map { score( line: $0 ) }.filter { $0 != 0 }
//    guard let line = ( 1 ..< lines.count ).first( where: { score( line: $0 ) != 0 } ) else {
//        return []
//    }
            
    return blarg
}


func rotate( lines: [String] ) -> [String] {
    lines[0].indices.reduce( into: [String]() ) { rotated, colIndex in
        rotated.append( String( lines.indices.map { rowIndex in lines[rowIndex][colIndex] } ) )
    }
}


func toggle( lines: [String], x: String.Index, y: Int ) -> [String] {
    var copy = lines
    copy[y] = lines[y].replacingCharacters( in: x ... x, with: lines[y][x] == "." ? "#" : "." )
    return copy
}


func lookForSmudge( lines: [String] ) -> Int {
    let original = score( lines: lines ).first ?? 0
    for y in lines.indices {
        for x in lines[y].indices {
            let toggled = toggle( lines: lines, x: x, y: y )
            let score = score( lines: toggled )
            
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
        100 * ( score( lines: $0 ).first ?? 0 ) + ( score( lines: rotate( lines: $0 ) ).first ?? 0 )
    }
    
    return "\( scores.reduce( 0, + ) )"
}

// > 18275
func part2( input: AOCinput ) -> String {
    let scores = input.paragraphs.map { findSmudge( lines: $0 ) }
    
//    for ( index, score ) in scores.enumerated() {
//        if score == 0 { print( input.paragraphs[index].joined( separator: "\n" ) ); break }
//    }
    return "\( scores.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
