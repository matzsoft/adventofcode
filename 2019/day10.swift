//
//         FILE: main.swift
//  DESCRIPTION: day10 - Monitoring Station
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/01/21 19:28:21
//

import Foundation
import Library

extension Point2D {
    var slope: Point2D {
        let factor = abs( gcd( x, y ) )
        
        return Point2D( x: x / factor, y: y / factor )
    }
    
    var tangent: Double {
        guard x != 0 else { return y < 0 ? -Double.infinity : Double.infinity }
        return Double( y ) / Double( x )
    }
}


struct Map {
    let asteroids: Set<Point2D>
    
    init( lines: [String] ) {
        let map = lines.map { Array( $0 ) }
        self.asteroids = ( 0 ..< map.count ).reduce( into: Set<Point2D>() ) { set, y in
            ( 0 ..< map[y].count ).forEach { x in
                if map[y][x] == "#" { set.insert( Point2D( x: x, y: y ) ) }
            }
        }
    }
    
    func groupAsteroids( location: Point2D ) -> [ Point2D : [Int] ] {
        return asteroids.subtracting( [ location ] ).reduce( into: [ Point2D : [Int] ]() ) { dict, target in
            let vector = target - location
            let slope = vector.slope
            let distance = vector.magnitude / slope.magnitude

            if dict[slope] == nil { dict[slope] = [ distance ] }
            else { dict[slope]?.append( distance ) }
        }
    }
    
    var maxVisible: Int {
        return asteroids.map { groupAsteroids( location: $0 ).count }.max()!
    }
    
    func vaporizationOrder() -> [Point2D] {
        let station = asteroids.map { ( $0, groupAsteroids( location: $0 ).count ) }.max { $0.1 < $1.1 }!.0
        let groups = groupAsteroids( location: station ).map { ( $0.key, $0.value.sorted() ) }.sorted {
            // Anything to the right of the x axis is before anything to the left.
            if $0.0.x.signum() > $1.0.x.signum() { return true }
            if $1.0.x.signum() > $0.0.x.signum() { return false }

            // Otherwise sort by increasing tangent
            return $0.0.tangent < $1.0.tangent
        }

        var pass = 0
        var list = [Point2D]()
        
        while list.count < asteroids.count - 1 {
            for group in groups {
                if group.1.count > pass {
                    list.append( station + group.1[pass] * group.0 )
                }
            }
            pass += 1
        }
        
        return list
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    return "\(map.maxVisible)"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let vaporizations = map.vaporizationOrder()
    let target = vaporizations[199]
    
    return "\(target.x * 100 + target.y)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
