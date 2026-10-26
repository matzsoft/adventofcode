//
//         FILE: main.swift
//  DESCRIPTION: day08 - Treetop Tree House
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/07/22 21:00:12
//

import Foundation
import Library


func parse( input: AOCinput ) -> [[Int]] {
    return input.lines.map {
        $0.map { Int( String( $0 ) )! }
    }
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    var counts = Array( repeating: Array( repeating: 0, count: map[0].count ), count: map.count )
    func visibleCheck( row: Int, col: Int, maximum: Int ) -> Int {
        guard maximum < map[row][col] else { return maximum }
        counts[row][col] += 1
        return map[row][col]
    }

    for row in 0 ..< map[0].count {
        var left = -1
        var right = -1
        for col in 0 ..< map.count {
            left = visibleCheck( row: row, col: col, maximum: left )
            right = visibleCheck( row: row, col: map.count - 1 - col, maximum: right )
        }
    }
    
    for col in 0 ..< map.count {
        var top = -1
        var bottom = -1
        for row in 0 ..< map[0].count {
            top = visibleCheck( row: row, col: col, maximum: top )
            bottom = visibleCheck( row: map[0].count - 1 - row, col: col, maximum: bottom )
        }
    }
    
    return "\( counts.flatMap { $0 }.filter { $0 > 0 }.count )"
}


func viewingDistance( index: Int, where predicate: (Int) -> Bool ) -> Int {
    guard let tree = ( 0 ..< index ).reversed().first( where: predicate ) else { return index }
    return index - tree
}


func viewingDistance( _ range: Range<Int>, where predicate: (Int) -> Bool ) -> Int {
    guard let tree = range.first( where: predicate ) else { return range.upperBound - range.lowerBound }
    return tree + 1 - range.lowerBound
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let scenicScores = (  0 ..< map.count ).map { row in
        ( 0 ..< map[row].count ).map { col in
            let upCount = viewingDistance( index: row ) { map[$0][col] >= map[row][col] }
            let downCount = viewingDistance( row + 1 ..< map.count ) { map[$0][col] >= map[row][col] }
            let leftCount = viewingDistance( index: col ) { map[row][$0] >= map[row][col] }
            let rightCount = viewingDistance( col + 1 ..< map[row].count ) { map[row][$0] >= map[row][col] }
            
            return upCount * downCount * leftCount * rightCount
        }
    }
    
    return "\( scenicScores.flatMap { $0 }.max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
