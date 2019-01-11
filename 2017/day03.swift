//
//  main.swift
//  day03
//
//  Created by Mark Johnson on 1/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let test1 = 1
let test2 = 12
let test3 = 23
let test4 = 1024
let input = 289326

enum Direction: String, CaseIterable {
    case N, NE, E, SE, S, SW, W, NW
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    static func +( left: Point, right: Point ) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func ==( left: Point, right: Point ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    func move( direction: Direction ) -> Point {
        switch direction {
        case .N:
            return self + Point(x: 0, y: 1)
        case .NE:
            return self + Point(x: 1, y: 1)
        case .E:
            return self + Point(x: 1, y: 0)
        case .SE:
            return self + Point(x: 1, y: -1)
        case .S:
            return self + Point(x: 0, y: -1)
        case .SW:
            return self + Point(x: -1, y: -1)
        case .W:
            return self + Point(x: -1, y: 0)
        case .NW:
            return self + Point(x: -1, y: 1)
        }
    }
}

struct Square {
    let label: Int
    let position: Point
    let value: Int
}


func quadratic( b: Int, c: Int ) -> Int {
    let square = b * b - 16 * c
    
    guard square >= 0 else { print( "Imaginary solution") ; exit(1) }

    let root = sqrt( Double( square ) )
    let solution1 = ( Double( -b ) + root ) / 8
    let solution2 = ( Double( -b ) - root ) / 8
    
    guard solution2 <= 0 else { print( "Two solutions" ); exit(1) }
    guard solution1 >= 0 else { print( "No solutions" ); exit(1) }
    
    return Int( solution1 )
}

func coords( square: Int ) -> Point {
    guard square > 1 else { return Point( x: 0, y: 0 ) }
    
    let base = quadratic( b: 4, c: 2 - square )
    let se = 4 * base * base + 4 * base + 2
    
    if square == se { return Point( x: base + 1, y: -base ) }
    
    let n = base + 1
    let ne = 4 * n * n - 2 * n + 1
    
    if square == ne { return Point( x: n, y: n ) }
    if square < ne { return Point( x: n, y: square - se - base ) }
    
    let nw = 4 * n * n + 1
    
    if square == nw { return Point( x: -n, y: n ) }
    if square < nw { return Point( x: n - square + ne, y: n )}
    
    let sw = 4 * n * n + 2 * n + 1
    
    if square == sw { return Point( x: -n, y: -n ) }
    if square < sw { return Point( x: -n, y: n - square + nw ) }
    
    return Point( x: -n + square - sw, y: -n )
}

func fillUntil( value: Int ) -> Int {
    var grid = [ Point( x: 0, y: 0 ) : Square( label: 1, position: Point(x: 0, y: 0), value: 1 ) ]
    
    for n in 2 ..< Int.max {
        let position = coords(square: n)
        var sum = 0
        
        for direction in Direction.allCases {
            let next = position.move(direction: direction)
            
            if let other = grid[next] {
                sum += other.value
            }
        }
        
        if sum > value {
            return sum
        }
        
        grid[position] = Square(label: n, position: position, value: sum)
    }
    
    return Int.max
}

let position = coords( square: input )

print( "Part1:", abs(position.x) + abs(position.y) )
print( "Part2:", fillUntil(value: input) )
