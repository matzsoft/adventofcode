//
//         FILE: main.swift
//  DESCRIPTION: day17 - Reservoir Research
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/25/21 12:21:18
//

import Foundation

class Map {
    enum Cell: String { case drySand = ".", wetSand = "|", clay = "#", water = "~" }

    struct Description {
        let type: String
        let value: Int
        let low: Int
        let high: Int
        
        init( line: String ) {
            let words = line.split(whereSeparator: { "=, .".contains($0) } )
            
            type = String( words[0] )
            value = Int( words[1] )!
            low = Int( words[3] )!
            high = Int( words[4] )!
        }
    }

    var map: [[Cell]]
    let bounds: Rect2D

    init( lines: [String] ) {
        let descriptions = lines.map { Description( line: $0 ) }
        let clay = descriptions.flatMap { description -> [Point2D] in
            if description.type == "x" {
                return ( description.low ... description.high ).map { y -> Point2D in
                    Point2D( x: description.value, y: y )
                }
            } else {
                return ( description.low ... description.high ).map { x -> Point2D in
                    Point2D( x: x, y: description.value )
                }
            }
        }
        let bounds = Rect2D( points: clay )
        
        self.bounds = Rect2D( min: Point2D( x: bounds.min.x - 1, y: bounds.min.y ),
                              width: bounds.width + 2, height: bounds.height )!
        
        map = Array(
            repeating: Array( repeating: Cell.drySand, count: self.bounds.width + 1 ),
            count: self.bounds.height + 1
        )
        clay.forEach { self[$0] = .clay }
    }
    
    subscript( position: Point2D ) -> Cell {
        get { return map[ position.y - bounds.min.y ][ position.x - bounds.min.x ] }
        set( newValue ) { map[ position.y - bounds.min.y ][ position.x - bounds.min.x ] = newValue }
    }
    
    func printMap() -> Void {
        map.forEach { print( $0.map { $0.rawValue }.joined() ) }
        print()
    }
    
    func scanLeft( position: Point2D ) -> ( x: Int, falls: Bool ) {
        var position = position
        
        while position.x > bounds.min.x {
            let left = position + DirectionUDLR.left.vector
            switch self[left] {
            case .drySand, .wetSand:
                position = left
                switch self[ position + DirectionUDLR.down.vector ] {
                case .drySand, .wetSand:
                    return ( x: position.x, falls: true )
                case .clay, .water:
                    continue
                }
            case .clay, .water:
                return ( x: position.x, falls: false )
            }
        }
        return ( x: bounds.min.x, falls: true )
    }
    
    func scanRight( position: Point2D ) -> ( x: Int, falls: Bool ) {
        var position = position

        while position.x < bounds.max.x {
            let right = position + DirectionUDLR.right.vector
            switch self[right] {
            case .drySand, .wetSand:
                position = right
                switch self[ position + DirectionUDLR.down.vector ] {
                case .drySand, .wetSand:
                    return ( x: position.x, falls: true )
                case .clay, .water:
                    continue
                }
            case .clay, .water:
                return ( x: position.x, falls: false )
            }
        }
        return ( x: bounds.max.x, falls: true )
    }
    
    func fill( position: Point2D ) -> Void {
        var position = position
        
        while position.y < bounds.max.y {
            let down = position + DirectionUDLR.down.vector
            switch self[down] {
            case .drySand:
                position = down
                self[down] = .wetSand
            case .wetSand:
                position = down
            case .clay, .water:
                let ( leftEnd, leftFall ) = scanLeft( position: position )
                let ( rightEnd, rightFall ) = scanRight( position: position )
                
                if !leftFall && !rightFall {
                    ( leftEnd ... rightEnd ).forEach { self[ Point2D( x: $0, y: position.y ) ] = .water }
                    position = position + DirectionUDLR.up.vector
                } else {
                    ( leftEnd ... rightEnd ).forEach { self[ Point2D( x: $0, y: position.y ) ] = .wetSand }
                    if leftFall {
                        fill( position: Point2D( x: leftEnd, y: position.y ) )
                    }
                    if rightFall {
                        fill( position: Point2D( x: rightEnd, y: position.y ) )
                    }
                    return
                }
            }
        }
    }
    
    func countWetSand() -> Int {
        return map.flatMap { $0 }.reduce( 0 ) { if case .wetSand = $1 { return $0 + 1 }; return $0 }
    }
    
    func countWater() -> Int {
        return map.flatMap { $0 }.reduce( 0 ) { if case .water = $1 { return $0 + 1 }; return $0 }
    }
}


func part1( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    
    map.fill( position: Point2D( x: 500, y: map.bounds.min.y - 1 ) )
    return "\(map.countWetSand() + map.countWater())"
}


func part2( input: AOCinput ) -> String {
    let map = Map( lines: input.lines )
    
    map.fill( position: Point2D( x: 500, y: map.bounds.min.y - 1 ) )
    return "\(map.countWater())"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
