//
//  main.swift
//  day14
//
//  Created by Mark Johnson on 1/14/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = "nbysizxe"

enum Direction: String, CaseIterable {
    case up = "U", down = "D", left = "L", right = "R"
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    static func +( left: Point, right: Point ) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func ==( left: Point, right: Point ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    func move( direction: Direction ) -> Point {
        switch direction {
        case .up:
            return self + Point(x: 0, y: -1)
        case .right:
            return self + Point(x: 1, y: 0)
        case .down:
            return self + Point(x: 0, y: 1)
        case .left:
            return self + Point(x: -1, y: 0)
        }
    }
}

class KnotHash {
    static let extraLengths = [ 17, 31, 73, 47, 23 ]
    
    var list: [Int]
    let lengths: [Int]
    var current: Int
    var skip: Int
    
    init( input: String ) {
        list = ( 0 ... 255 ).map { $0 }
        lengths = input.map { Int( $0.unicodeScalars.first!.value ) } + KnotHash.extraLengths
        current = 0
        skip = 0
    }
    
    func oneRound() -> Void {
        for length in lengths {
            if current + length  < list.count {
                let reversed = Array( list[ current ..< ( current + length) ].reversed() )
                
                list.replaceSubrange( current ..< ( current + length), with: reversed )
            } else {
                let working = list + list
                let reversed = Array( working[ current ..< ( current + length) ].reversed() )
                let part1 = Array( reversed[ ( list.count - current )...] )
                let part2 = Array( list[ ( ( current + length ) % list.count ) ..< current ] )
                let part3 = Array( reversed[ 0 ..< ( list.count - current ) ] )
                
                list = part1 + part2 + part3
            }
            
            current = ( current + length + skip ) % list.count
            skip += 1
        }
    }
    
    func generate() -> String {
        guard list.count == 256 else { return "Wrong sized list" }
        var hash = ""
        
        for _ in 0 ..< 64 {
            oneRound()
        }
        
        for i in stride( from: 0, to: list.count, by: 16 ) {
            let element = list[ i ..< ( i + 16 ) ].reduce( 0, { $0 ^ $1 } )
            
            hash += String( format: "%02x", element )
        }
        
        return hash
    }
}

enum Status {
    case free, used
}

class Square {
    let point: Point
    let status: Status
    var region: Int
    
    init( point: Point, status: Status ) {
        self.point = point
        self.status = status
        region = Int.min
    }
}

class Grid {
    static let bitCounts: [ Character : Int ] = [
        "0" : 0, "1" : 1, "2" : 1, "3" : 2,
        "4" : 1, "5" : 2, "6" : 2, "7" : 3,
        "8" : 1, "9" : 2, "a" : 2, "b" : 3,
        "c" : 2, "d" : 3, "e" : 3, "f" : 4,
        ]
    static let bitMasks: [ Character : [Status] ] = [
        "0" : [ .free, .free, .free, .free ],
        "1" : [ .free, .free, .free, .used ],
        "2" : [ .free, .free, .used, .free ],
        "3" : [ .free, .free, .used, .used ],
        "4" : [ .free, .used, .free, .free ],
        "5" : [ .free, .used, .free, .used ],
        "6" : [ .free, .used, .used, .free ],
        "7" : [ .free, .used, .used, .used ],
        "8" : [ .used, .free, .free, .free ],
        "9" : [ .used, .free, .free, .used ],
        "a" : [ .used, .free, .used, .free ],
        "b" : [ .used, .free, .used, .used ],
        "c" : [ .used, .used, .free, .free ],
        "d" : [ .used, .used, .free, .used ],
        "e" : [ .used, .used, .used, .free ],
        "f" : [ .used, .used, .used, .used ],
        ]

    let grid: [[Square]]
    let usedCount: Int
    
    init( baseKey: String ) {
        var sum = 0
        var grid: [[Square]] = []
        
        for rowNum in 0 ..< 128 {
            let generator = KnotHash( input: "\(input)-\(rowNum)" )
            let hash = generator.generate()
            
            sum += Grid.countBits( hash: hash )
            grid.append( Grid.buildRow( y: grid.count, hash: hash ) )
        }
        
        self.grid = grid
        usedCount = sum
    }

    static func countBits( hash: String ) -> Int {
        var sum = 0
        
        for char in hash {
            if let count = bitCounts[char] {
                sum += count
            }
        }
        
        return sum
    }
    
    static func buildRow( y: Int, hash: String ) -> [Square] {
        var row: [Square] = []
        
        for char in hash {
            if let nibble = bitMasks[char] {
                row.append( contentsOf: nibble.enumerated().map {
                    Square( point: Point( x: row.count + $0.offset, y: y ), status: $0.element )
                } )
            }
        }
        
        return row
    }
    
    subscript( point: Point ) -> Square? {
        guard point.x >= 0 && point.y >= 0 else { return nil }
        guard point.x < grid[0].count && point.y < grid.count else { return nil }
        
        return grid[point.y][point.x]
    }
    
    func walk() -> Int {
        var nextRegion = 0
        
        for row in grid {
            for disk in row {
                if disk.status == .used && disk.region == Int.min {
                    var queue = [ disk ]
                    
                    while let next = queue.first {
                        queue.removeFirst()
                        next.region = nextRegion
                        for direction in Direction.allCases {
                            let nextPoint = next.point.move(direction: direction)
                            
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



var grid = Grid(baseKey: input)

print( "Part1:", grid.usedCount )
print( "Part2:", grid.walk() )
