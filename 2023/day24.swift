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
    
    func intersection( _ other: Hail ) -> ( Double, Double ) {
        let denom = other.m - m
        let x = ( b - other.b ) / denom
//        let y = ( m * other.b - other.m * b ) / denom
        let y = ( other.m * b - m * other.b ) / denom
        return ( x, y )
    }
    
    func isFuture( _ other: Hail ) -> Bool {
        let intersect = intersection( other )
        
        if m == other.m { return false }
        if velocity.x > 0 && intersect.0 < Double( position.x ) { return false }
        if velocity.x < 0 && intersect.0 > Double( position.x ) { return false }

        if velocity.y > 0 && intersect.1 < Double( position.y ) { return false }
        if velocity.y < 0 && intersect.1 > Double( position.y ) { return false }
        
        if other.velocity.x > 0 && intersect.0 < Double( other.position.x ) { return false }
        if other.velocity.x < 0 && intersect.0 > Double( other.position.x ) { return false }

        if other.velocity.y > 0 && intersect.1 < Double( other.position.y ) { return false }
        if other.velocity.y < 0 && intersect.1 > Double( other.position.y ) { return false }
        
        return true
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
            if !hail[index1].isFuture( hail[index2] ) {
                //print( "\( hail[index1].position ) and \( hail[index2].position ) not in the future." )
            } else {
                let intersect = hail[index1].intersection( hail[index2] )
                let formated = ( String( format: "%.3f", intersect.0 ), String( format: "%.3f", intersect.1 ) )
                //print( "\( hail[index1].position ) and \( hail[index2].position ) intersect at \(formated)" )

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
