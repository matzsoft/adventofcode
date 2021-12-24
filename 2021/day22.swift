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
    let rects: [Rect3D]
    
    var volume: Int { rects.reduce( 0 ) { $0 + $1.volume } }
    
    init() {
        rects = []
    }

    init( rects: [Rect3D] ) {
        self.rects = rects
    }
    
    func add( rect: Rect3D ) -> Region3D {
        if rects.isEmpty { return Region3D( rects: [ rect ] ) }
//        let residual = rects.reduce( Region3D( rects: [ rect ] ) ) { $0.subtract( rect: $1 ) }
        var residual = Region3D( rects: [ rect ] )
        for oldRect in rects {
            residual = residual.subtract( rect: oldRect )
            if residual.rects.isEmpty {
                return self
            }
        }
        return Region3D( rects: rects + residual.rects )
    }

    func subtract( rect: Rect3D ) -> Region3D {
        return Region3D( rects: rects.flatMap { rect.subtract( from: $0 ) } )
    }
}

extension Rect3D {
    func add( to: Rect3D ) -> [Rect3D] {
        guard let intersection = self.intersection( with: to ) else { return [ to, self ] }
        
//        let sorted = [ self, to ].sorted( by: { $0.volume > $1.volume } )
//
//        return [ sorted[0] ] + intersection.subtract( from: sorted[1] )
        return [ to ] + intersection.subtract( from: self )
    }
    
    func subtract( from: Rect3D ) -> [Rect3D] {
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
        
//        let chopped = choppers.map { $0.intersection( with: from ) }
        var chopped = [Rect3D?]()
        for chopper in choppers {
            let result = chopper.intersection( with: from )
            chopped.append( result )
        }
        return choppers.compactMap { $0.intersection( with: from ) }
    }
}


func parse( input: AOCinput ) -> [Cuboid] {
    return input.lines.map { Cuboid( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let steps = parse( input: input )
    let valid = steps.filter {
        validZone.contains( point: $0.cube.min ) && validZone.contains( point: $0.cube.max )
    }
    let onCubes = valid.reduce( into: Set<Point3D>() ) {
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
//    let onRegion = steps.reduce( Region3D() ) {
//        if $1.action == .on {
//            return $0.add( rect: $1.cube )
//        } else {
//            return $0.subtract( rect: $1.cube )
//        }
//    }
    var onRegion = Region3D()
    for step in steps {
        switch step.action {
        case .on:
            let region = onRegion.add( rect: step.cube )
            onRegion = region
        case .off:
            let region = onRegion.subtract( rect: step.cube )
            onRegion = region
        }
    }
    
    return "\( onRegion.volume )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
