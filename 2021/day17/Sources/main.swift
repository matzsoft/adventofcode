//
//         FILE: main.swift
//  DESCRIPTION: day17 - Trick Shot
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/21 12:12:15
//

import Foundation
import Library


func parse( input: AOCinput ) -> Rect2D {
    let words = input.line.split( whereSeparator: { " =.,".contains( $0 ) } )
    let min = Point2D(x: Int( words[3] )!, y: Int( words[6] )! )
    let max = Point2D(x: Int( words[4] )!, y: Int( words[7] )! )

    return Rect2D( min: min, max: max )
}


func part1( input: AOCinput ) -> String {
    let target = parse( input: input )
    let yMax = -target.min.y - 1
    
    return "\( yMax * ( yMax + 1 ) / 2)"
}


func isHit( target: Rect2D, velocity: Point2D ) -> Bool {
    let tMin = ( 1 ... velocity.x ).first { velocity.x * $0 - $0 * ( $0 - 1 ) / 2 >= target.min.x }!
    if velocity.x * tMin - tMin * ( tMin - 1 ) / 2 > target.max.x { return false }
    let tentative = ( tMin ... Int.max ).first {
        $0 == velocity.x || velocity.x * ( $0 + 1 ) - $0 * ( $0 + 1 ) / 2 > target.max.x
    }!
    let tMax = tentative < velocity.x ? tentative : ( tentative ... Int.max ).first {
        velocity.y * $0 - $0 * ( $0 - 1 ) / 2 <= target.min.y
    }!
    
    for t in tMin ... tMax {
        let y = velocity.y * t - t * ( t - 1 ) / 2
        
        if target.min.y <= y && y <= target.max.y {
            return true
        }
    }
    
    return false
}


func part2( input: AOCinput ) -> String {
    let target = parse( input: input )
    let xMin = ( 1 ... Int.max ).first( where: { $0 * ( $0 + 1 ) / 2 >= target.min.x } )!
    let xMax = target.max.x
    let yMin = target.min.y
    let yMax = -target.min.y - 1
    var count = 0

    for x in xMin ... xMax {
        for y in ( yMin ... yMax ) {
            let vector = Point2D( x: x, y: y )
            if isHit( target: target, velocity: vector ) {
                count += 1
//                print( vector )
            }
        }
    }
    return "\(count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
