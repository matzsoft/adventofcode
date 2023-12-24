//
//         FILE: day24.swift
//  DESCRIPTION: Advent of Code 2023 Day 24: Never Tell Me The Odds
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/23/23 21:08:49
//

import Foundation
import Library

struct Hail {
    let position: Point3D
    let velocity: Point3D
    let m: Double
    let b: Double
    
    init( line: String ) {
        let numbers = line.split( whereSeparator: { ", @".contains( $0 ) } ).map { Int( $0 )! }
        position = Point3D( x: numbers[0], y: numbers[1], z: numbers[2] )
        velocity = Point3D( x: numbers[3], y: numbers[4], z: numbers[5] )
        m = Double( velocity.y ) / Double( velocity.x )
        b = Double( position.y ) - m * Double( position.x )
    }

    // For some reason
    //        let y = ( m * other.b - other.m * b ) / denom
    // gave the wrong sign for y.
    func intersection( _ other: Hail ) -> ( Double, Double ) {
        let denom = other.m - m
        let x = ( b - other.b ) / denom
        let y = ( other.m * b - m * other.b ) / denom
        return ( x, y )
    }
    
    func time( for position: ( Double, Double ) ) -> Double {
        if velocity.x != 0 { return ( position.0 - Double( self.position.x ) ) / Double( velocity.x ) }
        return ( position.1 - Double( self.position.y ) ) / Double( velocity.y )
    }
                                                                    
    func futureIntersect( _ other: Hail ) -> ( Double, Double )? {
        guard m != other.m else { return nil }
        let intersect = intersection( other )
        
        if time( for: intersect ) < 0 { return nil }
        if other.time( for: intersect ) < 0 { return nil }
        
        return intersect
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}

// > 15052
func part1( input: AOCinput ) -> String {
    let hail = input.lines.map { Hail( line: $0 ) }
    let range = Double( input.extras[0] )! ... Double( input.extras[1] )!
    var count = 0
    
    for index1 in 0 ..< hail.count - 1 {
        for index2 in index1 + 1 ..< hail.count {
            if let intersect = hail[index1].futureIntersect( hail[index2] ) {
                if range.contains( intersect.0 ) && range.contains( intersect.1 ) {
                    count += 1
                }
            }
        }
    }
    return "\(count)"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
