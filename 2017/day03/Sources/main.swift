//
//         FILE: main.swift
//  DESCRIPTION: day03 - Spiral Memory
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/15/21 11:20:14
//

import Foundation
import Library

struct Square {
    let label: Int
    let position: Point2D
    let value: Int
}


func quadratic( b: Int, c: Int ) throws -> Int {
    let square = b * b - 16 * c
    
    guard square >= 0 else { throw RuntimeError( "Imaginary solution" ) }

    let root = sqrt( Double( square ) )
    let solution1 = ( Double( -b ) + root ) / 8
    let solution2 = ( Double( -b ) - root ) / 8
    
    guard solution2 <= 0 else { throw RuntimeError( "Two solutions" ) }
    guard solution1 >= 0 else { throw RuntimeError( "No solutions" ) }

    return Int( solution1 )
}


func coords( square: Int ) -> Point2D {
    guard square > 1 else { return Point2D( x: 0, y: 0 ) }
    
    let base = try! quadratic( b: 4, c: 2 - square )
    let se = 4 * base * base + 4 * base + 2
    
    if square == se { return Point2D( x: base + 1, y: -base ) }
    
    let n = base + 1
    let ne = 4 * n * n - 2 * n + 1
    
    if square == ne { return Point2D( x: n, y: n ) }
    if square < ne { return Point2D( x: n, y: square - se - base ) }
    
    let nw = 4 * n * n + 1
    
    if square == nw { return Point2D( x: -n, y: n ) }
    if square < nw { return Point2D( x: n - square + ne, y: n )}
    
    let sw = 4 * n * n + 2 * n + 1
    
    if square == sw { return Point2D( x: -n, y: -n ) }
    if square < sw { return Point2D( x: -n, y: n - square + nw ) }
    
    return Point2D( x: -n + square - sw, y: -n )
}


func fillUntil( value: Int ) -> Int {
    var grid = [ Point2D( x: 0, y: 0 ) : Square( label: 1, position: Point2D( x: 0, y: 0), value: 1 ) ]
    
    for n in 2 ..< Int.max {
        let position = coords( square: n )
        let sum = Direction8.allCases.reduce( 0 ) {
            let next = position.move( direction: $1 )
            
            return $0 + ( grid[next] == nil ? 0 : grid[next]!.value )
        }
        
        if sum > value { return sum }
        
        grid[position] = Square( label: n, position: position, value: sum )
    }
    
    return Int.max
}



func parse( input: AOCinput ) -> Int {
    return Int( input.line )!
}


func part1( input: AOCinput ) -> String {
    let position = coords( square: parse( input: input ) )
    return "\(abs( position.x ) + abs( position.y ))"
}


func part2( input: AOCinput ) -> String {
    return "\(fillUntil( value: parse( input: input ) ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
