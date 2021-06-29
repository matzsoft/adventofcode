//
//  Coordinates.swift
//  day01
//
//  Created by Mark Johnson on 3/23/21.
//

import Foundation

protocol Direction2D { var vector: Point2D { get } }

enum Turn: String { case left = "L", right = "R", straight = "S", back = "B" }

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
        switch direction {
        case .straight:
            return self
        case .left:
            switch self {
            case .north:
                return .west
            case .east:
                return .north
            case .south:
                return .east
            case .west:
                return .south
            }
        case .right:
            switch self {
            case .north:
                return .east
            case .east:
                return .south
            case .south:
                return .west
            case .west:
                return .north
            }
        case .back:
            switch self {
            case .north:
                return .south
            case .east:
                return .west
            case .south:
                return .north
            case .west:
                return .east
            }
        }
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
    
    static func fromArrows( char: String ) -> DirectionUDLR? {
        switch char {
        case "^":
            return .up
        case "v":
            return .down
        case "<":
            return .left
        case ">":
            return .right
        default:
            return nil
        }
    }
    
    var toArrow: String {
        switch self {
        case .up:
            return "^"
        case .down:
            return "v"
        case .left:
            return "<"
        case .right:
            return ">"
        }
    }
    
    func turn( _ turn: Turn ) -> DirectionUDLR {
        switch turn {
        case .straight:
            return self
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
    
    static func *( left: Int, right: Point2D ) -> Point2D {
        return Point2D( x: left * right.x, y: left * right.y )
    }
    
    static func ==( left: Point2D, right: Point2D ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    var magnitude: Int {
        return abs( x ) + abs( y )
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
        self.min    = Point2D( x: Swift.min( min.x, max.x ), y: Swift.min( min.y, max.y ) )
        self.max    = Point2D( x: Swift.max( min.x, max.x ), y: Swift.max( min.y, max.y ) )
        self.width  = self.max.x - self.min.x + 1
        self.height = self.max.y - self.min.y + 1
        self.area   = width * height
    }

    init?( min: Point2D, width: Int, height: Int ) {
        guard width > 0 && height > 0 else { return nil }
        
        self.min    = min
        self.max    = Point2D( x: min.x + width - 1, y: min.y + height - 1 )
        self.width  = width
        self.height = height
        self.area   = width * height
    }
    
    init( points: [Point2D] ) {
        var bounds = Rect2D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    func expand( with point: Point2D ) -> Rect2D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }

    func pad( byMinX: Int = 0, byMaxX: Int = 0, byMinY: Int = 0, byMaxY: Int = 0 ) -> Rect2D {
        return Rect2D( min: Point2D( x: min.x - byMinX, y: min.y - byMinY ),
                       max: Point2D( x: max.x + byMaxX, y: max.y + byMaxY ) )
    }
    
    func pad( by: Int ) -> Rect2D {
        return pad( byMinX: by, byMaxX: by, byMinY: by, byMaxY: by )
    }
    
    func contains( point: Point2D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }

        return true
    }
    
    func intersection( with other: Rect2D ) -> Rect2D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        
        return Rect2D( min: Point2D( x: minX, y: minY ), width: maxX - minX + 1, height: maxY - minY + 1 )
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
    
    static func -( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z )
    }
    
    static func ==( left: Point3D, right: Point3D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
    
    var magnitude: Int {
        return abs( x ) + abs( y ) + abs( z )
    }
}

struct Rect3D: Hashable {
    let min:    Point3D
    let max:    Point3D
    let width:  Int
    let length: Int
    let height: Int
    let volume: Int
    
    init( min: Point3D, max: Point3D ) {
        self.min = Point3D(
            x: Swift.min( min.x, max.x ), y: Swift.min( min.y, max.y ), z: Swift.min( min.z, max.z ) )
        self.max = Point3D(
            x: Swift.max( min.x, max.x ), y: Swift.max( min.y, max.y ), z: Swift.max( min.z, max.z ) )
        self.width  = self.max.x - self.min.x + 1
        self.length = self.max.y - self.min.y + 1
        self.height = self.max.z - self.min.z + 1
        
        if width.multipliedReportingOverflow( by: length ).overflow {
            volume = Int.max
        } else if ( width * length ).multipliedReportingOverflow( by: height ).overflow {
            volume = Int.max
        } else {
            volume = width * length * height
        }
    }

    init?( min: Point3D, width: Int, length: Int, height: Int ) {
        guard width > 0 && length > 0 && height > 0 else { return nil }
        
        self.min    = min
        self.max    = Point3D( x: min.x + width - 1, y: min.y + length - 1, z: min.z + height - 1 )
        self.width  = width
        self.length = length
        self.height = height
        
        if width.multipliedReportingOverflow( by: length ).overflow {
            volume = Int.max
        } else if ( width * length ).multipliedReportingOverflow( by: height ).overflow {
            volume = Int.max
        } else {
            volume = width * length * height
        }
    }
    
    init( points: [Point3D] ) {
        var bounds = Rect3D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    init( rects: [Rect3D] ) {
        var bounds = Rect3D( min: rects[0].min, max: rects[0].max )
        
        rects[1...].forEach {
            bounds = bounds.expand( with: $0.min )
            bounds = bounds.expand( with: $0.max )
        }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    func expand( with point: Point3D ) -> Rect3D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )
        let minZ = Swift.min( min.z, point.z )
        let maxZ = Swift.max( max.z, point.z )

        return Rect3D( min: Point3D( x: minX, y: minY, z: minZ ), max: Point3D( x: maxX, y: maxY, z: maxZ ) )
    }
    
    func pad(
        byMinX: Int = 0, byMaxX: Int = 0,
        byMinY: Int = 0, byMaxY: Int = 0,
        byMinZ: Int = 0, byMaxZ: Int = 0
    ) -> Rect3D {
        return Rect3D( min: Point3D( x: min.x - byMinX, y: min.y - byMinY, z: min.z - byMinZ ),
                       max: Point3D( x: max.x + byMaxX, y: max.y + byMaxY, z: max.z + byMaxZ ) )
    }
    
    func pad( by: Int ) -> Rect3D {
        return pad( byMinX: by, byMaxX: by, byMinY: by, byMaxY: by, byMinZ: by, byMaxZ: by )
    }
    
    func contains( point: Point3D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }
        guard min.z <= point.z, point.z <= max.z else { return false }

        return true
    }
    
    func intersection( with other: Rect3D ) -> Rect3D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let minZ = Swift.min( min.z, other.min.z )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        let maxZ = Swift.max( max.z, other.max.z )

        return Rect3D(
            min: Point3D( x: minX, y: minY, z: minZ ),
            width: maxX - minX, length: maxY - minY, height: maxZ - minZ
        )
    }
}

