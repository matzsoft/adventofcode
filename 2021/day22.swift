//
//         FILE: main.swift
//  DESCRIPTION: day22 - Reactor Reboot
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/21/21 21:00:10
//

import Foundation

let validZone = Rect3D(
    points: [ Point3D( x: -50, y: -50, z: -50 ), Point3D( x: 50, y: 50, z: 50 ) ] )

struct Cuboid {
    enum Action: String { case on, off }
    
    let action: Action
    let cube: Rect3D
    
    init( line: String ) {
        let words = line.split( whereSeparator: { " =.,".contains( $0 ) } )
        let values = [ 2, 3, 5, 6, 8, 9 ].map { Int( words[$0] )! }
        
        action = Action( rawValue: String( words[0] ) )!
        cube = Rect3D(
            min: Point3D( x: values[0], y: values[2], z: values[4] ),
            max: Point3D( x: values[1], y: values[3], z: values[5] )
        )
    }
}

struct Region3D {
    var rects: [Rect3D]
    
    var volume: Int { rects.reduce( 0 ) { $0 + $1.volume } }
    
    init( rects: [Rect3D] ) {
        self.rects = rects
    }
    
    mutating func add( rect: Rect3D ) -> Void {
        subtract( rect: rect )
        rects.append( rect )
    }

    mutating func subtract( rect: Rect3D ) -> Void {
        rects = rects.flatMap { rect.subtract( from: $0 ) }
    }
}

extension Rect3D {
    func subtract( from: Rect3D ) -> [Rect3D] {
        if intersection( with: from ) == nil { return [ from ] }
        let choppers = [
            Rect3D(
                min: Point3D( x: Int.min, y: Int.min, z: Int.min ),
                max: Point3D( x: Int.max, y: Int.max, z: min.z - 1 )
            ),
            Rect3D(
                min: Point3D( x: Int.min, y: Int.min, z: max.z + 1 ),
                max: Point3D( x: Int.max, y: Int.max, z: Int.max )
            ),
            Rect3D(
                min: Point3D( x: Int.min,   y: Int.min, z: min.z ),
                max: Point3D( x: min.x - 1, y: Int.max, z: max.z )
            ),
            Rect3D(
                min: Point3D( x: max.x + 1, y: Int.min, z: min.z ),
                max: Point3D( x: Int.max,   y: Int.max, z: max.z )
            ),
            Rect3D(
                min: Point3D( x: min.x, y: Int.min,   z: min.z ),
                max: Point3D( x: max.x, y: min.y - 1, z: max.z )
            ),
            Rect3D(
                min: Point3D( x: min.x, y: max.y + 1, z: min.z ),
                max: Point3D( x: max.x, y: Int.max,   z: max.z )
            ),
        ]

        return choppers.compactMap { $0.intersection( with: from ) }
    }
}


func parse( input: AOCinput ) -> [Cuboid] {
    return input.lines.map { Cuboid( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let steps = parse( input: input ).filter {
        validZone.contains( point: $0.cube.min ) && validZone.contains( point: $0.cube.max )
    }
    let onCubes = steps.reduce( into: Set<Point3D>() ) {
        if $1.action == .on {
            $0.formUnion( $1.cube.points )
        } else {
            $0.subtract( $1.cube.points )
        }
    }
    
    return "\( onCubes.count )"
}


func part2( input: AOCinput ) -> String {
    let steps = parse( input: input )
    let onRegion = steps.reduce( into: Region3D( rects: [] ) ) {
        switch $1.action {
        case .on:
            $0.add( rect: $1.cube )
        case .off:
            $0.subtract( rect: $1.cube )
        }
    }
    
    return "\( onRegion.volume )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
