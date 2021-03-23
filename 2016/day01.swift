//
//         FILE: main.swift
//  DESCRIPTION: day01 -
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/23/21 12:54:23
//

import Foundation


enum Turn: Int { case right = 1, left = -1 }
enum Direction: Int, CaseIterable {
    case north, east, south, west
    
    var vector: Point {
        switch self {
        case .north:
            return Point( x: 0, y: 1 )
        case .east:
            return Point( x: 1, y: 0 )
        case .south:
            return Point( x: 0, y: -1 )
        case .west:
            return Point( x: -1, y: 0 )
        }
    }
    
    func turn( direction: Turn ) -> Direction {
        let newValue = self.rawValue + direction.rawValue + Direction.allCases.count
        return Direction( rawValue: newValue % Direction.allCases.count )!
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

func +(lhs: Point, rhs: Point) -> Point {
    return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
}

struct Step {
    let turn: Turn
    let distance: Int
    
    init( value: Substring ) {
        turn = value.first! == "R" ? Turn.right : Turn.left
        distance = Int( value.dropFirst() )!
    }
}


func parse( input: AOCinput ) -> [Point] {
    let steps = input.line.split() { ", ".contains( $0 ) }.map { Step( value: $0 ) }
    var path = [ Point( x: 0, y: 0 ) ]
    var direction = Direction.north
    
    for step in steps {
        direction = direction.turn( direction: step.turn )
        for _ in ( 0 ..< step.distance ) {
            path.append( path.last! + direction.vector )
        }
    }
    return path
}


func part1( input: AOCinput ) -> String {
    let path = parse( input: input )
    return "\(abs(path.last!.x) + abs(path.last!.y))"
}


func part2( input: AOCinput ) -> String {
    let path = parse( input: input )
    var seen = Set<Point>()
    
    for point in path {
        if seen.contains( point ) {
            return "\(abs(point.x) + abs(point.y))"
        }
        seen.insert( point )
    }
    return ""
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
