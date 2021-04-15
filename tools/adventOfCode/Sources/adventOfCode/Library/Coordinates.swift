//
//  Coordinates.swift
//  day01
//
//  Created by Mark Johnson on 3/23/21.
//

import Foundation

protocol Direction2D {
    var vector: Point2D { get }
}

enum Turn: Int { case right = 1, left = -1 }

/// Important Notice - this enum implements a coordinate system normally used in mathematics.
/// Positive Y is north and positive X is east.
enum Direction4: Int, CaseIterable, Direction2D {
    case north, east, south, west
    
    var vector: Point2D {
        switch self {
        case .north:
            return Point2D( x: 0, y: 1 )
        case .east:
            return Point2D( x: 1, y: 0 )
        case .south:
            return Point2D( x: 0, y: -1 )
        case .west:
            return Point2D( x: -1, y: 0 )
        }
    }
    
    func turn( direction: Turn ) -> Direction4 {
        let newValue = self.rawValue + direction.rawValue + Direction4.allCases.count
        return Direction4( rawValue: newValue % Direction4.allCases.count )!
    }
}

/// Important Notice - this enum implements a coordinate system normally used in computer images.
/// Positive Y is down and positive X is east.
enum DirectionUDLR: String, CaseIterable, Direction2D {
    case up = "U", down = "D", left = "L", right = "R"
    
    var vector: Point2D {
        switch self {
        case .up:
            return Point2D( x: 0, y: -1 )
        case .right:
            return Point2D( x: 1, y: 0 )
        case .down:
            return Point2D( x: 0, y: 1 )
        case .left:
            return Point2D( x: -1, y: 0 )
        }
    }
}

/// Important Notice - this enum implements a coordinate system normally used in mathematics.
/// Positive Y is north and positive X is east.
enum Direction8: String, CaseIterable, Direction2D {
    case N, NE, E, SE, S, SW, W, NW
    
    var vector: Point2D {
        switch self {
        case .N:
            return Point2D( x: 0, y: 1 )
        case .NE:
            return Point2D( x: 1, y: 1 )
        case .E:
            return Point2D( x: 1, y: 0 )
        case .SE:
            return Point2D( x: 1, y: -1 )
        case .S:
            return Point2D( x: 0, y: -1 )
        case .SW:
            return Point2D( x: -1, y: -1 )
        case .W:
            return Point2D( x: -1, y: 0 )
        case .NW:
            return Point2D( x: -1, y: 1 )
        }
    }
}

struct Point2D: Hashable {
    let x: Int
    let y: Int
    
    func distance( other: Point2D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    static func +( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x + right.x, y: left.y + right.y )
    }
    
    static func ==( left: Point2D, right: Point2D ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    func move( direction: Direction2D ) -> Point2D {
        return self + direction.vector
    }
}

struct Rect2D {
    let min: Point2D
    let max: Point2D
    
    func contains( point: Point2D ) -> Bool {
        guard min.x <= point.x, point.x <= max.y else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }

        return true
    }
}
