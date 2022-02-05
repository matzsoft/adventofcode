//
//         FILE: main.swift
//  DESCRIPTION: day05 - Hydrothermal Venture
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/04/21 21:00:10
//

import Foundation

struct Line {
    let start: Point2D
    let end: Point2D
    
    var isHorizontal: Bool { start.y == end.y }
    var isVertical: Bool { start.x == end.x }
    var points: Set<Point2D> {
        let vector = Point2D( x: ( end.x - start.x ).signum(), y: ( end.y - start.y ).signum() )
        var point = start
        var set = Set( [ start ] )
        
        while point != end {
            point = point + vector
            set.insert( point )
        }
        return set
    }
    
    init( line: String ) {
        let words = line.split( whereSeparator: { ", ->".contains( $0 ) } )

        start = Point2D( x: Int( words[0] )!, y: Int( words[1] )! )
        end = Point2D( x: Int( words[2] )!, y: Int( words[3] )! )
    }
}


func parse( input: AOCinput ) -> [Line] {
    return input.lines.map { Line( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let lines = parse( input: input )
    let histogram = lines.reduce( into: [ Point2D : Int ]() ) {
        if $1.isHorizontal || $1.isVertical {
            for point in $1.points {
                $0[ point, default: 0 ] += 1
            }
        }
    }
    return "\( histogram.filter( { $0.value > 1 } ).count )"
}


func part2( input: AOCinput ) -> String {
    let lines = parse( input: input )
    let histogram = lines.reduce( into: [ Point2D : Int ]() ) {
        for point in $1.points {
            $0[ point, default: 0 ] += 1
        }
    }
    return "\( histogram.filter( { $0.value > 1 } ).count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
