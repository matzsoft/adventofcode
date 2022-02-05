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

struct Map {
    let map: [[Int]]
    
    subscript( position: Point2D ) -> Int { return map[position.y][position.x] }
    
    var points: [Point2D] {
        ( 1 ..< map.count - 1 ).map {
            row in ( 1 ..< map[0].count - 1 ).map { col in Point2D(x: col, y: row) }
        }.flatMap { $0 }
    }
    
    init( lines: [String] ) {
        let map = lines.map { $0.map { Int( String( $0 ) )! } }
        
        self.map =
            [ Array( repeating: 9, count: map[0].count + 2 ) ] +
            map.map { [ 9 ] + $0 + [ 9 ] } +
            [ Array( repeating: 9, count: map[0].count + 2 ) ]
    }

    func isLowPoint( position: Point2D ) -> Bool {
        return DirectionUDLR.allCases.allSatisfy {
            let neighbor = position + $0.vector
            return self[position] < self[neighbor]
        }
    }
    
    // returns [ ( key: basinID, value: basinSize ) ] sorted by decreasing basinSize
    var basins: [ Dictionary<Int, Int>.Element ] {
        var basins = Array( repeating: Array( repeating: Int?( nil ),
                                              count: map[0].count ), count: map.count )
        var basinNumber = 0
        
        for position in points {
            guard self[position] != 9 else { continue }
            guard basins[position.y][position.x] == nil else { continue }
            
            var queue = [ position ]
            
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
        
        return basins.flatMap { $0 }.compactMap { $0 }.reduce( into: [ Int : Int ]() ) {
            $0[ $1, default: 0 ] += 1
        }.sorted( by: { $0.value > $1.value } )
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    let sum = map.points.reduce( 0 ) { $0 + ( map.isLowPoint( position: $1 ) ? map[$1] + 1 : 0 ) }

    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let basins = map.basins
    let big3 = ( 0 ..< 3 ).reduce( 1, { $0 * basins[$1].value } )
    return "\(big3)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
