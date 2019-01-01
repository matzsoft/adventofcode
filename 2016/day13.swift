//
//  main.swift
//  day13
//
//  Created by Mark Johnson on 12/31/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

enum Direction: CaseIterable {
    case north, east, south, west
}

enum Type: String {
    case open = ".", wall = "#"
}

struct Point {
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
        case .north:
            return self + Point(x: 0, y: -1)
        case .east:
            return self + Point(x: 1, y: 0)
        case .south:
            return self + Point(x: 0, y: 1)
        case .west:
            return self + Point(x: -1, y: 0)
        }
    }
}

class Cubicle {
    let type: Type
    var distance: Int
    
    init( x: Int, y: Int, favorite: Int ) {
        var value = x * x + 3 * x + 2 * x * y + y + y * y + favorite
        var parity = 0
        
        while value > 0 {
            parity ^= value & 1
            value >>= 1
        }
        
        if parity == 1 {
            type = .wall
        } else {
            type = .open
        }
        distance = Int.max
    }
}

class Floor {
    var map: [[Cubicle]] = []
    
    init( width: Int, height: Int, favorite: Int ) {
        for y in 0 ..< height {
            var row: [Cubicle] = []
            
            for x in 0 ..< width {
                row.append( Cubicle(x: x, y: y, favorite: favorite) )
            }
            map.append(row)
        }
    }
    
    subscript( point: Point ) -> Cubicle? {
        guard point.x >= 0 && point.y >= 0 else { return nil }
        guard point.x < map[0].count && point.y < map.count else { return nil }
        
        return map[point.y][point.x]
    }
    
    func possibleMoves( point: Point ) -> [Point] {
        var results: [Point] = []
        
        for direction in Direction.allCases {
            let nextPos = point.move(direction: direction)
            
            if let next = self[ nextPos ] {
                if next.type == .open {
                    results.append(nextPos)
                }
            }
        }
        
        return results
    }
    
    func findDistance( start: Point, end: Point ) -> Int? {
        var queue: [Point] = []
        
        map.forEach { $0.forEach { $0.distance = Int.max } }
        if let begin = self[start] {
            begin.distance = 0
        }
        queue.append(start)
        
        while let next = queue.first {
            let possibles = possibleMoves(point: next)
            
            queue.removeFirst()
            if let nextCube = self[next] {
                let newDistance = nextCube.distance + 1
                
                for possible in possibles {
                    if possible == end {
                        return newDistance
                    }
                    
                    if let cube = self[possible] {
                        if cube.distance == Int.max {
                            cube.distance = newDistance
                            queue.append(possible)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func find( inRange: Int, start: Point ) -> Int {
        var queue: [Point] = []
        
        map.forEach { $0.forEach { $0.distance = Int.max } }
        if let begin = self[start] {
            begin.distance = 0
        }
        queue.append(start)
        
        while let next = queue.first {
            let possibles = possibleMoves(point: next)
            
            queue.removeFirst()
            if let nextCube = self[next] {
                let newDistance = nextCube.distance + 1
                
                if newDistance > inRange {
                    break
                }
                
                for possible in possibles {
                    if let cube = self[possible] {
                        if cube.distance == Int.max {
                            cube.distance = newDistance
                            queue.append(possible)
                        }
                    }
                }
            }
        }
        
        //printMap()
        return map.flatMap { $0 }.filter { $0.distance < Int.max }.count
    }
    
    func printMap() -> Void {
        for row in map {
            var line = ""
            
            for cube in row {
                switch cube.type {
                case .wall:
                    line += "#"
                case .open:
                    if cube.distance == Int.max {
                        line += "."
                    } else if cube.distance < 10 {
                        line += String( cube.distance )
                    } else {
                        line += "?"
                    }
                }
            }
            print( line )
        }
    }
}



let startPoint = Point(x: 1, y: 1)

let test1Favorite = 10
let test1End = Point(x: 7, y: 4
)
let inputFavorite = 1364
let inputEnd = Point(x: 31, y: 39)


let floor = Floor(width: 70, height: 70, favorite: inputFavorite)

if let part1 = floor.findDistance( start: startPoint, end: inputEnd ) {
    print( "Part1:", part1 )
}

print( "Part2:", floor.find( inRange: 50, start: startPoint ) )
