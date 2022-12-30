//
//         FILE: main.swift
//  DESCRIPTION: day22 - Monkey Map
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/21/22 22:21:08
//

import Foundation

extension DirectionUDLR {
    var toInt: Int {
        switch self {
        case .up:
            return 3
        case .down:
            return 1
        case .left:
            return 2
        case .right:
            return 0
        }
    }
}

extension Point3D{
    func orthogonal( other: Point3D ) -> Point3D? {
        let magnitude = magnitude
        guard x * other.x + y * other.y + z * other.z == 0 else { return nil }
        guard magnitude == other.magnitude else { return nil }
        
        let unitVector1 = Point3D( x: x / magnitude, y: y / magnitude, z: z / magnitude )
        let unitVector2 = Point3D( x: other.x / magnitude, y: other.y / magnitude, z: other.z / magnitude )
        
        return Point3D(
            x: unitVector1.y * unitVector2.z - unitVector2.y * unitVector1.z,
            y: unitVector1.x * unitVector2.z - unitVector2.x * unitVector1.z,
            z: unitVector1.x * unitVector2.y - unitVector2.x * unitVector1.y
        )
    }
    
    var reversed: Point3D {
        Point3D( x: -x, y: -y, z: -z )
    }
}


struct Map {
    enum Step: CustomStringConvertible {
        case move( Int ), turn( Turn )
        
        init( value: String ) {
            if let number = Int( value ) {
                self = .move( number )
            } else {
                self = .turn( Turn( rawValue: value )! )
            }
        }
        
        var description: String {
            switch self {
            case .move( let number ):
                return String( number )
            case .turn( let turn ):
                return turn.rawValue
            }
        }
    }
    
    let map: [[Tile?]]
    let bounds: Rect2D
    let path: [Step]
    var position: Point2D
    var direction: DirectionUDLR
    
    init( paragraphs: [[String]] ) {
        let rows = paragraphs[0].count
        let cols = paragraphs[0].map { $0.count }.max()!
        let characters = paragraphs[0].map { Array( $0 ) }
        
        map = ( 0 ..< rows ).reduce(
            into: Array( repeating: Array( repeating: nil, count: cols ), count: rows )
        ) { map, row in
            ( 0 ..< characters[row].count ).forEach { col in
                if let tileType = Tile.TileType( rawValue: String( characters[row][col] ) ) {
                    map[row][col] = Tile( tileType: tileType, location: Point2D( x: col, y: row ) )
                }
            }
        }
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: cols, height: rows )!
        
        let delimiters = Turn.allCases.map { $0.rawValue }.joined()
        path = paragraphs[1][0].tokenize( delimiters: delimiters ).map { Step( value: String( $0 ) ) }
        position = Point2D( x: map[0].firstIndex( where: { $0?.tileType == .open } )!, y: 0 )
        direction = DirectionUDLR.right
    }
    
    subscript( point: Point2D ) -> Tile? {
        guard bounds.contains( point: point ) else { return nil }
        return map[point.y][point.x]
    }
    
    var dump: String {
        let mapLines = map.map { $0.map { $0?.tileType.rawValue ?? " " }.joined() }.joined( separator: "\n" )
        let pathLines = path.map { "\($0)" }.joined( separator: " " )
        
        return [ mapLines, pathLines ].joined( separator: "\n\n" )
    }
    
    mutating func followPath() -> Int {
        for step in path {
            switch step {
            case .turn( let turn ):
                direction = direction.turn( turn )
            case .move( let number ):
                MOVEMENT:
                for _ in 1 ... number {
                    let next = position + direction.vector
                    
                    if !bounds.contains( point: next ) {
                        if isWallOnOtherSide() { break MOVEMENT }
                    } else {
                        switch self[next]?.tileType {
                        case .open:
                            position = next
                        case .wall:
                            break MOVEMENT
                        case nil:
                            if isWallOnOtherSide() { break MOVEMENT }
                        }
                    }
                }
            }
        }
        return 1000 * ( position.y + 1 ) + 4 * ( position.x + 1 ) + direction.toInt
    }
    
    mutating func isWallOnOtherSide() -> Bool {
        switch direction {
        case .up:
            let newY = ( 0 ..< map.count ).last( where: { map[$0][position.x] != nil } )!
            let newPos = Point2D( x: position.x, y: newY )
            if self[newPos]?.tileType == .wall { return true }
            position = newPos
        case .down:
            let newY = ( 0 ..< map.count ).first( where: { map[$0][position.x] != nil } )!
            let newPos = Point2D( x: position.x, y: newY )
            if self[newPos]?.tileType == .wall { return true }
            position = newPos
        case .left:
            let newX = map[position.y].lastIndex( where: { $0 != nil } )!
            let newPos = Point2D( x: newX, y: position.y )
            if self[newPos]?.tileType == .wall { return true }
            position = newPos
        case .right:
            let newX = map[position.y].firstIndex( where: { $0 != nil } )!
            let newPos = Point2D( x: newX, y: position.y )
            if self[newPos]?.tileType == .wall { return true }
            position = newPos
        }
        return false
    }
}


