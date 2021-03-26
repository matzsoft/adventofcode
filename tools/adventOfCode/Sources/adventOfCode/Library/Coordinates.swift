//
//  Coordinates.swift
//  day01
//
//  Created by Mark Johnson on 3/23/21.
//

import Foundation

enum Turn: Int { case right = 1, left = -1 }
enum Direction4: Int, CaseIterable {
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

struct Point2D: Hashable {
    let x: Int
    let y: Int
}

func +(lhs: Point2D, rhs: Point2D) -> Point2D {
    return Point2D( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
}