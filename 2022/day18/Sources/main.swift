//
//         FILE: main.swift
//  DESCRIPTION: day18 - Boiling Boulders
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/18/22 00:14:55
//

import Foundation
import Library

enum Direction3D: CaseIterable {
    case north, south, east, west, up, down
    
    var vector: Point3D {
        switch self {
        case .north:
            return Point3D( x: 0, y: 1, z: 0 )
        case .south:
            return Point3D( x: 0, y: -1, z: 0 )
        case .east:
            return Point3D( x: 1, y: 0, z: 0 )
        case .west:
            return Point3D( x: -1, y: 0, z: 0 )
        case .up:
            return Point3D( x: 0, y: 0, z: 1 )
        case .down:
            return Point3D( x: 0, y: 0, z: -1 )
        }
    }
}


func parse( input: AOCinput ) -> Set<Point3D> {
    return Set( input.lines.map {
        let coords = $0.split( separator: "," ).map { Int( $0 )! }
        return Point3D( x: coords[0], y: coords[1], z: coords[2] )
    } )
}


func part1( input: AOCinput ) -> String {
    let cubes = parse( input: input )
    let count = cubes.reduce( 6 * cubes.count ) { count, cube in
        let connected = Direction3D.allCases.map { cube + $0.vector }.filter { cubes.contains( $0 ) }
        return count - connected.count
    }
    return "\(count)"
}


struct Map {
    enum cubeType { case lava, outside, unknown }

    let bounds: Rect3D
    var map: [[[cubeType]]]
    
    init( lava: Set<Point3D> ) {
        bounds = Rect3D( points: Array( lava ) ).pad( by: 1 )
        map = Array( repeating: Array( repeating: Array(
            repeating: cubeType.unknown, count: bounds.height ), count: bounds.length ), count: bounds.width
        )
        lava.forEach { self[$0] = .lava }
        self[ bounds.min ] = .outside
        
        var queue = [ bounds.min ]

        while !queue.isEmpty {
            let cube = queue.removeFirst()
            
            Direction3D.allCases
                .map { cube + $0.vector }
                .filter { bounds.contains( point: $0 ) && self[$0] == .unknown }
                .forEach { self[$0] = .outside; queue.append( $0 ) }
        }
    }
    
    subscript( point: Point3D ) -> cubeType {
        get {
            map[ point.x - bounds.min.x ][ point.y - bounds.min.y ][ point.z - bounds.min.z ]
        }
        set {
            map[ point.x - bounds.min.x ][ point.y - bounds.min.y ][ point.z - bounds.min.z ] = newValue
        }
    }
    
    var outside: Set<Point3D> {
        return ( bounds.min.x ... bounds.max.x ).reduce( into: Set<Point3D>() ) { set, x in
            ( bounds.min.y ... bounds.max.y ).forEach { y in
                ( bounds.min.z ... bounds.max.z ).forEach { z in
                    let cube = Point3D( x: x, y: y, z: z )
                    if self[cube] == .outside { set.insert( cube ) }
                }
            }
        }
    }
}


func part2( input: AOCinput ) -> String {
    let cubes = parse( input: input )
    let count = cubes.reduce( 6 * cubes.count ) { count, cube in
        let connected = Direction3D.allCases.map { cube + $0.vector }.filter { cubes.contains( $0 ) }
        return count - connected.count
    }
    let candidates = Set( cubes.flatMap { cube in
        Direction3D.allCases.map { cube + $0.vector }.filter { !cubes.contains( $0 ) }
    } )
    let map = Map( lava: cubes )
    let internals = candidates.subtracting( map.outside )
    let revisedCount = internals.reduce( count ) { count, cube in
        let mCount = Direction3D.allCases.map { cube + $0.vector }.filter { cubes.contains( $0 ) }
        return count - mCount.count
    }
    return "\(revisedCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
