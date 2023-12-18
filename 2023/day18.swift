//
//         FILE: day18.swift
//  DESCRIPTION: Advent of Code 2023 Day 18: Lavaduct Lagoon
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/23 21:00:00
//

import Foundation
import Library
import CoreGraphics


struct Instruction {
    let direction: DirectionUDLR
    let distance: Int
    
    init( line: String, expanded: Bool = false ) {
        let words = line.split( whereSeparator: { " (#)".contains( $0 ) } ).map { String( $0 ) }
        
        if !expanded {
            direction = DirectionUDLR( rawValue: words[0] )!
            distance = Int( words[1] )!
        } else {
            switch words[2].last {
            case "0":
                direction = .right
            case "1":
                direction = .down
            case "2":
                direction = .left
            case "3":
                direction = .up
            default:
                fatalError( "\(words[2]) has invalid direction." )
            }
            distance = Int( words[2].prefix( 5 ), radix: 16 )!
        }
    }
}


struct Trench {
    var points: Array<Point2D> = []
    
    init( start: Point2D ) {
        points = [ start ]
    }
    
    mutating func dig( instruction: Instruction ) -> Void {
        guard let last = points.last else { return }
        points.append( last + instruction.distance * instruction.direction.vector )
//        if points.isEmpty { return }
//        for _ in 1 ... instruction.distance {
//            let next = points.last! + instruction.direction.vector
//            points.append( next )
//        }
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let instructions = input.lines.map { Instruction( line: $0 ) }
    var trench = Trench(start: Point2D( x: 0, y: 0 ) )
    
    instructions.forEach { trench.dig( instruction: $0 ) }
    
    let bounds = Rect2D( points: trench.points )
    let polygon = trench.points.map { CGPoint( x: $0.x, y: $0.y ) }
    
    let context = CGContext(
        data: nil, width: bounds.width, height: bounds.height,
        bitsPerComponent: 8, bytesPerRow: 4 * bounds.width,
        space: CGColorSpace( name: CGColorSpace.genericRGBLinear )!,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    )!
    context.beginPath()
    context.addLines( between: polygon )
//    context.addLine( to: polygon[0] )
    context.closePath()
    
    let points = bounds.points
        .map { CGPoint( x: $0.x, y: $0.y ) }
        .filter { context.path!.contains( $0 ) }
    return "\( points.count )"
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
