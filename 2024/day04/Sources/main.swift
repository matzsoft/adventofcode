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
    
    init( lines: [String] ) {
        map = lines.map { $0.map { $0 } }
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: lines[0].count, height: lines.count )!
    }
    
    subscript( location: Point2D ) -> Character? {
        get {
            guard bounds.contains( point: location ) else { return nil }
            return map[location.y][location.x]
        }
    }
    
    func findAll( target: Character ) -> [Point2D] {
        bounds.points.compactMap { self[$0] == target ? $0 : nil }
    }
    
    func substr( start: Point2D, direction: Direction8, length: Int ) -> String {
        let array = ( 0 ..< length ).compactMap {
            self[ start + $0 * direction.vector ]
        }
        return String( array )
    }
}


func part1( input: AOCinput ) -> String {
    let wordSearch = WordSearch( lines: input.lines )
    let count = wordSearch.findAll( target: "X" ).reduce( 0 ) { sum, nextX in
        sum + Direction8.allCases.filter {
            wordSearch.substr( start: nextX, direction: $0, length: 4 ) == "XMAS"
        }.count
    }
    return "\(count)"
}


func part2( input: AOCinput ) -> String {
    let diagonals = [ Direction8.NW, Direction8.NE ]
    let goal = Set( "MAS" )
    let wordSearch = WordSearch( lines: input.lines )
    let count = wordSearch.findAll( target: "A" ).reduce( 0 ) { sum, nextA in
        let success = diagonals.filter {
            let start = nextA + $0.opposite.vector
            let substr = wordSearch.substr( start: start, direction: $0, length: 3 )
            let candidate = Set( substr )
            return candidate == goal
        }.count == 2
        return sum + ( success ? 1 : 0 )
    }
    
    return "\(count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
