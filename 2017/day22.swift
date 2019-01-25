//
//  main.swift
//  day22
//
//  Created by Mark Johnson on 1/24/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let testInput = """
..#
#..
...
"""
let input = """
.....###..#....#.#..##...
......##.##...........##.
.#..#..#.#.##.##.........
...#..###..##.#.###.#.#.#
##....#.##.#..####.####..
#..##...#.##.##.....##..#
.#.#......#...####...#.##
###....#######...#####.#.
##..#.####...#.#.##......
##.....###....#.#..#.##.#
.#..##.....#########.##..
##...##.###..#.#..#.#...#
...####..#...#.##.#..####
.#..##......#####..#.###.
...#.#.#..##...#####.....
#..###.###.#.....#.#.###.
##.##.#.#.##.#..#..######
####.##..#.###.#...#..###
.........#####.##.###..##
..#.##.#..#..#...##..#...
###.###.#.#..##...###....
##..#.#.#.#.#.#.#...###..
#..#.#.....#..#..#..##...
........#######.#...#.#..
..##.###.#.##.#.#.###..##
"""

enum State: String {
    case clean = ".", weakened = "W", infected = "#", flagged = "F"
}

enum Direction: String, CaseIterable {
    case up = "U", down = "D", left = "L", right = "R"
    
    func turn( _ how: Turn ) -> Direction {
        switch how {
        case .left:
            switch self {
            case .up:
                return .left
            case .right:
                return .up
            case .down:
                return .right
            case .left:
                return .down
            }
        case .right:
            switch self {
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .up
            }
        case .back:
            switch self {
            case .up:
                return .down
            case .right:
                return .left
            case .down:
                return .up
            case .left:
                return .right
            }
        }
    }
}

enum Turn {
    case left, right, back
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    static func +( left: Point, right: Point ) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func ==( left: Point, right: Point ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    func move( direction: Direction ) -> Point {
        switch direction {
        case .up:
            return self + Point(x: 0, y: -1)
        case .right:
            return self + Point(x: 1, y: 0)
        case .down:
            return self + Point(x: 0, y: 1)
        case .left:
            return self + Point(x: -1, y: 0)
        }
    }
}

class Grid {
    static let gridMax = 5001
    
    var grid: [[State]]
    let offset: Point
    var current: Point
    var points: Direction
    var rangeMin: Point
    var rangeMax: Point
    var infections: Int

    init( input: String ) {
        let initial = input.split(separator: "\n").map { $0.map { $0 == "." ? State.clean : State.infected } }
        
        grid = Array( repeating: Array( repeating: State.clean, count: Grid.gridMax ), count: Grid.gridMax )
        offset = Point( x: Grid.gridMax / 2, y: Grid.gridMax / 2 )
        current = Point( x: 0, y: 0 )
        points = .up
        rangeMin = Point( x: 0, y: 0 )
        rangeMax = Point( x: 0, y: 0 )
        infections = 0

        for y in 0 ..< initial.count {
            let realY = y - initial.count / 2
            
            for x in 0 ..< initial[y].count {
                let realX = x - initial.count / 2
                let actual = Point( x: realX, y: realY )
                
                self[actual] = initial[y][x]
            }
        }

        infections = 0
    }
    
    subscript( point: Point ) -> State {
        get {
            let point = offsetPoint( point: point )
            
            return grid[point.y][point.x]
        }
        set {
            let minx = min( rangeMin.x, point.x )
            let maxx = max( rangeMax.x, point.x )
            let miny = min( rangeMin.y, point.y )
            let maxy = max( rangeMax.y, point.y )
            let point = offsetPoint( point: point )

            grid[point.y][point.x] = newValue
            rangeMin = Point( x: minx, y: miny )
            rangeMax = Point( x: maxx, y: maxy )
            if newValue == .infected { infections += 1 }
        }
    }
    
    func offsetPoint( point: Point ) -> Point {
        let point = point + offset
        
        guard point.x >= 0 && point.y >= 0 else { print( "Range exdeeded" ); exit(1) }
        guard point.x < Grid.gridMax && point.y < Grid.gridMax else { print( "Range exdeeded" ); exit(1) }
        
        return point
    }
    
    func burst( count: Int ) -> Void {
        var nextState = self[current]
        
        for _ in 0 ..< count {
            switch self[current] {
            case .infected:
                nextState = .clean
                points = points.turn( .right )
            case .clean:
                nextState = .infected
                points = points.turn( .left )
            case .weakened:
                break
            case .flagged:
                break
            }
            
            self[current] = nextState
            current = current.move(direction: points)
        }
    }
    
    func evolvedBurst( count: Int ) -> Void {
        var nextState = self[current]
        
        for _ in 0 ..< count {
            switch self[current] {
            case .infected:
                nextState = .flagged
                points = points.turn( .right )
            case .clean:
                nextState = .weakened
                points = points.turn( .left )
            case .weakened:
                nextState = .infected
                break
            case .flagged:
                nextState = .clean
                points = points.turn( .back )
                break
            }
            
            self[current] = nextState
            current = current.move(direction: points)
        }
    }
    
    func printIt() -> Void {
        for y in rangeMin.y ... rangeMax.y {
            let line = ( rangeMin.x ... rangeMax.x ).map { self[ Point(x: $0, y: y) ].rawValue }.joined()
            
            print( line )
        }
        print()
    }
}

let grid1 = Grid( input: input )

grid1.burst(count: 10000)
//grid1.printIt()
print( "Part1:", grid1.infections )


let grid2 = Grid( input: input )

grid2.evolvedBurst(count: 10000000)
//grid2.printIt()
print( "Part2:", grid2.infections )
