//
//         FILE: day22.swift
//  DESCRIPTION: Advent of Code 2023 Day 22: Sand Slabs
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/21/23 21:00:03
//

import Foundation
import Library

struct Brick {
    var bounds: Rect3D
    var supportedBy: Set<Int>
    var supports: Set<Int>
    
    init( bounds: Rect3D, supportedBy: Set<Int> = [], supports: Set<Int> = [] ) {
        self.bounds = bounds
        self.supportedBy = supportedBy
        self.supports = supports
    }
    
    init( line: String ) {
        let coords = line.split( whereSeparator: { ",~".contains( $0 ) } ).map { Int( $0 )! }
        
        bounds = Rect3D(
            min: Point3D( x: coords[0], y: coords[1], z: coords[2] ),
            max: Point3D( x: coords[3], y: coords[4], z: coords[5] )
        )
        supportedBy = []
        supports = []
    }
    
    var projection: Rect3D {
        Rect3D(
            min: Point3D( x: bounds.min.x, y: bounds.min.y, z: 1 ),
            max: bounds.max + Point3D( x: 0, y: 0, z: -1 )
        )
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var bricks  = input.lines.map { Brick( line: $0 ) }.sorted { $0.bounds.min.z < $1.bounds.min.z }

    for ( index, brick ) in bricks.enumerated() {
        let projection = brick.projection
        let candidates =  bricks[..<index].sorted { $0.bounds.max.z > $1.bounds.max.z }
        guard let candidate = candidates.first( where: { $0.bounds.intersection( with: projection) != nil } )
        else {
            bricks[index] = Brick( bounds: Rect3D(
                min: brick.bounds.min + Point3D( x: 0, y: 0, z: -brick.bounds.min.z + 1 ),
                max: brick.bounds.max + Point3D( x: 0, y: 0, z: -brick.bounds.min.z + 1 )
            ) )
            continue
        }
        let supportedBy = bricks[..<index].indices
            .filter {
                bricks[$0].bounds.max.z == candidate.bounds.max.z &&
                bricks[$0].bounds.intersection( with: projection) != nil
            }
        
        for support in supportedBy { bricks[support].supports.insert( index ) }
        let vector = Point3D( x: 0, y: 0, z: brick.bounds.min.z - candidate.bounds.max.z - 1 )
        bricks[index] = Brick(
            bounds: Rect3D( min: brick.bounds.min - vector, max: brick.bounds.max - vector ),
            supportedBy: Set( supportedBy )
        )
    }
    
//    for ( index, brick ) in bricks.enumerated() {
//        let front = "\(index): \(brick.bounds.min) ~ \(brick.bounds.max), "
//        let back = "supportedBy \(brick.supportedBy), supports \(brick.supports)"
//        print( front + back )
//    }
    
    let dork = bricks.filter { $0.supportedBy.count == 1 }
    let wank = Set( bricks.indices ).subtracting( dork.flatMap { $0.supportedBy } )
    let disposable = bricks.filter {
        let above = $0.supports.filter { bricks[$0].supportedBy.count == 1 }
        return above.isEmpty
    }
    
    return "\( disposable.count )"
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
