//
//  Coordinates.swift
//  day01
//
//  Created by Mark Johnson on 3/23/21.
//

import Foundation

public protocol Direction2D { var vector: Point2D { get } }

public enum Turn: String, CaseIterable { case left = "L", right = "R", straight = "S", back = "B" }

/// Important Notice - this enum implements a coordinate system normally used in mathematics.
/// Positive Y is north and positive X is east.
public enum Direction4: Int, CaseIterable, Direction2D {
    case north, east, south, west
    
    public var vector: Point2D {
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
    
    static public func fromArrows( char: String ) -> Direction4? {
        switch char {
        case "^":
            return .north
        case "v":
            return .south
        case "<":
            return .west
        case ">":
            return .east
        default:
            return nil
        }
    }
    
    public func turn( direction: Turn ) -> Direction4 {
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
public enum DirectionUDLR: String, CaseIterable, Direction2D {
    case up = "U", down = "D", left = "L", right = "R"
    
    public var vector: Point2D {
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
    
    public func turn( _ turn: Turn ) -> DirectionUDLR {
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
public enum Direction8: String, CaseIterable, Direction2D {
    case N, NE, E, SE, S, SW, W, NW
    
    public var vector: Point2D {
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
public enum Direction6: String, CaseIterable, Direction2D {
    case n, ne, se, s, sw, nw
    
    public var vector: Point2D {
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


/// Important Notice - this enum implements a coordinate system normally used in mathematics.
/// Positive Y is north and positive X is east.
enum Direction6alt: String, CaseIterable, Direction2D {
    case e, se, sw, w, nw, ne

    var vector: Point2D {
        switch self {
        case .e:
            return Point2D( x: 2, y: 0 )
        case .se:
            return Point2D( x: 1, y: -1 )
        case .sw:
            return Point2D( x: -1, y: -1 )
        case .w:
            return Point2D( x: -2, y: 0 )
        case .nw:
            return Point2D( x: -1, y: 1 )
        case .ne:
            return Point2D( x: 1, y: 1 )
        }
    }
}


public struct Point2D: Hashable {
    public let x: Int
    public let y: Int
    
    public init( x: Int, y: Int ) {
        self.x = x
        self.y = y
    }
    
    public func distance( other: Point2D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    public func hexDistance( other: Point2D ) -> Int {
        let absX = abs( x - other.x )
        let absY = abs( y - other.y )

        return absY <= absX ? absX : ( absY - absX ) / 2 + absX
    }
    
    static public func +( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x + right.x, y: left.y + right.y )
    }
    
    static public func -( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x - right.x, y: left.y - right.y )
    }
    
    static func *( left: Int, right: Point2D ) -> Point2D {
        return Point2D( x: left * right.x, y: left * right.y )
    }
    
    static public func ==( left: Point2D, right: Point2D ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    public var magnitude: Int {
        return abs( x ) + abs( y )
    }

    public func move( direction: Direction2D ) -> Point2D {
        return self + direction.vector
    }
}

public struct Rect2D: Hashable, CustomStringConvertible {
    public let min:    Point2D
    public let max:    Point2D
    public let width:  Int
    public let height: Int
    let area:   Int
    
    public init( min: Point2D, max: Point2D ) {
        self.min    = Point2D( x: Swift.min( min.x, max.x ), y: Swift.min( min.y, max.y ) )
        self.max    = Point2D( x: Swift.max( min.x, max.x ), y: Swift.max( min.y, max.y ) )
        self.width  = self.max.x - self.min.x + 1
        self.height = self.max.y - self.min.y + 1
        self.area   = width * height
    }

    public init?( min: Point2D, width: Int, height: Int ) {
        guard width > 0 && height > 0 else { return nil }
        
        self.min    = min
        self.max    = Point2D( x: min.x + width - 1, y: min.y + height - 1 )
        self.width  = width
        self.height = height
        self.area   = width * height
    }
    
    public init( points: [Point2D] ) {
        var bounds = Rect2D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    var xRange: ClosedRange<Int> { min.x ... max.x }
    var yRange: ClosedRange<Int> { min.y ... max.y }
    public var description: String {
        "(\(min.x),\(min.y) \(width)x\(height))"
    }
    var points: [Point2D] {
         ( min.y ... max.y ).flatMap { y in ( min.x ... max.x ).map { x in Point2D( x: x, y: y ) } }
    }

    public func expand( with point: Point2D ) -> Rect2D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }

    func expand( with other: Rect2D ) -> Rect2D {
        let minX = Swift.min( min.x, other.min.x )
        let maxX = Swift.max( max.x, other.max.x )
        let minY = Swift.min( min.y, other.min.y )
        let maxY = Swift.max( max.y, other.max.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }

    func pad( byMinX: Int = 0, byMaxX: Int = 0, byMinY: Int = 0, byMaxY: Int = 0 ) -> Rect2D {
        return Rect2D( min: Point2D( x: min.x - byMinX, y: min.y - byMinY ),
                       max: Point2D( x: max.x + byMaxX, y: max.y + byMaxY ) )
    }
    
    func pad( by: Int ) -> Rect2D {
        return pad( byMinX: by, byMaxX: by, byMinY: by, byMaxY: by )
    }
    
    public func contains( point: Point2D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }

        return true
    }
    
    public func intersection( with other: Rect2D ) -> Rect2D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        
        return Rect2D( min: Point2D( x: minX, y: minY ), width: maxX - minX + 1, height: maxY - minY + 1 )
    }
}

public struct Point3D: Hashable, CustomStringConvertible {
    public let x: Int
    public let y: Int
    public let z: Int

    public init( x: Int, y: Int, z: Int ) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public var description: String { "(\(x),\(y),\(z))" }
    
    public func distance( other: Point3D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z )
    }
    
    public static func +( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z )
    }
    
    public static func -( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z )
    }
    
    static func *( left: Int, right: Point3D ) -> Point3D {
        return Point3D( x: left * right.x, y: left * right.y, z: left * right.z )
    }
    
    public static func ==( left: Point3D, right: Point3D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
    
    public var magnitude: Int {
        return abs( x ) + abs( y ) + abs( z )
    }
}

public struct Rect3D: Hashable {
    public let min:    Point3D
    public let max:    Point3D
    public let width:  Int
    public let length: Int
    public let height: Int
    public let volume: Int
    
    public init( min: Point3D, max: Point3D ) {
        self.min = Point3D(
            x: Swift.min( min.x, max.x ), y: Swift.min( min.y, max.y ), z: Swift.min( min.z, max.z ) )
        self.max = Point3D(
            x: Swift.max( min.x, max.x ), y: Swift.max( min.y, max.y ), z: Swift.max( min.z, max.z ) )

        func measurement( small: Int, big: Int ) -> Int {
            if big.subtractingReportingOverflow( small ).overflow {
                return Int.max
            } else if ( big - small ).addingReportingOverflow( 1 ).overflow {
                return Int.max
            } else {
                return big - small + 1
            }
        }

        self.width  = measurement( small: self.min.x, big: self.max.x )
        self.length = measurement( small: self.min.y, big: self.max.y )
        self.height = measurement( small: self.min.z, big: self.max.z )

        if width.multipliedReportingOverflow( by: length ).overflow {
            volume = Int.max
        } else if ( width * length ).multipliedReportingOverflow( by: height ).overflow {
            volume = Int.max
        } else {
            volume = width * length * height
        }
    }

    public init?( min: Point3D, width: Int, length: Int, height: Int ) {
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
    
    public init( rects: [Rect3D] ) {
        var bounds = Rect3D( min: rects[0].min, max: rects[0].max )
        
        rects[1...].forEach {
            bounds = bounds.expand( with: $0.min )
            bounds = bounds.expand( with: $0.max )
        }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    var points: [Point3D] {
         ( min.z ... max.z ).flatMap { z in
             ( min.y ... max.y ).flatMap { y in
                 ( min.x ... max.x ).map { x in Point3D( x: x, y: y, z: z ) } } }
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
        let minZ = Swift.max( min.z, other.min.z )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        let maxZ = Swift.min( max.z, other.max.z )

        return Rect3D(
            min: Point3D( x: minX, y: minY, z: minZ ),
            width: maxX - minX + 1, length: maxY - minY + 1, height: maxZ - minZ + 1
        )
    }
}

struct Matrix3D {
    static var identity: Matrix3D {
        let matrix = [
            [ 1, 0, 0, 0 ],
            [ 0, 1, 0, 0 ],
            [ 0, 0, 1, 0 ],
            [ 0, 0, 0, 1 ]
        ]
        return Matrix3D( matrix: matrix )
    }
    
    static func scale( by factors: Point3D ) -> Matrix3D {
        var matrix = identity.matrix
        matrix[0][0] = factors.x
        matrix[1][1] = factors.y
        matrix[2][2] = factors.z
        return Matrix3D( matrix: matrix )
    }
    
    static func rotate( aroundX by: Turn ) -> Matrix3D {
        var matrix = identity.matrix
        switch by {
        case .left:
            matrix[1][1] =  0        // cos(90)
            matrix[2][2] =  0        // cos(90)
            matrix[2][1] =  1        // sin(90)
            matrix[1][2] = -1        // -sin(90)
        case .right:
            matrix[1][1] =  0        // cos(270)
            matrix[2][2] =  0        // cos(270)
            matrix[2][1] = -1        // sin(270)
            matrix[1][2] =  1        // -sin(270)
        case .straight:
            break
        case .back:
            matrix[1][1] = -1        // cos(180)
            matrix[2][2] = -1        // cos(180)
            matrix[2][1] =  0        // sin(180)
            matrix[1][2] =  0        // -sin(180)
        }
        return Matrix3D( matrix: matrix )
    }
    
    static func rotate( aroundY by: Turn ) -> Matrix3D {
        var matrix = identity.matrix
        switch by {
        case .left:
            matrix[0][0] =  0        // cos(90)
            matrix[2][2] =  0        // cos(90)
            matrix[0][2] =  1        // sin(90)
            matrix[2][0] = -1        // -sin(90)
        case .right:
            matrix[0][0] =  0        // cos(270)
            matrix[2][2] =  0        // cos(270)
            matrix[0][2] = -1        // sin(270)
            matrix[2][0] =  1        // -sin(270)
        case .straight:
            break
        case .back:
            matrix[0][0] = -1        // cos(180)
            matrix[2][2] = -1        // cos(180)
            matrix[0][2] =  0        // sin(180)
            matrix[2][0] =  0        // -sin(180)
        }
        return Matrix3D( matrix: matrix )
    }
    
    static func rotate( aroundZ by: Turn ) -> Matrix3D {
        var matrix = identity.matrix
        switch by {
        case .left:
            matrix[0][0] =  0        // cos(90)
            matrix[1][1] =  0        // cos(90)
            matrix[1][0] =  1        // sin(90)
            matrix[0][1] = -1        // -sin(90)
        case .right:
            matrix[0][0] =  0        // cos(270)
            matrix[1][1] =  0        // cos(270)
            matrix[1][0] = -1        // sin(270)
            matrix[0][1] =  1        // -sin(270)
        case .straight:
            break
        case .back:
            matrix[0][0] = -1        // cos(180)
            matrix[1][1] = -1        // cos(180)
            matrix[1][0] =  0        // sin(180)
            matrix[0][1] =  0        // -sin(180)
        }
        return Matrix3D( matrix: matrix )
    }
    
    static func rotate( aroundX byX: Turn, aroundY byY: Turn, aroundZ byZ: Turn ) -> Matrix3D {
        rotate( aroundX: byX ).multiply( by: rotate( aroundY: byY ) ).multiply( by: rotate(aroundZ: byZ ) )
    }
    
    let matrix: [[Int]]
    
    init( matrix: [[Int]] ) {
        self.matrix = matrix
    }
    
    func multiply( by other: Matrix3D ) -> Matrix3D {
        let matrix = ( 0 ..< self.matrix.count ).map { row in
            ( 0 ..< other.matrix[0].count ).map { col in
                ( 0 ..< self.matrix[0].count ).reduce( 0 ) { $0 + self.matrix[row][$1] * other.matrix[$1][col] }
            }
        }
//        let matrix = [
//            [
//                matrix[0][0] * other.matrix[0][0] + matrix[0][1] * other.matrix[1][0] + matrix[0][2] * other.matrix[2][0] + matrix[0][3] * other.matrix[3][0],
//                matrix[0][0] * other.matrix[0][1] + matrix[0][1] * other.matrix[1][1] + matrix[0][2] * other.matrix[2][1] + matrix[0][3] * other.matrix[3][1],
//                matrix[0][0] * other.matrix[0][2] + matrix[0][1] * other.matrix[1][2] + matrix[0][2] * other.matrix[2][2] + matrix[0][3] * other.matrix[3][2],
//                matrix[0][0] * other.matrix[0][3] + matrix[0][1] * other.matrix[1][3] + matrix[0][2] * other.matrix[2][3] + matrix[0][3] * other.matrix[3][3],
//            ],
//            [
//                matrix[1][0] * other.matrix[0][0] + matrix[1][1] * other.matrix[1][0] + matrix[1][2] * other.matrix[2][0] + matrix[1][3] * other.matrix[3][0],
//                matrix[1][0] * other.matrix[0][1] + matrix[1][1] * other.matrix[1][1] + matrix[1][2] * other.matrix[2][1] + matrix[1][3] * other.matrix[3][1],
//                matrix[1][0] * other.matrix[0][2] + matrix[1][1] * other.matrix[1][2] + matrix[1][2] * other.matrix[2][2] + matrix[0][3] * other.matrix[3][2],
//                matrix[0][0] * other.matrix[0][3] + matrix[0][1] * other.matrix[1][3] + matrix[0][2] * other.matrix[2][3] + matrix[1][3] * other.matrix[3][3],
//            ],
//            [
//                matrix[2][0] * other.matrix[0][0] + matrix[2][1] * other.matrix[1][0] + matrix[2][2] * other.matrix[2][0] + matrix[2][3] * other.matrix[3][0],
//                matrix[2][0] * other.matrix[0][1] + matrix[2][1] * other.matrix[1][1] + matrix[2][2] * other.matrix[2][1] + matrix[2][3] * other.matrix[3][1],
//                matrix[2][0] * other.matrix[0][2] + matrix[2][1] * other.matrix[1][2] + matrix[2][2] * other.matrix[2][2] + matrix[2][3] * other.matrix[3][2],
//                matrix[2][0] * other.matrix[0][3] + matrix[2][1] * other.matrix[1][3] + matrix[2][2] * other.matrix[2][3] + matrix[2][3] * other.matrix[3][3],
//            ],
//            [
//                matrix[3][0] * other.matrix[0][0] + matrix[3][1] * other.matrix[1][0] + matrix[3][2] * other.matrix[2][0] + matrix[3][3] * other.matrix[3][0],
//                matrix[3][0] * other.matrix[0][1] + matrix[3][1] * other.matrix[1][1] + matrix[3][2] * other.matrix[2][1] + matrix[3][3] * other.matrix[3][1],
//                matrix[3][0] * other.matrix[0][2] + matrix[3][1] * other.matrix[1][2] + matrix[3][2] * other.matrix[2][2] + matrix[3][3] * other.matrix[3][2],
//                matrix[3][0] * other.matrix[0][3] + matrix[3][1] * other.matrix[1][3] + matrix[3][2] * other.matrix[2][3] + matrix[3][3] * other.matrix[3][3],
//            ]
//        ]
        return Matrix3D( matrix: matrix )
    }
    
    func transform( point: Point3D ) -> Point3D {
        let newX = point.x * matrix[0][0] + point.y * matrix[1][0] + point.z * matrix[2][0] + matrix[3][0]
        let newY = point.x * matrix[0][1] + point.y * matrix[1][1] + point.z * matrix[2][1] + matrix[3][1]
        let newZ = point.x * matrix[0][2] + point.y * matrix[1][2] + point.z * matrix[2][2] + matrix[3][2]
        return Point3D( x: newX, y: newY, z: newZ )
    }
    
    func add( translation: Point3D ) -> Matrix3D {
        var matrix = self.matrix
        matrix[3][0] += translation.x
        matrix[3][1] += translation.y
        matrix[3][2] += translation.z
        return Matrix3D( matrix: matrix )
    }
}

public struct Point4D: Hashable {
    let x: Int
    let y: Int
    let z: Int
    let t: Int

    public init(x: Int, y: Int, z: Int, t: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
    
    public func distance( other: Point4D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z ) + abs( t - other.t )
    }
    
    static func +( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z, t: left.t + right.t )
    }
    
    static func -( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z, t: left.t - right.t )
    }
    
    public static func ==( left: Point4D, right: Point4D ) -> Bool {
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
        let minZ = Swift.max( min.z, other.min.z )
        let minT = Swift.max( min.t, other.min.t )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        let maxZ = Swift.min( max.z, other.max.z )
        let maxT = Swift.min( max.t, other.max.t )

        return Rect4D(
            min: Point4D( x: minX, y: minY, z: minZ, t: minT ),
            width: maxX - minX + 1, length: maxY - minY + 1,
            height: maxZ - minZ + 1, duration: maxT - minT + 1
        )
    }
}
