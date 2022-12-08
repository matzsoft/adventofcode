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


func viewingDistance( index: Int, limit: Int, where predicate: (Int) -> Bool ) -> Int {
    guard let tree = ( index + 1 ..< limit ).first( where: predicate ) else { return limit - 1 - index }
    return tree - index
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    var counts = Array( repeating: Array( repeating: 0, count: map[0].count ), count: map.count )
    for row in 0 ..< map.count {
        for col in 0 ..< map[row].count {
            let upCount = viewingDistance( index: row, where: { map[$0][col] >= map[row][col] } )
            let downCount = viewingDistance(
                index: row, limit: map.count, where: { map[$0][col] >= map[row][col] } )
            
            let leftCount = viewingDistance( index: col, where: { map[row][$0] >= map[row][col] } )
            let rightCount = viewingDistance(
                index: col, limit: map[row].count, where: { map[row][$0] >= map[row][col] } )
            
            counts[row][col] = upCount * downCount * leftCount * rightCount
        }
    }
    
    return "\( counts.flatMap { $0 }.max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
