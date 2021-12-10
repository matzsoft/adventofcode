//
//         FILE: main.swift
//  DESCRIPTION: day09 - Smoke Basin
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/08/21 21:05:39
//

import Foundation

func isLowPoint( map: [[Int]], row: Int, col: Int ) -> Bool {
//    print( "\(row), \(col)" )
    guard map[row][col] < map[row-1][col] else { return false }
    guard map[row][col] < map[row+1][col] else { return false }
    guard map[row][col] < map[row][col-1] else { return false }
    guard map[row][col] < map[row][col+1] else { return false }

    return true
}


func parse( input: AOCinput ) -> [[Int]] {
    let map = input.lines.map { $0.map { Int( String( $0 ) )! } }
    return
        [ Array( repeating: 9, count: map[0].count + 2 ) ] +
        map.map { [ 9 ] + $0 + [ 9 ] } +
        [ Array( repeating: 9, count: map[0].count + 2 ) ]
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    var sum = 0
    
    for row in 1 ..< map.count - 1 {
        for col in 1 ..< map[row].count - 1 {
            if isLowPoint( map: map, row: row, col: col ) {
                sum += map[row][col] + 1
            }
        }
    }

    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    var basins = Array( repeating: Array( repeating: Int?( nil ), count: map[0].count ), count: map.count )
    var basinNumber = 0
    
    for row in map.indices {
        for col in map[row].indices {
            guard map[row][col] != 9 else { continue }
            guard basins[row][col] == nil else { continue }

            var queue = [ Point2D( x: col, y: row ) ]
            
            basinNumber += 1
            while !queue.isEmpty {
                let position = queue.removeFirst()
                
                basins[position.y][position.x] = basinNumber
                for direction in DirectionUDLR.allCases {
                    let neighbor = position + direction.vector
                    
                    guard map[neighbor.y][neighbor.x] != 9 else { continue }
                    guard basins[neighbor.y][neighbor.x] == nil else { continue }
                    queue.append( neighbor )
                }
            }
        }
    }
    
    let histogram = basins.flatMap { $0 }.compactMap { $0 }.reduce( into: [ Int : Int ]() ) {
        $0[ $1, default: 0 ] += 1
    }.sorted( by: { $0.value > $1.value } )
    let big3 = histogram[0].value * histogram[1].value * histogram[2].value
    return "\(big3)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
