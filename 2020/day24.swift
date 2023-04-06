//
//         FILE: main.swift
//  DESCRIPTION: day24 - Lobby Layout
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/01/21 13:38:00
//

import Foundation
import Library

func identify( line: String ) -> Point2D {
    var destination = Point2D( x: 0, y: 0 )
    var last: Character?
    
    for character in line {
        if let previous = last {
            let direction = Direction6alt( rawValue: String( previous ) + String( character ) )!
            destination = destination + direction.vector
            last = nil
        } else if let direction = Direction6alt( rawValue: String( character ) ) {
            destination = destination + direction.vector
            last = nil
        } else {
            last = character
        }
    }
    
    return destination
}


func countNeighbors( blacks: Set<Point2D>, position: Point2D ) -> Int {
    return Direction6alt.allCases.filter { blacks.contains( position + $0.vector ) }.count
}


func findWhites( blacks: Set<Point2D> ) -> [Point2D] {
    let bounds = Rect2D( points: Array( blacks ) ).pad( byMinX: 2, byMaxX: 2, byMinY: 1, byMaxY: 1 )
    
    return ( bounds.min.x ... bounds.max.x ).flatMap { x in
        ( bounds.min.y ... bounds.max.y ).compactMap{ y in
            let tile = Point2D( x: x, y: y )

            return blacks.contains( tile ) ? nil : tile
        }
    }
}


func parse( input: AOCinput ) -> Set<Point2D> {
    let visited = input.lines.map { identify( line: $0 ) }
    var blacks = Set<Point2D>()
    
    for tile in visited {
        if !blacks.insert( tile ).inserted {
            blacks.remove( tile )
        }
    }
    
    return blacks
}


func part1( input: AOCinput ) -> String {
    let blacks = parse( input: input )
    return "\( blacks.count )"
}


func part2( input: AOCinput ) -> String {
    var blacks = parse( input: input )
    
    for _ in 1 ... 100 {
        var nextDay = blacks
        
        for tile in blacks {
            let neighbors = countNeighbors( blacks: blacks, position: tile )
            
            if neighbors == 0 || neighbors > 2 { nextDay.remove( tile ) }
        }
        
        for tile in findWhites( blacks: blacks ) {
            let neighbors = countNeighbors( blacks: blacks, position: tile )
            
            if neighbors == 2 { nextDay.insert( tile ) }
        }
        blacks = nextDay
    }
    
    return "\( blacks.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