struct Point4D: Hashable {
    let x: Int
    let y: Int
    let z: Int
    let t: Int

    func distance( other: Point4D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z ) + abs( t - other.t )
    }
    
    static func +( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z, t: left.t + right.t )
    }
    
    static func -( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z, t: left.t - right.t )
    }
    
    static func ==( left: Point4D, right: Point4D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z && left.t == right.t
    }
    
    var magnitude: Int {
        return abs( x ) + abs( y ) + abs( z ) + abs( t )
    }
}

struct Rect4D: Hashable {
    let min:      Point4D
    let max:      Point4D
    let width:    Int
    let length:   Int
    let height:   Int
    let duration: Int
    let volume:   Int
    
    init( min: Point4D, max: Point4D ) {
        self.min = Point4D(
            x: Swift.min( min.x, max.x ),
            y: Swift.min( min.y, max.y ),
            z: Swift.min( min.z, max.z ),
            t: Swift.min( min.t, max.t )
        )
        self.max = Point4D(
            x: Swift.max( min.x, max.x ),
            y: Swift.max( min.y, max.y ),
            z: Swift.max( min.z, max.z ),
            t: Swift.max( min.t, max.t )
        )
        self.width    = self.max.x - self.min.x + 1
        self.length   = self.max.y - self.min.y + 1
        self.height   = self.max.z - self.min.z + 1
        self.duration = self.max.t - self.min.t + 1
        
        if width.multipliedReportingOverflow( by: length ).overflow {
            volume = Int.max
        } else if ( width * length ).multipliedReportingOverflow( by: height ).overflow {
            volume = Int.max
        } else if ( width * length * height ).multipliedReportingOverflow( by: duration ).overflow {
            volume = Int.max
        } else {
            volume = width * length * height * duration
        }
    }

