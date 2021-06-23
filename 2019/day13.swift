//
//         FILE: main.swift
//  DESCRIPTION: day13 - Care Package
//        NOTES: Should be run in Teminal as Xcode does not support terminal emulation
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/03/21 12:08:06
//

import Foundation

struct ArcadeCabinet {
    enum TileID: Int {
        case empty = 0, wall = 1, block = 2, paddle = 3, ball = 4
        
        func asString() -> String {
            switch self {
            case .empty:
                return " "
            case .wall:
                return "█"
            case .block:
                return "▒"
            case .paddle:
                return "▁"
            case .ball:
                return "●"
            }
        }
    }
    enum Joystick: Int { case left = -1, neutral = 0, right = 1 }

    let computer: Intcode
    var map: [[TileID]] = []
    var paddlePos = Point2D( x: 0, y: 0 )
    var ballPos = Point2D( x: 0, y: 0 )
    var score = 0
    var computerHalted = false

    var width: Int { return map.count == 0 ? 0 : map[0].count }
    var height: Int { return map.count }
    var asString: String { return map.map { $0.map { $0.asString() }.joined() }.joined( separator: "\n" ) }

    init( initialMemory: [Int] ) throws {
        var tiles: [ Point2D : TileID ] = [:]
        
        computer = Intcode( name: "BreakOut", memory: initialMemory )
        
        computer.memory[0] = 2
        while let ( position, type ) = try move() {
            tiles[ position ] = type
        }
        
        let bounds = Rect2D( points: tiles.map { $0.key } )
        
        map = Array( repeating: Array( repeating: TileID.empty, count: bounds.width ), count: bounds.height )
        for ( position, type ) in tiles {
            map[position.y][position.x] = type
        }
    }
    
    mutating func move() throws -> ( Point2D, TileID )? {
        computerHalted = false
        guard let x = try computer.execute() else { computerHalted = true; return nil }
        guard let y = try computer.execute() else { computerHalted = true; return nil }
        guard let value = try computer.execute() else { computerHalted = true; return nil }
        
        if x == -1 {
            score = value
            return nil
        }
        
        let position = Point2D( x: x, y: y )

        guard let type = TileID( rawValue: value ) else { return nil }
        
        switch type {
        case .paddle:
            paddlePos = position
        case .ball:
            ballPos = position
        default:
            break
        }
        
        return ( position, type )
    }
    
    func count( of type: TileID ) -> Int {
        return map.reduce( 0, { $0 + $1.filter( { $0 == type } ).count } )
    }
    
    mutating func play() throws -> Int {
        computer.inputs = [ ( ballPos.x - paddlePos.x ).signum() ]
        while !computerHalted {
            while let ( position, type ) = try move() {
                map[position.y][position.x] = type
                Terminal.move( to: position )
                switch type {
                case .ball:
                    print( type.asString(), separator: "", terminator: "" )
                    computer.inputs = [ ( ballPos.x - paddlePos.x ).signum() ]
                    usleep( 25000 )
                    fflush(stdout)
                case .paddle:
                    print( type.asString(), separator: "", terminator: "" )
                case .empty:
                    print( type.asString(), separator: "", terminator: "" )
                default:
                    Terminal.move( to: Point2D( x: 0, y: height + 2 ) )
                    print( "Unexpected \(type) at \(position)" )
                }
            }
            Terminal.move(to: Point2D( x: 0, y: height ) )
            print( "Score: \(score)" )
        }
        
        return score
    }
}

class Terminal {
    static let escape = Character( UnicodeScalar( 27 ) )
    
    static func clearScreen() -> Void {
        print( escape, "[2J", separator: "", terminator: "" )
    }
    
    static func move( to position: Point2D ) -> Void {
        print( escape, "[\(position.y+1);\(position.x+1)H", separator: "", terminator: "" )
    }
}


func parse( input: AOCinput ) -> ArcadeCabinet {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }
    return try! ArcadeCabinet( initialMemory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    let cabinet = parse( input: input )
    return "\( cabinet.count( of: .block ) )"
}


func part2( input: AOCinput ) -> String {
    var cabinet = parse( input: input )
    
    Terminal.clearScreen()
    Terminal.move( to: Point2D(x: 0, y: 0 ) )
    print( cabinet.asString )
    print( "Score: \(cabinet.score)" )

    let finalScore = try! cabinet.play()

    Terminal.move(to: Point2D( x: 0, y: cabinet.height + 2 ) )
    return "\(finalScore)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