class Face: Hashable, CustomStringConvertible {
    enum Facing: String, CaseIterable { case front, back, left, right, up, down }
    
    let id: Int
    let map: Map
    let bounds: Rect2D
    var base: Point3D
    var topVector: Point3D
    var leftVector: Point3D
//    var tiles: [[Tile]]
    var faces = [ DirectionUDLR : Face ]()
    
    static func == ( lhs: Face, rhs: Face ) -> Bool {
        lhs.id == rhs.id
    }
    
   init( map: Map, bounds: Rect2D, id: Int ) {
        self.id = id
        self.map = map
        self.bounds = bounds
        self.base = Point3D( x: bounds.min.x, y: bounds.min.y, z: 0 )
        self.topVector = Point3D( x: bounds.width - 1, y: 0, z: 0 )
        self.leftVector = Point3D( x: 0, y: bounds.height - 1, z: 0 )
//        self.tiles = []
//        self.tiles = ( bounds.min.x ... bounds.max.x ).map { x in
//            ( bounds.min.y ... bounds.max.y ).map { y in
//                Tile( location: Point2D( x: x, y: y ) )
//            }
//        }
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( id )
    }

//    subscript( point: Point2D ) -> Tile {
//        return tiles[ point.y - bounds.min.y ][ point.x - bounds.min.x ]
//    }
    
    var description: String {
        let faces = self.faces.map { "\($0.key.rawValue) → \($0.value.id)" }.joined( separator: ", " )
        return "\(id): \(bounds) \(base) \(topVector) \(leftVector)\n   \(faces)"
    }
    
    var corners: [Point3D] {
        [ base, base + topVector, base + leftVector, base + topVector + leftVector ]
    }
    
    func connectLeft( other: Face, cubeBounds: Rect3D ) -> Void {
        guard let unit = topVector.orthogonal( other: leftVector ) else { return }
        let full = ( bounds.width - 1 ) * unit
        
        other.topVector = cubeBounds.contains( point: base + unit ) ? full.reversed : full
        other.base = base - other.topVector
        other.leftVector = leftVector
        
        faces[.left] = other
        other.faces[.right] = self
    }
    
    func connectDown( other: Face, cubeBounds: Rect3D ) -> Void {
        guard let unit = topVector.orthogonal( other: leftVector ) else { return }
        let full = ( bounds.width - 1 ) * unit

        other.base = base + leftVector
        other.topVector = topVector
        other.leftVector = cubeBounds.contains( point: other.base + unit ) ? full : full.reversed
        
        faces[.down] = other
        other.faces[.up] = self
    }
    
    func connectRight( other: Face, cubeBounds: Rect3D ) -> Void {
        guard let unit = topVector.orthogonal( other: leftVector ) else { return }
        let full = ( bounds.width - 1 ) * unit

        other.base = base + topVector
        other.topVector = cubeBounds.contains( point: other.base + unit ) ? full : full.reversed
        other.leftVector = leftVector
        
        faces[.right] = other
        other.faces[.left] = self
    }
    
    func vector( other: Face ) -> Point2D {
        Point2D(
            x: ( other.bounds.min.x - bounds.min.x ) / bounds.width,
            y: ( other.bounds.min.y - bounds.min.y ) / bounds.height
        )
    }
}


class Tile: Hashable {
    enum TileType: String { case open = ".", wall = "#" }

    let tileType: TileType
    let location: Point2D
    var neighbors = [ DirectionUDLR : Point2D ]()
    var transitions = [ DirectionUDLR : DirectionUDLR ]()
    
    static func == ( lhs: Tile, rhs: Tile ) -> Bool {
        lhs.location == rhs.location
    }
    
    init( tileType: TileType, location: Point2D ) {
        self.tileType = tileType
        self.location = location
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( location )
    }
}


struct Cube {
    let map: Map
    let faces: [Face]
    let edges: Int
    let bounds: Rect3D
    
