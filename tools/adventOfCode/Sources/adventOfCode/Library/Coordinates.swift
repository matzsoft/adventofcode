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

enum Turn: Int { case right = 1, left = -1, back = 2 }

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
    
    func turn( _ turn: Turn ) -> DirectionUDLR {
        switch turn {
        case .left:
            switch self {
            case .up:
                return .left
            case .right:
                return .up
            case .down:
                return .right
            case .left:
                return .down
            }
        case .right:
            switch self {
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .up
            }
        case .back:
            switch self {
            case .up:
                return .down
            case .right:
                return .left
            case .down:
                return .up
            case .left:
                return .right
            }
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

/// Important Notice - this enum implements a coordinate system normally used in mathematics.
/// Positive Y is north and positive X is east.
enum Direction6: String, CaseIterable, Direction2D {
    case n, ne, se, s, sw, nw
    
    var vector: Point2D {
        switch self {
        case .n:
            return Point2D( x: 0, y: 2 )
        case .ne:
            return Point2D( x: 1, y: 1 )
        case .se:
            return Point2D( x: 1, y: -1 )
        case .s:
            return Point2D( x: 0, y: -2 )
        case .sw:
            return Point2D( x: -1, y: -1 )
        case .nw:
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
    
    func hexDistance( other: Point2D ) -> Int {
        let absX = abs( x - other.x )
        let absY = abs( y - other.y )

        return absY <= absX ? absX : ( absY - absX ) / 2 + absX
    }
    
    static func +( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x + right.x, y: left.y + right.y )
    }
    
    static func -( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x - right.x, y: left.y - right.y )
    }
    
    static func ==( left: Point2D, right: Point2D ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    func move( direction: Direction2D ) -> Point2D {
        return self + direction.vector
    }
}

struct Rect2D: Hashable {
    let min:    Point2D
    let max:    Point2D
    let width:  Int
    let height: Int
    let area:   Int
    
    init( min: Point2D, max: Point2D ) {
        self.min    = min
        self.max    = max
        self.width  = abs( max.x - min.x )
        self.height = abs( max.y - min.y )
        self.area   = width * height
    }

    init?( min: Point2D, width: Int, height: Int ) {
        guard width > 0 && height > 0 else { return nil }
        
        self.min    = min
        self.max    = Point2D( x: min.x + width, y: min.y + height )
        self.width  = width
        self.height = height
        self.area   = width * height
    }
    
    init( points: [Point2D] ) {
        var bounds = Rect2D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    func contains( point: Point2D ) -> Bool {
        guard min.x <= point.x, point.x <= max.y else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }

        return true
    }
    
    func expand( with point: Point2D ) -> Rect2D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }
    
    func intersection( with other: Rect2D ) -> Rect2D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        
        return Rect2D( min: Point2D( x: minX, y: minY ), width: maxX - minX, height: maxY - minY )
    }
}

struct Point3D: Hashable {
    let x: Int
    let y: Int
    let z: Int

    func distance( other: Point3D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z )
    }
    
    static func +( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z )
    }
    
    static func ==( left: Point3D, right: Point3D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
    
    func magnitude() -> Int {
        return abs(x) + abs(y) + abs(z)
    }
}

