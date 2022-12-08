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

    for row in 0 ..< map[0].count {
        var left = -1
        var right = -1
        for col in 0 ..< map.count {
            if left < map[row][col] {
                counts[row][col] += 1
                left = map[row][col]
            }
            if right < map[row][ map.count - 1 - col ] {
                counts[row][ map.count - 1 - col ] += 1
                right = map[row][ map.count - 1 - col ]
            }
        }
    }
    
    for col in 0 ..< map.count {
        var top = -1
        var bottom = -1
        for row in 0 ..< map[0].count {
            if top < map[row][col] {
                counts[row][col] += 1
                top = map[row][col]
            }
            if bottom < map[ map[0].count - 1 - row ][col] {
                counts[ map[0].count - 1 - row ][col] += 1
                bottom = map[ map[0].count - 1 - row ][col]
            }
        }
    }
    
    let dork = counts.flatMap { $0 }.filter { $0 > 0 }.count
    return "\(dork)"
}


func leftUp( index: Int, tree: Int? ) -> Int {
    guard tree != nil else { return index }
    return index - tree!
}


func rightDown( index: Int, limit: Int, tree: Int? ) -> Int {
    guard tree != nil else { return limit - 1 - index }
    return tree! - index
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    var counts = Array( repeating: Array( repeating: 0, count: map[0].count ), count: map.count )
    for row in 0 ..< map.count {
        for col in 0 ..< map[row].count {
            let up = ( 0 ..< row ).reversed().first( where: { map[$0][col] >= map[row][col] } )
            let upCount = leftUp( index: row, tree: up )
            
            let down = ( row + 1 ..< map.count ).first( where: { map[$0][col] >= map[row][col] } )
            let downCount = rightDown( index: row, limit: map.count, tree: down )
            
            let left = ( 0 ..< col ).reversed().first( where: { map[row][$0] >= map[row][col] } )
            let leftCount = leftUp( index: col, tree: left )
            
            let right = ( col + 1 ..< map[row].count ).first( where: { map[row][$0] >= map[row][col] } )
            let rightCount = rightDown( index: col, limit: map[row].count, tree: right )
            
            counts[row][col] = upCount * downCount * leftCount * rightCount
        }
    }
    
    let dork = counts.flatMap { $0 }.max()!
    return "\(dork)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
