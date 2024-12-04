//
//         FILE: day04.swift
//  DESCRIPTION: Advent of Code 2024 Day 4: Ceres Search
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/03/24 21:00:00
//

import Foundation
import Library

struct WordSearch {
    let map: [[Character]]
    let bounds: Rect2D
    var position: Point2D
    
    init( lines: [String] ) {
        map = lines.map { $0.map { $0 } }
        position = Point2D( x: 0, y: 0 )
        bounds = Rect2D( min: position, width: lines[0].count, height: lines.count )!
    }
    
    subscript( location: Point2D ) -> Character? {
        get {
            guard bounds.contains( point: location ) else { return nil }
            return map[location.y][location.x]
        }
    }
    
    mutating func find( value: Character ) -> Point2D? {
        if self[position] == value { let found = position; next(); return found }
        
        while let candidate = next() {
            if self[candidate] == value { next(); return candidate }
        }
        
        return nil
    }
    
    @discardableResult
    mutating func next() -> Point2D? {
        guard bounds.contains( point: position ) else { return nil }
        
        position = position + Direction8.E.vector
        if bounds.contains( point: position ) { return position }
        
        position = Point2D( x: 0, y: position.y + 1 )
        if bounds.contains( point: position ) { return position }
        
        return nil
    }
}


func parse( input: AOCinput ) -> WordSearch {
    return WordSearch( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var wordSearch = parse( input: input )
    var count = 0
    
    while let nextX = wordSearch.find( value: "X" ) {
        for direction in Direction8.allCases {
            if wordSearch[ nextX + direction.vector ] != "M" { continue }
            if wordSearch[ nextX + 2 * direction.vector ] != "A" { continue }
            if wordSearch[ nextX + 3 * direction.vector ] == "S" {
                count += 1
            }
        }
    }
    return "\(count)"
}


func part2( input: AOCinput ) -> String {
    var wordSearch = parse( input: input )
    var count = 0
    let diagonals = [ Direction8.NW, Direction8.NE, Direction8.SE, Direction8.SW ]
    
    while let nextX = wordSearch.find( value: "A" ) {
        var masCount = 0
        for direction in diagonals {
            if wordSearch[ nextX + direction.vector ] == "M" {
                if wordSearch[ nextX + direction.opposite.vector ] == "S" {
                    masCount += 1
                }
            }
        }
        
        if masCount == 2 { count += 1}
    }
    
    return "\(count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
