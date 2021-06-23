//
//         FILE: main.swift
//  DESCRIPTION: day13 - A Maze of Twisty Little Cubicles
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/03/21 19:23:47
//

import Foundation

enum Type: Int { case open, wall }

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
        
        type = Type( rawValue: parity )!
        distance = Int.max
    }
}

class Floor {
    var map: [[Cubicle]] = []
    
    init( width: Int, height: Int, favorite: Int ) {
        for y in 0 ..< height {
            var row: [Cubicle] = []
            
            for x in 0 ..< width {
                row.append( Cubicle( x: x, y: y, favorite: favorite ) )
            }
            map.append(row)
        }
    }
    
    subscript( point: Point2D ) -> Cubicle? {
        guard point.x >= 0 && point.y >= 0 else { return nil }
        guard point.x < map[0].count && point.y < map.count else { return nil }
        
        return map[point.y][point.x]
    }
    
    func possibleMoves( point: Point2D ) -> [Point2D] {
        var results: [Point2D] = []
        
        for direction in Direction4.allCases {
            let nextPos = point.move( direction: direction )
            
            if let next = self[ nextPos ] {
                if next.type == .open {
                    results.append( nextPos )
                }
            }
        }
        
        return results
    }
    
    func findDistance( start: Point2D, end: Point2D ) -> Int? {
        var queue: [Point2D] = []
        
        map.forEach { $0.forEach { $0.distance = Int.max } }
        if let begin = self[start] {
            begin.distance = 0
        }
        queue.append(start)
        
        while let next = queue.first {
            let possibles = possibleMoves( point: next )
            
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
                            queue.append( possible )
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func find( inRange: Int, start: Point2D ) -> Int {
        var queue: [Point2D] = []
        
        map.forEach { $0.forEach { $0.distance = Int.max } }
        if let begin = self[start] {
            begin.distance = 0
        }
        queue.append( start )
        
        while let next = queue.first {
            let possibles = possibleMoves( point: next )
            
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
                            queue.append( possible )
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


func parse( input: AOCinput ) -> Int {
    return Int( input.line )!
}


let startPoint = Point2D( x: 1, y: 1 )

func part1( input: AOCinput ) -> String {
    let favorite = parse( input: input )
    let floor = Floor( width: 70, height: 70, favorite: favorite )
    
    return "\(floor.findDistance( start: startPoint, end: Point2D( x: 31, y: 39 ) )!)"
}


func part2( input: AOCinput ) -> String {
    let favorite = parse( input: input )
    let floor = Floor( width: 70, height: 70, favorite: favorite )
    
    return "\(floor.find( inRange: 50, start: startPoint ))"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
