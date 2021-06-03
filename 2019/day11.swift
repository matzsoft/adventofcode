//
//         FILE: main.swift
//  DESCRIPTION: day11 - Space Police
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/02/21 20:18:05
//

import Foundation

struct Robot {
    enum Turn: Int { case left = 0, right = 1 }
    enum Color: Int {
        case black = 0, white = 1
        
        func asString() -> String {
            switch self {
            case .black:
                return "█"
            case .white:
                return " "
            }
        }
    }
    
    let computer: Intcode
    var position: Point2D
    var direction: DirectionUDLR
    var map: [ Point2D : Color ]
    
    init( initialMemory: [Int] ) {
        computer = Intcode( name: "HullPainter", memory: initialMemory )
        position = Point2D( x: 0, y: 0 )
        direction = .up
        map = [:]
    }
    
    var paintedCount: Int {
        return map.count
    }
    
    mutating func paint() -> Void {
        while true {
            if let color = map[position] {
                computer.inputs = [ color.rawValue ]
            } else {
                computer.inputs = [ Color.black.rawValue ]
            }
            
            guard let color = try! computer.execute() else { break }
            guard let turn = try! computer.execute() else { break }
            
            if let color = Color( rawValue: color ) {
                map[position] = color
            }
            
            if let turn = Turn( rawValue: turn ) {
                switch turn {
                case .left:
                    direction = direction.turn( TurnLSR.left )
                case .right:
                    direction = direction.turn( TurnLSR.right )
                }
            }
            position = position + direction.vector
        }
    }
    
    mutating func paintIt( color: Color ) -> Void {
        map[position] = color
    }
    
    var ocr: String {
        let blockLetters = try! BlockLetterDictionary( from: "5x6+0.txt" )
        let whites = map.filter { $0.value == .white }.map { $0.key }
        let minX = whites.map { $0.x }.min()!
        let maxX = whites.map { $0.x }.max()! + 1
        let minY = whites.map { $0.y }.min()!
        let maxY = whites.map { $0.y }.max()!
        let bounds = Rect2D( min: Point2D( x: minX, y: minY ), max: Point2D(x: maxX, y: maxY ) )
        var screen = Array( repeating: Array( repeating: false, count: bounds.width ), count: bounds.height )
        
        for location in whites {
            screen[ location.y - bounds.min.y ][ location.x - bounds.min.x ] = true
        }
        
        return blockLetters.makeString( screen: screen )
    }
    
    func results() -> String {
        let bounds = Rect2D( points: map.keys.map { $0 as Point2D } )
        var grid = Array(
            repeating: Array( repeating: Color.black, count: bounds.width + 2 ),
            count: bounds.height + 2
        )
        
        for ( location, color ) in map {
            grid[ location.y - bounds.min.y + 1 ][ location.x - bounds.min.x + 1  ] = color
        }
        
        return grid.map { $0.map { $0.asString() }.joined() }.joined( separator: "\n" )
    }
}


func parse( input: AOCinput ) -> Robot {
    return Robot( initialMemory: input.line.split( separator: "," ).map { Int( $0 )! } )
}


func part1( input: AOCinput ) -> String {
    var robot = parse( input: input )
    
    robot.paint()
    return "\(robot.paintedCount)"
}


func part2( input: AOCinput ) -> String {
    var robot = parse( input: input )
    
    robot.paintIt( color: .white )
    robot.paint()
    print( robot.results() )
    return "\(robot.ocr)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