    init?( min: Point4D, width: Int, length: Int, height: Int, duration: Int ) {
        guard width > 0 && length > 0 && height > 0 else { return nil }
        
        self.min      = min
        self.max      = Point4D( x: min.x + width - 1,
                               y: min.y + length - 1,
                               z: min.z + height - 1,
                               t: min.t + duration - 1
        )
        self.width    = width
        self.length   = length
        self.height   = height
        self.duration = duration
        
        if width.multipliedReportingOverflow( by: length ).overflow {
            volume = Int.max
        } else if ( width * length ).multipliedReportingOverflow( by: height ).overflow {
            volume = Int.max
        } else if ( width * length * height ).multipliedReportingOverflow( by: duration ).overflow {
            volume = Int.max
        } else {
            volume = width * length * height * duration
        }
    }
    
    init( points: [Point4D] ) {
        var bounds = Rect4D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    init( rects: [Rect4D] ) {
        var bounds = Rect4D( min: rects[0].min, max: rects[0].max )
        
        rects[1...].forEach {
            bounds = bounds.expand( with: $0.min )
            bounds = bounds.expand( with: $0.max )
        }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    func expand( with point: Point4D ) -> Rect4D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )
        let minZ = Swift.min( min.z, point.z )
        let maxZ = Swift.max( max.z, point.z )
        let minT = Swift.min( min.t, point.t )
        let maxT = Swift.max( max.t, point.t )

        return Rect4D(
            min: Point4D( x: minX, y: minY, z: minZ, t: minT ),
            max: Point4D( x: maxX, y: maxY, z: maxZ, t: maxT )
        )
    }
    
    func pad(
        byMinX: Int = 0, byMaxX: Int = 0,
        byMinY: Int = 0, byMaxY: Int = 0,
        byMinZ: Int = 0, byMaxZ: Int = 0,
        byMinT: Int = 0, byMaxT: Int = 0
    ) -> Rect4D {
        return Rect4D(
            min: Point4D( x: min.x - byMinX, y: min.y - byMinY, z: min.z - byMinZ, t: min.t - byMinT ),
            max: Point4D( x: max.x + byMaxX, y: max.y + byMaxY, z: max.z + byMaxZ, t: max.t + byMaxT )
        )
    }
    
    func pad( by: Int ) -> Rect4D {
        return pad(
            byMinX: by, byMaxX: by, byMinY: by, byMaxY: by, byMinZ: by, byMaxZ: by, byMinT: by, byMaxT: by
        )
    }
    
    func contains( point: Point4D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }
        guard min.z <= point.z, point.z <= max.z else { return false }
        guard min.t <= point.t, point.t <= max.t else { return false }

        return true
    }
    
    func intersection( with other: Rect4D ) -> Rect4D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let minZ = Swift.min( min.z, other.min.z )
        let minT = Swift.min( min.t, other.min.t )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        let maxZ = Swift.max( max.z, other.max.z )
        let maxT = Swift.max( max.t, other.max.t )

        return Rect4D(
            min: Point4D( x: minX, y: minY, z: minZ, t: minT ),
            width: maxX - minX, length: maxY - minY, height: maxZ - minZ, duration: maxT - minT
        )
    }
}
