//
//         FILE: main.swift
//  DESCRIPTION: day03 - No Matter How You Slice It
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/26/21 18:44:28
//

import Foundation

func findOverlaps( rectangles: [Rect2D] ) -> [Rect2D] {
    return ( 0 ..< rectangles.count - 1 ).flatMap { i in
        ( i + 1 ..< rectangles.count ).compactMap { rectangles[i].intersection( with: rectangles[$0] ) }
    }
}

func consolidate( rectangles: [Rect2D] ) -> [Rect2D] {
    var consolidated = [Rect2D]()
    
    for rectangle in rectangles {
        var newList: [Rect2D] = [ rectangle ]
        
        for exists in consolidated {
            guard let trial = exists.intersection( with: rectangle ) else {
                newList.append( exists )
                continue
            }
            
            let leftW = trial.min.x - exists.min.x
            if let left = Rect2D( min: exists.min, width: leftW, height: exists.height ) {
                newList.append(left)
            }
            
            let topMin = Point2D( x: trial.min.x, y: exists.min.y )
            let topW = exists.max.x - trial.min.x
            if let top = Rect2D( min: topMin, width: topW, height: trial.min.y - exists.min.y ) {
                newList.append(top)
            }
            
            let bottomMin = Point2D( x: trial.min.x, y: trial.max.y )
            let bottomW = exists.max.x - trial.min.x
            if let bottom = Rect2D( min: bottomMin, width: bottomW, height: exists.max.y - trial.max.y ) {
                newList.append(bottom)
            }

            let rightMin = Point2D( x: trial.max.x, y: trial.min.y )
            if let right = Rect2D( min: rightMin, width: exists.max.x - trial.max.x, height: trial.height ) {
                newList.append(right)
            }
        }
        
        consolidated = newList
    }
    
    return consolidated
}

func countOverlaps( claims: [ Int : Rect2D ] ) -> [ Int : Int ] {
    let keys = claims.keys.map { Int( $0 ) }
    
    return ( 0 ..< keys.count - 1 ).reduce( into: [ Int : Int ]() ) { dict, i in
        ( i + 1 ..< keys.count ).forEach { j in
            if claims[keys[i]]?.intersection( with: claims[keys[j]]! ) != nil {
                dict[keys[i]] = ( dict[keys[i]] ?? 0 ) + 1
                dict[keys[j]] = ( dict[keys[j]] ?? 0 ) + 1
            }
        }
    }
}


func parse( input: AOCinput ) -> [ Int : Rect2D ] {
    return Dictionary( uniqueKeysWithValues: input.lines.map {
        let words = $0.split( whereSeparator: { "# @,:x".contains( $0 ) } ).map { Int($0)! }
        return (
            words[0],
            Rect2D( min: Point2D( x: words[1], y: words[2] ), width: words[3], height: words[4] )!
        )
    } )
}


func part1( input: AOCinput ) -> String {
    let claims = parse( input: input )
    let overlaps = findOverlaps( rectangles: Array<Rect2D>( claims.values ) )
    let consolidated = consolidate( rectangles: overlaps )
    return "\(consolidated.reduce( 0 ) { $0 + $1.area })"
}


func part2( input: AOCinput ) -> String {
    let claims = parse( input: input )
    let overlapCounts = countOverlaps( claims: claims )
    let result = claims.keys.first { overlapCounts[$0] == nil }!

    return "\(result)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
