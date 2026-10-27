//
//         FILE: day14.swift
//  DESCRIPTION: Advent of Code 2024 Day 14: Restroom Redoubt
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/13/24 21:00:00
//

import Foundation
import Library

extension Rect2D {
    var mid: Point2D { min + Point2D( x: width / 2, y: height / 2 ) }
    
    func wrapped( point: Point2D ) -> Point2D {
        Point2D( x: point.x.mod( width ), y: point.y.mod( height ) )
    }
}

extension Int {
    func mod( _ n: Int ) -> Int {
        let result = self % n
        return result >= 0 ? result : result + n
    }
}

enum OutputType: String { case yes, no, movie }


struct Robot {
    let position: Point2D
    let velocity: Point2D
}


struct Lobby {
    let bounds: Rect2D
    let robots: [Robot]
    let output: OutputType
    
    func robots( at step: Int) -> [Point2D] {
        self.robots.map { bounds.wrapped( point: $0.position + step * $0.velocity ) }
    }
    
    func description( at step: Int ) -> String {
        var buffer = Array(
            repeating: Array( repeating: Character( "." ), count: bounds.width ),
            count: bounds.height
        )
        
        robots( at: step ).forEach { buffer[$0.y][$0.x] = "*" }
        return buffer.map { String( $0 ) }.joined( separator: "\n" )
    }
}


func parse( input: AOCinput ) -> Lobby {
    let robots = input.lines.map {
        let fields = $0.split( whereSeparator: { "=, ".contains( $0 ) } )
        return Robot(
            position: Point2D( x: Int( fields[1] )!, y: Int( fields[2] )! ),
            velocity: Point2D( x: Int( fields[4] )!, y: Int( fields[5] )! )
        )
    }
    let fields = input.extras[0].split( separator: "," ).map { Int( $0 )! }
    let bounds = Rect2D(
        min: Point2D( x: 0, y: 0 ), width: fields[0], height: fields[1] )!
    let output = OutputType( rawValue: input.extras[1] )!
    
    return Lobby( bounds: bounds, robots: robots, output: output )
}


func part1( input: AOCinput ) -> String {
    let lobby = parse( input: input )
    let robots = lobby.robots( at: 100 )
    let mid = lobby.bounds.mid
    let quadrants = robots.reduce( into: Array( repeating: 0, count: 4 ) ) {
        quadrants, robot in
        
        switch ( robot.x, robot.y ) {
        case let ( x, y ) where x > mid.x && y < mid.y:
            quadrants[0] += 1
        case let ( x, y ) where x < mid.x && y < mid.y:
            quadrants[1] += 1
        case let ( x, y ) where x < mid.x && y > mid.y:
            quadrants[2] += 1
        case let ( x, y ) where x > mid.x && y > mid.y:
            quadrants[3] += 1
        default:
            break
        }
    }
    return "\(quadrants.reduce( 1, * ))"
}


func part2( input: AOCinput ) -> String {
    let lobby = parse( input: input )
    for step in 1 ... ( lobby.bounds.width * lobby.bounds.height ) {
        let robots = lobby.robots( at: step )

        if robots.count == Set( robots ).count {
            if lobby.output == .yes {
                print( step )
                print( lobby.description( at: step ) )
            }
            return "\(step)"
        }
    }
    
    return "No solution found."
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
