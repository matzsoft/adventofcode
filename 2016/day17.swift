//
//  main.swift
//  day17
//
//  Created by Mark Johnson on 1/4/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

enum Direction: String, CaseIterable {
    case up = "U", down = "D", left = "L", right = "R"
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

struct Position {
    let point: Point
    let path: String
}


let tests = [
    ( in: "ihgpwlah", out: "DDRRRD", longest: 370 ),
    ( in: "kglvqrro", out: "DDUDRLRRUDRD", longest: 492 ),
    ( in: "ulqzkmiv", out: "DRURDRUDDLLDLUURRDULRLDUUDDDRR", longest: 830 ),
]

let xmin = 0
let xmax = 3
let ymin = 0
let ymax = 3
let start = Point(x: 0, y: 0)
let vault = Point(x: 3, y: 3)
let input = "qzthpkfp"



extension String {
    subscript( offset: Int ) -> Character {
        return self[ self.index( self.startIndex, offsetBy: offset ) ]
    }
}

func isValid( point: Point ) -> Bool {
    guard point.x >= xmin else { return false }
    guard point.x <= xmax else { return false }
    guard point.y >= ymin else { return false }
    guard point.y <= ymax else { return false }
    
    return true
}

func isOpen( hexChar: Character ) -> Bool {
    let value = Int( String( hexChar ), radix: 16 )!
    
    return value > 10
}

func isOpen( direction: Direction, hash: String ) -> Bool {
    switch direction {
    case .up:
        return isOpen(hexChar: hash[0])
    case .down:
        return isOpen(hexChar: hash[1])
    case .left:
        return isOpen(hexChar: hash[2])
    case .right:
        return isOpen(hexChar: hash[3])
    }
}

func possibleMoves( key: String, point: Point, path: String ) -> [Position] {
    let hash = "\(key)\(path)".utf8.md5.rawValue
    var results: [Position] = []
    
    for direction in Direction.allCases {
        let nextPos = point.move(direction: direction)
        
        if isValid( point: nextPos ) && isOpen( direction: direction, hash: hash ) {
            results.append( Position( point: nextPos, path: path + direction.rawValue ) )
        }
    }
    
    return results
}

func findDistance( key: String, start: Point, end: Point ) -> String? {
    var queue: [Position] = [ Position( point: start, path: "" ) ]
    
    while let next = queue.first {
        let possibles = possibleMoves(key: key, point: next.point, path: next.path)
        
        queue.removeFirst()
        for possible in possibles {
            if possible.point == end {
                return possible.path
            }
            
            queue.append(possible)
        }
    }
    
    return nil
}

func findLongest( key: String, start: Point, end: Point ) -> String? {
    var queue: [Position] = [ Position( point: start, path: "" ) ]
    var last: String?
    
    while let next = queue.first {
        let possibles = possibleMoves(key: key, point: next.point, path: next.path)
        
        queue.removeFirst()
        for possible in possibles {
            if possible.point == end {
                last = possible.path
            } else {
                queue.append(possible)
            }
        }
    }
    
    return last
}


for test in tests {
    if let result = findDistance(key: test.in, start: start, end: vault) {
        if result != test.out {
            print( "Wrong part1 for test:", test.in )
            exit(1)
        }
    } else {
        print( "No part1 for test:", test.in )
        exit(1)
    }
    
    if let result = findLongest(key: test.in, start: start, end: vault) {
        if result.count != test.longest {
            print( "Wrong part2 for test:", test.in )
            exit(1)
        }
    } else {
        print( "No part2 for test:", test.in )
        exit(1)
    }
}

if let part1 = findDistance( key: input, start: start, end: vault ) {
    print( "Part1:", part1 )
} else {
    print( "Part1: failed" )
}

if let part2 = findLongest(key: input, start: start, end: vault ) {
    print( "Part2:", part2.count )
} else {
    print( "Part2: failed" )
}
