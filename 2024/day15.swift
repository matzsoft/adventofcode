//
//         FILE: day15.swift
//  DESCRIPTION: Advent of Code 2024 Day 15: Warehouse Woes
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/14/24 22:07:57
//

import Foundation
import Library

enum Tile: Character { case empty = ".", wall = "#", box = "O", robot = "@" }
enum FatTile: Character {
    case empty = ".", wall = "#", leftBox = "[", rightBox = "]", robot = "@"
}

struct Warehouse: CustomStringConvertible {
    var map: [[Tile]]
    let bounds: Rect2D
    var robot: Point2D
    
    var description: String {
        map.map { String( $0.map { $0.rawValue } ) }.joined( separator: "\n" )
    }
    
    init( lines: [String] ) {
        let map = lines.map { $0.map { Tile( rawValue: $0 )! } }
        let row = map.indices.first( where: { map[$0].contains( .robot ) } )!
        let col = map[row].indices.first( where: { map[row][$0] == .robot } )!
        
        self.map = map
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count
        )!
        self.robot = Point2D( x: col, y: row )
    }
    
    subscript( point: Point2D ) -> Tile {
        get { map[point.y][point.x] }
        set { map[point.y][point.x] = newValue }
    }
    
    mutating func move( direction: DirectionUDLR ) -> Void {
        let destination = robot + direction.vector
        
        switch self[destination] {
        case .wall:
            break
        case .empty:
            self[robot] = .empty
            self[destination] = .robot
            robot = destination
        case .box:
            for final in 1 ... Int.max {
                let point = destination + final * direction.vector
                if self[point] == .wall { break }
                if self[point] == .empty {
                    self[robot] = .empty
                    self[destination] = .robot
                    self[point] = .box
                    robot = destination
                    break
                }
            }
        default:
            fatalError( "Unknown obstacle." )
        }
    }
    
    var score: Int {
        bounds.points
            .filter { self[$0] == .box }
            .reduce( 0 ) { $0 + 100 * $1.y + $1.x }
    }
}


struct FatWarehouse: CustomStringConvertible {
    var map: [[FatTile]]
    let bounds: Rect2D
    var robot: Point2D
    
    var description: String {
        map.map { String( $0.map { $0.rawValue } ) }.joined( separator: "\n" )
    }
    
    init( warehouse: Warehouse ) {
        map = warehouse.map.map { $0.flatMap {
            switch $0 {
            case .empty:
                return [ FatTile.empty, FatTile.empty ]
            case .wall:
                return [ FatTile.wall, FatTile.wall ]
            case .box:
                return [ FatTile.leftBox, FatTile.rightBox ]
            case .robot:
                return [ FatTile.robot, FatTile.empty ]
            }
        } }
        bounds = Rect2D(
            min: warehouse.bounds.min,
            width: 2 * warehouse.bounds.width, height: warehouse.bounds.height
        )!
        robot = Point2D( x: 2 * warehouse.robot.x, y: warehouse.robot.y )
    }
    
    subscript( point: Point2D ) -> FatTile {
        get { map[point.y][point.x] }
        set { map[point.y][point.x] = newValue }
    }
    
    mutating func move( direction: DirectionUDLR ) -> Void {
        let destination = robot + direction.vector
        
        switch self[destination] {
        case .wall:
            break
        case .empty:
            self[robot] = .empty
            self[destination] = .robot
            robot = destination
//        case .box:
//            for final in 1 ... Int.max {
//                let point = destination + final * direction.vector
//                if self[point] == .wall { break }
//                if self[point] == .empty {
//                    self[robot] = .empty
//                    self[destination] = .robot
//                    self[point] = .box
//                    robot = destination
//                    break
//                }
//            }
        default:
            fatalError( "Unknown obstacle." )
        }
    }
    
    var score: Int {
        bounds.points
            .filter { self[$0] == .leftBox }
            .reduce( 0 ) { $0 + 100 * $1.y + $1.x }
    }
}


func parse( input: AOCinput ) -> ( Warehouse, [DirectionUDLR] ) {
    let warehouse = Warehouse( lines: input.paragraphs[0] )
    let moves = input.paragraphs[1].joined().map {
        DirectionUDLR.fromArrows( char: String( $0 ) )!
    }
    return ( warehouse, moves )
}


func part1( input: AOCinput ) -> String {
    let ( warehouse, moves ) = parse( input: input )
    var workhouse = warehouse
    
    for move in moves {
        workhouse.move( direction: move )
//        print( "\(workhouse)")
    }
    return "\(workhouse.score)"
}


func part2( input: AOCinput ) -> String {
    let ( warehouse, moves ) = parse( input: input )
    var workhouse = FatWarehouse( warehouse: warehouse )
    
    print( "\(workhouse)")
    
    for move in moves {
        workhouse.move( direction: move )
//        print( "\(workhouse)")
    }
    return "\(workhouse.score)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
