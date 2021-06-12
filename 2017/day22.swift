//
//         FILE: main.swift
//  DESCRIPTION: day22 - Sporifica Virus
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/24/21 14:14:13
//

import Foundation

class Grid {
    enum State: String { case clean = ".", weakened = "W", infected = "#", flagged = "F" }

    static let gridMax = 5001
    
    var grid:       [[State]]
    let offset:     Point2D
    var current:    Point2D
    var points:     DirectionUDLR
    var range:      Rect2D
    var infections: Int

    init( lines: [String] ) {
        let initial = lines.map { $0.map { $0 == "." ? State.clean : State.infected } }
        
        grid = Array( repeating: Array( repeating: State.clean, count: Grid.gridMax ), count: Grid.gridMax )
        offset     = Point2D( x: Grid.gridMax / 2, y: Grid.gridMax / 2 )
        current    = Point2D( x: 0, y: 0 )
        points     = .up
        range      = Rect2D( min: Point2D( x: 0, y: 0 ), max: Point2D( x: 0, y: 0 ) )
        infections = 0

        for y in 0 ..< initial.count {
            let realY = y - initial.count / 2
            
            for x in 0 ..< initial[y].count {
                let realX = x - initial.count / 2
                let actual = Point2D( x: realX, y: realY )
                
                self[actual] = initial[y][x]
            }
        }

        infections = 0
    }
    
    subscript( point: Point2D ) -> State {
        get {
            let point = try! offsetPoint( point: point )
            
            return grid[point.y][point.x]
        }
        set {
            range = range.expand( with: point )
            let point = try! offsetPoint( point: point )

            grid[point.y][point.x] = newValue
            if newValue == .infected { infections += 1 }
        }
    }
    
    func offsetPoint( point: Point2D ) throws -> Point2D {
        let point = point + offset
        
        guard 0 <= point.x && point.x < Grid.gridMax else { throw RuntimeError( "Range exdeeded" ) }
        guard 0 <= point.y && point.y < Grid.gridMax else { throw RuntimeError( "Range exdeeded" ) }

        return point
    }
    
    func burst( count: Int ) -> Void {
        var nextState = self[current]
        
        for _ in 0 ..< count {
            switch self[current] {
            case .infected:
                nextState = .clean
                points = points.turn( Turn.right )
            case .clean:
                nextState = .infected
                points = points.turn( Turn.left )
            case .weakened:
                break
            case .flagged:
                break
            }
            
            self[current] = nextState
            current = current.move( direction: points )
        }
    }
    
    func evolvedBurst( count: Int ) -> Void {
        var nextState = self[current]
        var number = 0
        
        while number < count {
            number += 1
            switch self[current] {
            case .infected:
                nextState = .flagged
                points = points.turn( Turn.right )
            case .clean:
                nextState = .weakened
                points = points.turn( Turn.left )
            case .weakened:
                nextState = .infected
                break
            case .flagged:
                nextState = .clean
                points = points.turn( Turn.back )
                break
            }
            
            self[current] = nextState
            current = current.move( direction: points )
        }
    }
    
    func printIt() -> Void {
        for y in range.min.y ... range.max.y {
            let line = ( range.min.x ... range.max.x ).map {
                self[ Point2D( x: $0, y: y ) ].rawValue
            }.joined()
            
            print( line )
        }
        print()
    }
}


func parse( input: AOCinput ) -> Grid {
    return Grid( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let grid = parse( input: input )
    
    grid.burst( count: 10000 )
    return "\(grid.infections)"
}


func part2( input: AOCinput ) -> String {
    let grid = parse( input: input )
    
    grid.evolvedBurst( count: 10000000 )
    return "\(grid.infections)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
