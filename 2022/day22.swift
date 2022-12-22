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
struct Map {
    enum Tile: String { case limbo = " ", open = ".", wall = "#" }
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
    
    let map: [[Tile]]
    let bounds: Rect2D
    let path: [Step]
    var position: Point2D
    var direction: DirectionUDLR
    
    init( paragraphs: [[String]] ) {
        let rows = paragraphs[0].count
        let cols = paragraphs[0].map { $0.count }.max()!
        let characters = paragraphs[0].map { Array( $0 ) }
        
        map  = ( 0 ..< rows ).reduce(
            into: Array( repeating: Array( repeating: Tile.limbo, count: cols ), count: rows )
        ) { map, row in
            ( 0 ..< characters[row].count ).forEach { col in
                map[row][col] = Tile( rawValue: String( characters[row][col] ) )!
            }
        }
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: cols, height: rows )!
        
        let delimiters = Turn.allCases.map { $0.rawValue }.joined()
        path = paragraphs[1][0].tokenize( delimiters: delimiters ).map { Step( value: String( $0 ) ) }
        position = Point2D( x: map[0].firstIndex( where: { $0 == Tile.open } )!, y: 0 )
        direction = DirectionUDLR.right
    }
    
    subscript( point: Point2D ) -> Tile {
        map[point.y][point.x]
    }
    
    var dump: String {
        let mapLines = map.map { $0.map { $0.rawValue }.joined() }.joined( separator: "\n" )
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
                        switch self[next] {
                        case .open:
                            position = next
                        case .wall:
                            break MOVEMENT
                        case .limbo:
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
            let newY = ( 0 ..< map.count ).last( where: { map[$0][position.x] != .limbo } )!
            let newPos = Point2D( x: position.x, y: newY )
            if self[newPos] == .wall { return true }
            position = newPos
        case .down:
            let newY = ( 0 ..< map.count ).first( where: { map[$0][position.x] != .limbo } )!
            let newPos = Point2D( x: position.x, y: newY )
            if self[newPos] == .wall { return true }
            position = newPos
        case .left:
            let newX = map[position.y].lastIndex( where: { $0 != .limbo } )!
            let newPos = Point2D( x: newX, y: position.y )
            if self[newPos] == .wall { return true }
            position = newPos
        case .right:
            let newX = map[position.y].firstIndex( where: { $0 != .limbo } )!
            let newPos = Point2D( x: newX, y: position.y )
            if self[newPos] == .wall { return true }
            position = newPos
        }
        return false
    }
}


func part1( input: AOCinput ) -> String {
    var map = Map( paragraphs: input.paragraphs )
//    print( map.dump )
    return "\(map.followPath())"
}


func part2( input: AOCinput ) -> String {
    let something = Map( paragraphs: input.paragraphs )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
