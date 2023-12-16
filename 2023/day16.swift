//
//         FILE: day16.swift
//  DESCRIPTION: Advent of Code 2023 Day 16: The Floor Will Be Lava
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/15/23 21:00:01
//

import Foundation
import Library

enum Tile: Character {
    case empty = ".", vsplit = "|", hsplit = "-", fmirror = "/", bmirror = "\\"
    
    func action( beam: Beam ) -> [Beam] {
        switch self {
        case .empty:
            return [ beam.move ]
        case .vsplit:
            if beam.direction == .right || beam.direction == .left {
                return [ beam.turn( direction: .left ), beam.turn( direction: .right ) ]
            }
            return [ beam.move ]
        case .hsplit:
            if beam.direction == .up || beam.direction == .down {
                return [ beam.turn( direction: .left ), beam.turn( direction: .right ) ]
            }
            return [ beam.move ]
        case .fmirror:
            if beam.direction == .right || beam.direction == .left {
                return [ beam.turn( direction: .left ) ]
            }
            return [ beam.turn( direction: .right ) ]
        case .bmirror:
            if beam.direction == .right || beam.direction == .left {
                return [ beam.turn( direction: .right ) ]
            }
            return [ beam.turn( direction: .left ) ]
        }
    }
    
    func description( seen: Bool ) -> Character {
        guard seen else { return rawValue }
        switch self {
        case .empty:
            return "*"
        case .vsplit:
            return "⇅"
        case .hsplit:
            return "⇄"
        case .fmirror:
            return "⍁"
        case .bmirror:
            return "⍂"
        }
    }
}

struct Beam: Hashable {
    let position: Point2D
    let direction: DirectionUDLR
    
    var move: Beam { Beam( position: position + direction.vector, direction: direction ) }
    
    func turn( direction: Turn ) -> Beam {
        Beam( position: position, direction: self.direction.turn( direction ) ).move
    }
}

struct Grid {
    let layout: [[Tile]]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        layout = lines.reduce( into: [[Tile]]() ) { layout, line in
            layout.append( Array( line ).map { Tile( rawValue: $0 )! } )
        }
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: layout[0].count, height: layout.count )!
    }
    
    subscript( point: Point2D ) -> Tile {
        layout[point.y][point.x]
    }
    
    func energized( start: Beam ) -> Int {
        var queue = [ start ]
        var seen = Set<Beam>()
        
        while !queue.isEmpty {
            let beam = queue.removeFirst()

            if bounds.contains( point: beam.position ) {
                if seen.insert( beam ).inserted {
                    queue.append( contentsOf: self[ beam.position ].action( beam: beam ) )
                }
            }
        }
        
    //    print( description( seen: seen ) )
        return Set( seen.map { $0.position } ).count
    }

    func description( seen: Set<Beam> ) -> String {
        layout.indices.map { y in
            String(
                layout[y].indices.map { x in
                    let seen = seen.contains( where: { $0.position == Point2D( x: x, y: y ) } )
                    return layout[y][x].description( seen: seen )
                }
            )
        }.joined( separator: "\n" )
    }
}


func part1( input: AOCinput ) -> String {
    let start = Beam( position: Point2D( x: 0, y: 0 ), direction: .right )
    
    return "\( Grid( lines: input.lines ).energized( start: start ) )"
}


func part2( input: AOCinput ) -> String {
    let grid = Grid( lines: input.lines )
    let beams =
        ( grid.bounds.min.x ... grid.bounds.max.x ).flatMap {
            [
                Beam( position: Point2D( x: $0, y: grid.bounds.min.y ), direction: .down),
                Beam( position: Point2D( x: $0, y: grid.bounds.max.y ), direction: .up )
            ]
        }
        +
        ( grid.bounds.min.y ... grid.bounds.max.y ).flatMap {
            [
                Beam( position: Point2D( x: grid.bounds.min.x, y: $0 ), direction: .right),
                Beam( position: Point2D( x: grid.bounds.max.x, y: $0 ), direction: .left )
            ]
        }
    let values = beams.map { grid.energized( start: $0 ) }
    return "\( values.max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