    init( input: AOCinput ) {
        let map = Map( paragraphs: input.paragraphs )
        let edges = Int( input.extras[0] )!
    
        let faces = stride( from: 0, to: map.bounds.height, by: edges ).flatMap { row in
            stride( from: 0, to: map.bounds.width, by: edges ).compactMap { col in
                let point = Point2D( x: col, y: row )
                return map[point] == nil ? nil : Rect2D( min: point, width: edges, height: edges )!
            }
        }.enumerated().map { Face( map: map, bounds: $1, id: $0 + 1 ) }

        self.map   = map
        self.faces = faces
        self.edges = edges
        self.bounds = Rect3D(
            min: Point3D( x: faces[0].bounds.min.x, y: faces[0].bounds.min.y, z: 0 ),
            width: edges, length: edges, height: edges )!
        
        fold()
        connect()
    }
    
    var representation: String {
        let fakeEdge = 5
        let bounds = Rect2D(
            min: Point2D( x: map.bounds.min.x / edges * fakeEdge, y: map.bounds.min.y / edges * fakeEdge ),
            width: map.bounds.width / edges * fakeEdge, height: map.bounds.height / edges * fakeEdge
        )!.pad( by: 1 )
        var buffer = Array( repeating: Array( repeating: " ", count: bounds.width ), count: bounds.height )
        
        for face in faces {
            let faceBounds = Rect2D(
                min: Point2D(
                    x: face.bounds.min.x / edges * fakeEdge + 1,
                    y: face.bounds.min.y / edges * fakeEdge + 1
                ),
                width: face.bounds.width / edges * fakeEdge,
                height: face.bounds.height / edges * fakeEdge
            )!
            for row in faceBounds.yRange {
                for col in faceBounds.xRange {
                    buffer[row][col] = String( face.id )
                }
            }
            for ( direction, other ) in face.faces {
                switch direction {
                case .up:
                    buffer[ faceBounds.min.y - 1 ][ faceBounds.min.x + fakeEdge / 2 ] = String( other.id )
                case .down:
                    buffer[ faceBounds.max.y + 1 ][ faceBounds.min.x + fakeEdge / 2 ] = String( other.id )
                case .left:
                    buffer[ faceBounds.min.y + fakeEdge / 2 ][ faceBounds.min.x - 1 ] = String( other.id )
                case .right:
                    buffer[ faceBounds.min.y + fakeEdge / 2 ][ faceBounds.max.x + 1 ] = String( other.id )
                }
            }
        }
        return buffer.map { $0.joined() }.joined( separator: "\n" )
    }
    
    func fold() -> Void {
        var established = Set( [ faces[0] ] )
        var queue = [ faces[0] ]
        
        while !queue.isEmpty {
            let face = queue.removeFirst()
            
            established.insert( face )
            let neighbors = faces
                .map { ( face.vector(other: $0 ), $0 ) }
                .filter { $0.0.magnitude == 1 && !established.contains( $0.1 ) }
            
            for ( vector, neighbor ) in neighbors {
                queue.append( neighbor )
                switch vector {
                case Point2D( x: -1, y: 0 ):
                    face.connectLeft( other: neighbor, cubeBounds: bounds )
                case Point2D( x: 0, y: 1 ):
                    face.connectDown( other: neighbor, cubeBounds: bounds )
                case Point2D( x: 1, y: 0 ):
                    face.connectRight( other: neighbor, cubeBounds: bounds )
                default:
                    fatalError( "Bad vector Victor" )
                }
            }
        }
    }
    
    func connect() -> Void {
        let nullVector = Point3D( x: 0, y: 0, z: 0 )
        for face in faces {
            for direction in DirectionUDLR.allCases {
                guard face.faces[direction] == nil else { continue }
                switch direction {
                case .up:
                    connect( face: face, direction: direction, vector1: nullVector, vector2: face.topVector )
                case .down:
                    connect(
                        face: face, direction: direction, vector1: face.leftVector, vector2: face.topVector
                    )
                case .left:
                    connect(
                        face: face, direction: direction, vector1: nullVector, vector2: face.leftVector
                    )
                case .right:
                    connect(
                        face: face, direction: direction, vector1: face.topVector, vector2: face.leftVector
                    )
                }
            }
        }
    }
    
    func connect( face: Face, direction: DirectionUDLR, vector1: Point3D, vector2: Point3D ) -> Void {
        let point1 = face.base + vector1
        let point2 = point1 + vector2
        let other = faces.first { $0 != face && Set( $0.corners ).isSuperset( of: [ point1, point2 ] ) }!
        
        face.faces[direction] = other
    }
}


func part1( input: AOCinput ) -> String {
    var map = Map( paragraphs: input.paragraphs )
//    print( map.dump )
    return "\(map.followPath())"
}


func part2( input: AOCinput ) -> String {
    let cube = Cube( input: input )
    
    cube.faces.forEach { print( "\($0)" ) }
    print( cube.representation )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
