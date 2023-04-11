//
//  Coordinates.swift
//  day01
//
//  Created by Mark Johnson on 3/23/21.
//

import Foundation

/// All 2D direction types must supply a vector method.
public protocol Direction2D { var vector: Point2D { get } }

/// Defines a turn in 2D.
public enum Turn: String, CaseIterable { case left = "L", right = "R", straight = "S", back = "B" }

/// Implements a 2D direction based on the 4 major compass points.
///
/// The coordinate system implementd is one normally used in mathematics.
/// Positive Y is north and positive X is east.
public enum Direction4: Int, CaseIterable, Direction2D {
    case north, east, south, west
    
    /// Returns a vector that represents one step in the given direction.
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
    
    /// A Direction4 can also be represented by ASCII "arrows".
    /// - Parameter char: Can be "^", "v", "<", or ">".
    /// - Returns: The corresponding direction.
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
    
    /// Modifies a direction by one turn.
    /// - Parameter direction: The direction of the turn.
    /// - Returns: The direction after turning.
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

/// Implements a 2D direction based on up, down, left, and right.
///
/// The coordinate system implementd is one normally used in computer images.
/// Positive Y is down and positive X is right.
public enum DirectionUDLR: String, CaseIterable, Direction2D {
    case up = "U", down = "D", left = "L", right = "R"
    
    /// Returns a vector that represents one step in the given direction.
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
    
