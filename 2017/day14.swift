//
//         FILE: main.swift
//  DESCRIPTION: day14 - Disk Defragmentation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/19/21 19:45:25
//

import Foundation
import Library

class Square {
    enum Status: Int { case free, used }

    let status: Status
    let point:  Point2D
    var region: Int
    
    init( status: Status, point: Point2D ) {
        self.status = status
        self.point  = point
        region      = Int.min
    }
    
    static func array( from hex: String, y: Int ) throws -> [Square] {
        return try hex.enumerated().flatMap { ( hexchar ) -> [Square] in
            guard let binary = Int( String( hexchar.element ), radix: 16 ) else {
                throw RuntimeError( "Non hex character '\(hexchar.element)' in hash." )
            }
            return ( 0 ... 3 ).map { ( bitOffset ) -> Square in
                let status = Status( rawValue: ( binary >> ( 3 - bitOffset ) ) & 1 )!
                let x = 4 * hexchar.offset + bitOffset
                return Square( status: status, point: Point2D( x: x, y: y ) )
            }
        }
    }
}

class Grid {
    let grid: [[Square]]
    
    var usedCount: Int {
        return grid.reduce( 0 ) { $0 + $1.filter { $0.status == .used }.count }
    }
    
    init( baseKey: String ) {
        grid = ( 0 ..< 128 ).map { ( y ) in
            let generator = KnotHash( input: "\(baseKey)-\(y)" )
            return try! Square.array( from: generator.generate(), y: y )
        }
    }

    subscript( point: Point2D ) -> Square? {
        guard 0 <= point.x && point.x < grid[0].count else { return nil }
        guard 0 <= point.y && point.y < grid.count else { return nil }

        return grid[point.y][point.x]
    }

    var regionCount: Int {
        var nextRegion = 0
        
        for row in grid {
            for disk in row {
                if disk.status == .used && disk.region == Int.min {
                    var queue = [ disk ]
                    
                    while let next = queue.first {
                        queue.removeFirst()
                        next.region = nextRegion
                        for direction in DirectionUDLR.allCases {
                            let nextPoint = next.point.move( direction: direction )
                            
                            if let nextDisk = self[nextPoint] {
                                if nextDisk.status == .used && nextDisk.region == Int.min {
                                    queue.append( nextDisk )
                                }
                            }
                        }
                    }
                    nextRegion += 1
                }
            }
        }
        
        return nextRegion
    }
}


func parse( input: AOCinput ) -> Grid {
    return Grid( baseKey: input.line )
}


func part1( input: AOCinput ) -> String {
    let grid = parse( input: input )
    return "\(grid.usedCount)"
}


func part2( input: AOCinput ) -> String {
    let grid = parse( input: input )
    return "\(grid.regionCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
