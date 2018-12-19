//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 12/18/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
"""
let input = """
....||.#|..|...|.#..#...|.|.....|.....##|.....||..
....#.|..|.....#|....|#|##|...#........|...#.#|.#.
.#||....|...#####..|.|.#..|..|.|..#.|#....#..||#..
.....|....|..|....#....#..#...||....|.....#.|#..|#
.|.#||##.|..#....|#.|..|||#..##.|.#.|..##..|...|.|
.|.|...|...|#.|.....#...#|.#.....#..|#........###.
......|#|..#....|.#.#|....||#|.|#.....#|..#.#||...
.|.......##|..|..#|....|.|.|....#..|#|#.#...#.||##
##|..#.#..#||.###.|......|#.|....#...#.|...#....#|
..|###|#....#.|.#|#|.....|..|.||#|.|#.||...|##...#
...#....|.||||.|.|.##...#..|.||.|....#|#|#.|..|||.
|#....#...##..#||..|..#|.......|#|....|.|.|..|##..
|#....|.|..|..|..#.#......|..|.|..|||.#||...#.#.||
...|.|.....#.##|....|..#.|.....||..##..#..|||.....
.###.#.|.|||#.#.|.|.|...#..###..#|.........|.....#
|..#..|#..#........#.#.###.#...|.|.....|.||.|.|.||
|##.|..#..#...#|.........#|...#||.|..#|#.|.|..||..
....||.|....#.....|......#.|.|#.#.......|.|...#...
|.#.#|..#|#..#.#......#||.#..|||.#.#..#.||.####.#.
|.||.|.|.|#|.#.#|.#.|||..|........|..#..|.......|.
##..|.#..||............|||..#....|.....###|#...|#.
#|.|..#.|.|......|#|#.||.|....#...#....|...|...|..
#.#.#...##...#....|#|#||.#|#...|#||#|....|..|...||
.|.#.|.|...###.|..##..||#..|.....||.|.|....##..#|#
..#|#|..##...##|..|||||.|....|.#..|...|...#.#|||..
..|.|....#.##.##|..|#..|...||...|..||##..##...#.##
..#|###..##....##|.||.|.|.||#...|.#.#|#.##||.|..|.
...|#...|#..#.....#|.....##..##.......#...##.|...#
.|..#.##|....#.#.#...|...##........|##|..#.|...|..
......|#....#.........#.|.....||...#|.|...#.|#....
..|.#..###||...#|###...|.|...|.|....#...#..|.|.#.|
.#|....||#.#|..#.#|..##.........|#.|.....#....|||.
....#.#....#|.|#.#.#.|#............|.#.#....|#...|
..|#....#|...#.#..#.#.#||..#.#..|......##.#.||....
..|#....|#..|.#..#....#.|#.||.....#..#.#|.#...|..#
.#........|||.......|....|||.#|#..#.#|#........||.
#..|.....#...#..#.|#....##...##.##...#||.........|
..|.##.|..|...|..#|#.|.........||...##......###.|.
.|..|...#....||..#....#||#...#.#......##......#|.#
.|..#......#.|.#.##.|..|...#.|##..|||...|.......#.
...#..#..|#.|.....#||.|....#...|##|##.....|.#..|..
#.....#...#...##.|....|......##...|...#.#.#.|.....
....#..|.|.|###|.##.|.#|.|.||.|#..|#..#...|.##.#..
..|.|.#.|#.#...##.#||#...#..||.#.|#..|###....|#...
|.|..........|.#......#..#|.#...#.....#.#.#|.###.|
#..#|||....#..|....##|...|.#.|##||.|..|.#|.|...|#|
.|###..#.....|.#.||.#..|#...#.#|.#|.|.##|....#|#..
.|...#...##......|..#.|#|.#.##......#.|......|...|
#.#..|#.#...#.|#|....#|##..#....##|..#.|..|#...|..
.#.#..|.#..#........##.|#..|##||......|..#...#....
"""

enum Acre: String {
    case open = ".", trees = "|", lumberyard = "#"
}

class Area {
    var map: [[Acre]]
    
    init( input: String ) {
        let lines = input.split(separator: "\n")
        
        map = []
        for line in lines {
            var row: [Acre] = []
            
            for char in line {
                switch char {
                case ".":
                    row.append(.open)
                case "|":
                    row.append(.trees)
                case "#":
                    row.append(.lumberyard)
                default:
                    print( "Invalid input '\(char)'" )
                    exit(1)
                }
            }
            map.append(row)
        }
    }
    
    init( old: Area ) {
        map = old.map
    }
    
    func printMap() -> Void {
        map.forEach { print( $0.map { $0.rawValue }.joined() ) }
        print()
    }
    
    func countAdjacentTrees( row: Int, col: Int ) -> Int {
        var count = 0
        
        for row in max( row - 1, 0 ) ..< min( row + 2, map.count ) {
            for col in max( col - 1, 0 ) ..< min( col + 2, map[row].count ) {
                if case .trees = map[row][col] { count += 1 }
            }
        }
        
        return count
    }
    
    func countAdjacentLumberyards( row: Int, col: Int ) -> Int {
        var count = 0
        
        for row in max( row - 1, 0 ) ..< min( row + 2, map.count ) {
            for col in max( col - 1, 0 ) ..< min( col + 2, map[row].count ) {
                if case .lumberyard = map[row][col] { count += 1 }
            }
        }
        
        return count
    }
    
    func transition() -> Void {
        let new = Area(old: self)
        
        for row in 0 ..< map.count {
            for col in 0 ..< map[row].count {
                switch map[row][col] {
                case .open:
                    if countAdjacentTrees( row: row, col: col ) >= 3 {
                        new.map[row][col] = .trees
                    }
                case .trees:
                    if countAdjacentLumberyards( row: row, col: col ) >= 3 {
                        new.map[row][col] = .lumberyard
                    }
                case .lumberyard:
                    let lumberyards = countAdjacentLumberyards( row: row, col: col )
                    let trees = countAdjacentTrees( row: row, col: col )
                    
                    if lumberyards == 1 || trees == 0 {
                        new.map[row][col] = .open
                    }
                }
            }
        }
        
        map = new.map
    }
    
    func countTrees() -> Int {
        return map.reduce( 0, { $0 + $1.reduce( 0, { if case .trees = $1 { return $0 + 1 }; return $0 } ) } )
    }
    
    func countLumberyards() -> Int {
        return map.reduce( 0, { $0 + $1.reduce( 0, {
            if case .lumberyard = $1 { return $0 + 1 }; return $0
        } ) } )
    }
}


let part1 = 10
let part2 = 1000000000
let area = Area(input: input)

area.printMap()
for _ in 1 ... part1 {
    area.transition()
}
area.printMap()
print( "Part1:", area.countTrees() * area.countLumberyards() )


let maxCycle = 100
var history:[Area] = []

for minute in ( part1 + 1 ) ... part2 {
    area.transition()
    if let index = history.lastIndex( where: { $0.map == area.map } ) {
        print( "Found cycle at minute", minute )
        print( "Index is \(index), cycle length is \(history.count-index)" )
        
        let remaining = part2 - minute
        let offset = remaining % ( history.count - index )
        
        area.map = history[ index + offset ].map
        break
    }
    if history.count == maxCycle {
        history.removeFirst()
    }
    history.append(Area(old: area))
}

area.printMap()
print( "Part2:", area.countTrees() * area.countLumberyards() )