    /// A Direction4 can also be represented by ASCII "arrows".
    /// - Parameter char: Can be "^", "v", "<", or ">".
    /// - Returns: The corresponding direction.
    public static func fromArrows( char: String ) -> DirectionUDLR? {
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
    
    /// A Direction4 can also be represented by ASCII "arrows".
    ///
    /// Returns one of "^", "v", "<", or ">".
    public var toArrow: String {
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
    
    /// Modifies a direction by one turn.
    /// - Parameter direction: The direction of the turn.
    /// - Returns: The direction after turning.
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

/// Implements a 2D direction based on the 8 major compass points.
///
/// The coordinate system implementd is one normally used in mathematics.
/// Positive Y is north and positive X is east.
public enum Direction8: String, CaseIterable, Direction2D {
    case N, NE, E, SE, S, SW, W, NW
    
    /// Returns a vector that represents one step in the given direction.
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


/// Implements a 2D direction based used for hexagonal grids.
///
/// The directions are based on the 6 compass points: n, ne, se, s, sw, and nw.
///
/// The coordinate system implementd is one normally used in mathematics.
/// Positive Y is north and positive X is east.
public enum Direction6: String, CaseIterable, Direction2D {
    case n, ne, se, s, sw, nw
    
    /// Returns a vector that represents one step in the given direction.
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


/// Implements a 2D direction based used for hexagonal grids.
///
/// The directions are based on the 6 compass points: e, se, sw, w, nw, and ne.
///
/// The coordinate system implementd is one normally used in mathematics.
/// Positive Y is north and positive X is east.
public enum Direction6alt: String, CaseIterable, Direction2D {
    case e, se, sw, w, nw, ne

    /// Returns a vector that represents one step in the given direction.
    public var vector: Point2D {
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


/// Used to represent points and vectors in 2D.
public struct Point2D: Hashable {
    public let x: Int
    public let y: Int
    
    public init( x: Int, y: Int ) {
        self.x = x
        self.y = y
    }
    
    /// Returns the Manhattan distance between two points.
    public func distance( other: Point2D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    /// Returns the Manhattan (like) distance between two points on a hexagonal grid.
    public func hexDistance( other: Point2D ) -> Int {
        let absX = abs( x - other.x )
        let absY = abs( y - other.y )

        return absY <= absX ? absX : ( absY - absX ) / 2 + absX
    }
    
    /// Adds either 2 vectors or a point and a vector.
    ///
    /// Adding 2 vectors gives a new vector that is the same as following one vector then the other.
    /// Adding a vector to a point gives a new point representing a move from the first point to the new one.
    public static func +( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x + right.x, y: left.y + right.y )
    }
    
    /// Subtracts either one point from another or a vector from a point.
    ///
    /// Subtracting 2 points gives the vector that moves from the second point to the first.
    /// Subtracting a vector from a point gives a new point in the opposite direction of the vector.
    /// Subtracting 2 vectors is less common.  It yields a new vector.
    public static func -( left: Point2D, right: Point2D ) -> Point2D {
        return Point2D( x: left.x - right.x, y: left.y - right.y )
    }
    
    /// Increases the magnitude of a vector while maintaining its direction.
    public static func *( left: Int, right: Point2D ) -> Point2D {
        return Point2D( x: left * right.x, y: left * right.y )
    }
    
    /// Compares 2 points or 2 vectors.
    static public func ==( left: Point2D, right: Point2D ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    /// The Manhattan distance represented by a vector.
    public var magnitude: Int {
        return abs( x ) + abs( y )
    }

    /// Yields a new point that is one step away in the given direction.
    public func move( direction: Direction2D ) -> Point2D {
        return self + direction.vector
    }
}


/// Used to represent rectangles in 2D.
public struct Rect2D: Hashable, CustomStringConvertible {
    public let min:    Point2D
    public let max:    Point2D
    public let width:  Int
    public let height: Int
    public let area:   Int
    
    /// Contructs a Rect2D from two diagonally opposite corners.
    /// - Parameters:
    ///   - min: The point at one of the corners.
    ///   - max: The point at the opposite corner.
    public init( min: Point2D, max: Point2D ) {
        self.min    = Point2D( x: Swift.min( min.x, max.x ), y: Swift.min( min.y, max.y ) )
        self.max    = Point2D( x: Swift.max( min.x, max.x ), y: Swift.max( min.y, max.y ) )
        self.width  = self.max.x - self.min.x + 1
        self.height = self.max.y - self.min.y + 1
        self.area   = width * height
    }
    
    /// Construct a Rect2D from a point, width, and height.
    /// - Parameters:
    ///   - min: The minimum corner of the rectangle.
    ///   - width: The rectangle width, increasing x.
    ///   - height: The rectangle height, increasing y.
    public init?( min: Point2D, width: Int, height: Int ) {
        guard width > 0 && height > 0 else { return nil }
        
        self.min    = min
        self.max    = Point2D( x: min.x + width - 1, y: min.y + height - 1 )
        self.width  = width
        self.height = height
        self.area   = width * height
    }
    
    /// Construct a Rect2D from a list of Point2D.
    ///
    /// Makes the smallest rectangle that contains all the points in the list.
    /// - Parameter points: The list of points to include.
    public init( points: [Point2D] ) {
        var bounds = Rect2D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    /// The range of x values included in the Rect2D.
    public var xRange: ClosedRange<Int> { min.x ... max.x }
    /// The range of y values included in the Rect2D.
    public var yRange: ClosedRange<Int> { min.y ... max.y }
    /// A string that describes the rectangle using minimum corner, width, and height.
    public var description: String { "(\(min.x),\(min.y) \(width)x\(height))" }
    /// A list of all the points that lie within (and on the boundary) of the rectangle.
    public var points: [Point2D] {
         ( min.y ... max.y ).flatMap { y in ( min.x ... max.x ).map { x in Point2D( x: x, y: y ) } }
    }
    
    /// Creates a new rectangle completely containing this rectangle and a given point.
    /// - Parameter point: The point used to expand this rectangle.
    /// - Returns: The smallest rectangle containing all of the original rectangle and the new point.
    public func expand( with point: Point2D ) -> Rect2D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }
    
    /// Creates a new rectangle completely containing this rectangle and another one.
    /// - Parameter other: The other rectangle used to expand this one.
    /// - Returns: The smallest rectangle containg the original and the other.
    public func expand( with other: Rect2D ) -> Rect2D {
        let minX = Swift.min( min.x, other.min.x )
        let maxX = Swift.max( max.x, other.max.x )
        let minY = Swift.min( min.y, other.min.y )
        let maxY = Swift.max( max.y, other.max.y )

        return Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D( x: maxX, y: maxY ) )
    }
    
    /// Create a new rectangle based on this one with extra space in each of the 4 directions.
    /// - Parameters:
    ///   - byMinX: Padding amount in the negative x direction.
    ///   - byMaxX: Padding amount in the positive x direction.
    ///   - byMinY: Padding amount in the negative y direction.
    ///   - byMaxY: Padding amount in the positive y direction.
    /// - Returns: A new Rect2d same as the original except padded in the 4 given amounts.
    public func pad( byMinX: Int = 0, byMaxX: Int = 0, byMinY: Int = 0, byMaxY: Int = 0 ) -> Rect2D {
        return Rect2D( min: Point2D( x: min.x - byMinX, y: min.y - byMinY ),
                       max: Point2D( x: max.x + byMaxX, y: max.y + byMaxY ) )
    }
    
    /// Create a new rectangle based on this one with extra space in all of the 4 directions.
    /// - Parameter by: Padding amount to apply in all 4 directions.
    /// - Returns: A new Rect2d same as the original except padded the same in all 4 directions.
    public func pad( by: Int ) -> Rect2D {
        return pad( byMinX: by, byMaxX: by, byMinY: by, byMaxY: by )
    }
    
    /// Check if a point is contained in a rectangle.
    ///
    /// Points on the rectangle boundary are considered contained.
    /// - Parameter point: The point to check.
    /// - Returns: True or false.
    public func contains( point: Point2D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }

        return true
    }
    
    /// Constructs the rectangle that is the intersection of two rectangles.
    /// - Parameter other: The rectangle to intersect with this one.
    /// - Returns: The rectangle contained within both the others.  May be empty.
    public func intersection( with other: Rect2D ) -> Rect2D? {
        let minX = Swift.max( min.x, other.min.x )
        let minY = Swift.max( min.y, other.min.y )
        let maxX = Swift.min( max.x, other.max.x )
        let maxY = Swift.min( max.y, other.max.y )
        
        return Rect2D( min: Point2D( x: minX, y: minY ), width: maxX - minX + 1, height: maxY - minY + 1 )
    }
}

/// Used to represent points and vectors in 3D.
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
    
    /// Returns the Manhattan distance between two points.
    public func distance( other: Point3D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z )
    }
    
    /// Adds either 2 vectors or a point and a vector.
    ///
    /// Adding 2 vectors gives a new vector that is the same as following one vector then the other.
    /// Adding a vector to a point gives a new point representing a move from the first point to the new one.
    public static func +( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z )
    }
    
    /// Subtracts either one point from another or a vector from a point.
    ///
    /// Subtracting 2 points gives the vector that moves from the second point to the first.
    /// Subtracting a vector from a point gives a new point in the opposite direction of the vector.
    /// Subtracting 2 vectors is less common.  It yields a new vector.
    public static func -( left: Point3D, right: Point3D ) -> Point3D {
        return Point3D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z )
    }
    
    /// Increases the magnitude of a vector while maintaining its direction.
    public static func *( left: Int, right: Point3D ) -> Point3D {
        return Point3D( x: left * right.x, y: left * right.y, z: left * right.z )
    }
    
    /// Compares 2 points or 2 vectors.
    public static func ==( left: Point3D, right: Point3D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
    
    /// The Manhattan distance represented by a vector.
    public var magnitude: Int {
        return abs( x ) + abs( y ) + abs( z )
    }
}


/// Used to represent rectangluler solid in 3D.
public struct Rect3D: Hashable {
    public let min:    Point3D
    public let max:    Point3D
    public let width:  Int
    public let length: Int
    public let height: Int
    public let volume: Int
    
    /// Contructs a Rect3D from two diagonally opposite corners.
    ///
    /// In order to handle large coordinates, integer overflow is avoided.
    /// - Parameters:
    ///   - min: The point at one of the corners.
    ///   - max: The point at the opposite corner.
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

    /// Construct a Rect3D from a point, width, length, and height.
    /// - Parameters:
    ///   - min: The minimum corner of the rectangle.
    ///   - width: The rectangle width, increasing x.
    ///   - length: The rectangle length, increasing y.
    ///   - height: The rectangle height, increasing z.
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
    
    /// Construct a Rect3D from a list of Point3D.
    ///
    /// Makes the smallest rectangle that contains all the points in the list.
    /// - Parameter points: The list of points to include.
    public init( points: [Point3D] ) {
        var bounds = Rect3D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    /// Construct a Rect3D from a list of Rect3D.
    ///
    /// Makes the smallest rectangle that contains all the rectangles in the list.
    /// - Parameter rects: The list of rectangles to include.
    public init( rects: [Rect3D] ) {
        var bounds = Rect3D( min: rects[0].min, max: rects[0].max )
        
        rects[1...].forEach {
            bounds = bounds.expand( with: $0.min )
            bounds = bounds.expand( with: $0.max )
        }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    /// A list of all the points that lie within (and on the boundary) of the rectangle.
    public var points: [Point3D] {
         ( min.z ... max.z ).flatMap { z in
             ( min.y ... max.y ).flatMap { y in
                 ( min.x ... max.x ).map { x in Point3D( x: x, y: y, z: z ) } } }
     }

    /// Creates a new rectangle completely containing this rectangle and a given point.
    /// - Parameter point: The point used to expand this rectangle.
    /// - Returns: The smallest rectangle containing all of the original rectangle and the new point.
    func expand( with point: Point3D ) -> Rect3D {
        let minX = Swift.min( min.x, point.x )
        let maxX = Swift.max( max.x, point.x )
        let minY = Swift.min( min.y, point.y )
        let maxY = Swift.max( max.y, point.y )
        let minZ = Swift.min( min.z, point.z )
        let maxZ = Swift.max( max.z, point.z )

        return Rect3D( min: Point3D( x: minX, y: minY, z: minZ ), max: Point3D( x: maxX, y: maxY, z: maxZ ) )
    }
    
    /// Create a new rectangle based on this one with extra space in each of the 6 directions.
    /// - Parameters:
    ///   - byMinX: Padding amount in the negative x direction.
    ///   - byMaxX: Padding amount in the positive x direction.
    ///   - byMinY: Padding amount in the negative y direction.
    ///   - byMaxY: Padding amount in the positive y direction.
    ///   - byMinZ: Padding amount in the negative z direction.
    ///   - byMaxZ: Padding amount in the positive z direction.
    /// - Returns: A new Rect3d same as the original except padded in the 6 given amounts.
    func pad(
        byMinX: Int = 0, byMaxX: Int = 0,
        byMinY: Int = 0, byMaxY: Int = 0,
        byMinZ: Int = 0, byMaxZ: Int = 0
    ) -> Rect3D {
        return Rect3D( min: Point3D( x: min.x - byMinX, y: min.y - byMinY, z: min.z - byMinZ ),
                       max: Point3D( x: max.x + byMaxX, y: max.y + byMaxY, z: max.z + byMaxZ ) )
    }
    
    /// Create a new rectangle based on this one with extra space in all of the 6 directions.
    /// - Parameter by: Padding amount to apply in all 6 directions.
    /// - Returns: A new Rect3d same as the original except padded the same in all 6 directions.
    public func pad( by: Int ) -> Rect3D {
        return pad( byMinX: by, byMaxX: by, byMinY: by, byMaxY: by, byMinZ: by, byMaxZ: by )
    }
    
    /// Check if a point is contained in a rectangle.
    ///
    /// Points on the rectangle boundary are considered contained.
    /// - Parameter point: The point to check.
    /// - Returns: True or false.
    public func contains( point: Point3D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }
        guard min.z <= point.z, point.z <= max.z else { return false }

        return true
    }
    
    /// Constructs the rectangle that is the intersection of two rectangles.
    /// - Parameter other: The rectangle to intersect with this one.
    /// - Returns: The rectangle contained within both the others.  May be empty.
    public func intersection( with other: Rect3D ) -> Rect3D? {
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


/// Used to implement matrix transformations in 3D coordinate systems.
public struct Matrix3D {
    /// The identity matrix, i.e. does no transformation.
    ///
    /// Usually used to construct other matrices.
    public static var identity: Matrix3D {
        let matrix = [
            [ 1, 0, 0, 0 ],
            [ 0, 1, 0, 0 ],
            [ 0, 0, 1, 0 ],
            [ 0, 0, 0, 1 ]
        ]
        return Matrix3D( matrix: matrix )
    }
    
    /// Creates a scale matrix.
    /// - Parameter factors: A vector giving the scale factor in each of the 3 dimensions.
    /// - Returns: A matrix that will scale with the given factors.
    static func scale( by factors: Point3D ) -> Matrix3D {
        var matrix = identity.matrix
        matrix[0][0] = factors.x
        matrix[1][1] = factors.y
        matrix[2][2] = factors.z
        return Matrix3D( matrix: matrix )
    }
    
    /// Creates a rotation matrix about the x axis.
    ///
    /// Only multiples of 90 degrees are supported.
    /// - Parameter by: The amount of rotation - right, left, straight, or back.
    /// - Returns: A matrix that will rotate around the x axis by the specified turn.
    public static func rotate( aroundX by: Turn ) -> Matrix3D {
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
    
    /// Creates a rotation matrix about the y axis.
    ///
    /// Only multiples of 90 degrees are supported.
    /// - Parameter by: The amount of rotation - right, left, straight, or back.
    /// - Returns: A matrix that will rotate around the y axis by the specified turn.
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
    
    /// Creates a rotation matrix about the z axis.
    ///
    /// Only multiples of 90 degrees are supported.
    /// - Parameter by: The amount of rotation - right, left, straight, or back.
    /// - Returns: A matrix that will rotate around the z axis by the specified turn.
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
    
    /// Creates a rotation matrix about the origin.
    ///
    /// Only multiples of 90 degrees are supported - right, left, straight, or back.
    ///
    /// Rotations are applied first x, then y, then z.
    /// - Parameters:
    ///   - byX: The amount of x rotation.
    ///   - byY: The amount of y rotation.
    ///   - byZ: The amount of z rotation.
    /// - Returns: A matrix that will rotate around the origin by the specified turns.
    public static func rotate( aroundX byX: Turn, aroundY byY: Turn, aroundZ byZ: Turn ) -> Matrix3D {
        rotate( aroundX: byX ).multiply( by: rotate( aroundY: byY ) ).multiply( by: rotate(aroundZ: byZ ) )
    }
    
    let matrix: [[Int]]
    
    /// Create a Matrix3D object from an array of integer arrays.
    /// - Parameter matrix: A 4 by 4 array of integers.
    init( matrix: [[Int]] ) {
        self.matrix = matrix
    }
    
    /// Multiple two matrices together, combining the two transformations into one.
    /// - Parameter other: The multiplicand matrix.
    /// - Returns: A new matrix combining the two transformations.
    public func multiply( by other: Matrix3D ) -> Matrix3D {
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
    
    /// Use this matrix to transform the given point.
    /// - Parameter point: The point to transform.
    /// - Returns: The resulting point after the transformation.
    public func transform( point: Point3D ) -> Point3D {
        let newX = point.x * matrix[0][0] + point.y * matrix[1][0] + point.z * matrix[2][0] + matrix[3][0]
        let newY = point.x * matrix[0][1] + point.y * matrix[1][1] + point.z * matrix[2][1] + matrix[3][1]
        let newZ = point.x * matrix[0][2] + point.y * matrix[1][2] + point.z * matrix[2][2] + matrix[3][2]
        return Point3D( x: newX, y: newY, z: newZ )
    }
    
    /// Create a new matrix with a translation component added to this one.
    ///
    /// A shortcut for `self.multiply( other: Matrix3D.identity.add( translation: translation ) )`
    /// - Parameter translation: A vector giving the desired translation.
    /// - Returns: A new matrix which is a copy of the current one with the translation added.
    public func add( translation: Point3D ) -> Matrix3D {
        var matrix = self.matrix
        matrix[3][0] += translation.x
        matrix[3][1] += translation.y
        matrix[3][2] += translation.z
        return Matrix3D( matrix: matrix )
    }
}


/// Used to represent points and vectors in 4D.
public struct Point4D: Hashable {
    public let x: Int
    public let y: Int
    public let z: Int
    public let t: Int

    public init(x: Int, y: Int, z: Int, t: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
    
    /// Returns the Manhattan distance between two points.
    public func distance( other: Point4D ) -> Int {
        return abs( x - other.x ) + abs( y - other.y ) + abs( z - other.z ) + abs( t - other.t )
    }
    
    /// Adds either 2 vectors or a point and a vector.
    ///
    /// Adding 2 vectors gives a new vector that is the same as following one vector then the other.
    /// Adding a vector to a point gives a new point representing a move from the first point to the new one.
    static func +( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x + right.x, y: left.y + right.y, z: left.z + right.z, t: left.t + right.t )
    }
    
    /// Subtracts either one point from another or a vector from a point.
    ///
    /// Subtracting 2 points gives the vector that moves from the second point to the first.
    /// Subtracting a vector from a point gives a new point in the opposite direction of the vector.
    /// Subtracting 2 vectors is less common.  It yields a new vector.
    static func -( left: Point4D, right: Point4D ) -> Point4D {
        return Point4D( x: left.x - right.x, y: left.y - right.y, z: left.z - right.z, t: left.t - right.t )
    }
    
    /// Compares 2 points or 2 vectors.
    public static func ==( left: Point4D, right: Point4D ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z && left.t == right.t
    }
    
    /// The Manhattan distance represented by a vector.
    var magnitude: Int {
        return abs( x ) + abs( y ) + abs( z ) + abs( t )
    }
}

/// Used to represent rectangluler solid in 4D.
public struct Rect4D: Hashable {
    public let min:      Point4D
    public let max:      Point4D
    let width:    Int
    let length:   Int
    let height:   Int
    let duration: Int
    let volume:   Int
    
    /// Contructs a Rect4D from two diagonally opposite corners.
    ///
    /// In order to handle large coordinates, integer overflow is avoided.
    /// - Parameters:
    ///   - min: The point at one of the corners.
    ///   - max: The point at the opposite corner.
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

    /// Construct a Rect4D from a point, width, length, height, and duration.
    /// - Parameters:
    ///   - min: The minimum corner of the rectangle.
    ///   - width: The rectangle width, increasing x.
    ///   - length: The rectangle length, increasing y.
    ///   - height: The rectangle height, increasing z.
    ///   - duration: The rectangle height, increasing t.
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
    
    /// Construct a Rect4D from a list of Point4D.
    ///
    /// Makes the smallest rectangle that contains all the points in the list.
    /// - Parameter points: The list of points to include.
    public init( points: [Point4D] ) {
        var bounds = Rect4D( min: points[0], max: points[0] )
        
        points[1...].forEach { bounds = bounds.expand( with: $0 ) }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    /// Construct a Rect4D from a list of Rect4D.
    ///
    /// Makes the smallest rectangle that contains all the rectangles in the list.
    /// - Parameter rects: The list of rectangles to include.
    init( rects: [Rect4D] ) {
        var bounds = Rect4D( min: rects[0].min, max: rects[0].max )
        
        rects[1...].forEach {
            bounds = bounds.expand( with: $0.min )
            bounds = bounds.expand( with: $0.max )
        }
        
        self.init( min: bounds.min, max: bounds.max )
    }
    
    /// Creates a new rectangle completely containing this rectangle and a given point.
    /// - Parameter point: The point used to expand this rectangle.
    /// - Returns: The smallest rectangle containing all of the original rectangle and the new point.
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
    
    /// Create a new rectangle based on this one with extra space in each of the 8 directions.
    /// - Parameters:
    ///   - byMinX: Padding amount in the negative x direction.
    ///   - byMaxX: Padding amount in the positive x direction.
    ///   - byMinY: Padding amount in the negative y direction.
    ///   - byMaxY: Padding amount in the positive y direction.
    ///   - byMinZ: Padding amount in the negative z direction.
    ///   - byMaxZ: Padding amount in the positive z direction.
    ///   - byMinT: Padding amount in the negative t direction.
    ///   - byMaxT: Padding amount in the positive t direction.
    /// - Returns: A new Rect4d same as the original except padded in the 8 given amounts.
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
    
    /// Create a new rectangle based on this one with extra space in all of the 8 directions.
    /// - Parameter by: Padding amount to apply in all 8 directions.
    /// - Returns: A new Rect4d same as the original except padded the same in all 8 directions.
    public func pad( by: Int ) -> Rect4D {
        return pad(
            byMinX: by, byMaxX: by, byMinY: by, byMaxY: by, byMinZ: by, byMaxZ: by, byMinT: by, byMaxT: by
        )
    }
    
    /// Check if a point is contained in a rectangle.
    ///
    /// Points on the rectangle boundary are considered contained.
    /// - Parameter point: The point to check.
    /// - Returns: True or false.
    func contains( point: Point4D ) -> Bool {
        guard min.x <= point.x, point.x <= max.x else { return false }
        guard min.y <= point.y, point.y <= max.y else { return false }
        guard min.z <= point.z, point.z <= max.z else { return false }
        guard min.t <= point.t, point.t <= max.t else { return false }

        return true
    }
    
    /// Constructs the rectangle that is the intersection of two rectangles.
    /// - Parameter other: The rectangle to intersect with this one.
    /// - Returns: The rectangle contained within both the others.  May be empty.
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
