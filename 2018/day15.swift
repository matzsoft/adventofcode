//
//  main.swift
//  day15
//
//  Created by Mark Johnson on 12/14/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
#######
#.E...#
#.....#
#...G.#
#######
"""
let test2 = """
#########
#G..G..G#
#.......#
#.......#
#G..E..G#
#.......#
#.......#
#G..G..G#
#########
"""
let test3 = """
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
"""
let test4 = """
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######
"""
let test5 = """
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
"""
let test6 = """
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
"""
let test7 = """
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
"""
let test8 = """
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
"""
let input = """
################################
#######################...######
######################...#######
##############...####..G########
#############....G...G..########
############...#.......####..###
###########G.G##..#.G...###..###
##########....###.....G.G......#
#########....##....GG..G..###..#
###########..#................##
###########..#...#G...........##
##########...............G.....#
#####.#####...#####E.......E...#
####..#####..#######.....G..####
##.G..####G.#########.E...E...##
#...####....#########..........#
#.G.####....#########..........#
##..####....#########..##......#
###.###.....#########G.....#.###
###.##...G...#######..E.....####
###.....G.....#####E.......#####
###.......................######
######..............E.........##
######......###................#
#####.......##.................#
#####.#....##......##........E##
#######....######.##E.##########
#######....#########..##########
######.....#########....########
####.....###########..E.########
####...#.###########....########
################################
"""

func printDistances( distances: [[Int]] ) -> Void {
    distances.forEach { print( $0.map { $0 == Int.max ? "X" : ( $0 > 9 ? "?" : String($0) ) }.joined() ) }
    print()
}

enum Type: String {
    case goblin, elf
}

struct Point {
    let x: Int
    let y: Int
    
    func hashKey() -> String {
        return "\(x),\(y)"
    }
    
    func distance( to there: Point ) -> Int {
        return abs( x - there.x ) + abs( y - there.y )
    }
    
    static func !=( left: Point, right: Point ) -> Bool {
        return left.x != right.x || left.y != right.y
    }
    
    static func readingOrder( left: Point, right: Point ) -> Bool {
        return left.y < right.y || left.y == right.y && left.x < right.x
    }
}

class Fighter {
    let type: Type
    var attackPoints = 3
    var hitPoints: Int
    var position: Point
    
    var isAlive: Bool { return hitPoints > 0 }
    var isDead: Bool { return !isAlive }
    
    init( type: Type, position: Point ) {
        self.type = type
        hitPoints = 200
        self.position = position
    }
    
    func turn() -> Bool {
        var targets: [Fighter] = []
        
        switch type {
        case .elf:
            targets = Fighter.allGoblins()
        case .goblin:
            targets = Fighter.allElves()
        }
        
        if targets.count == 0 {
            // All opponents are dead, indicate tick aborted
            return false
        }
        
        if let victim = nextVictim(targets: targets) {
            attack(victim: victim)
        } else {
            let distances = allDistances()
            let inRange = findInRange(targets: targets)

            if let closest = inRange.min( by: { distances[$0.y][$0.x] < distances[$1.y][$1.x] } ) {
                let distance = distances[closest.y][closest.x]
                
                if distance < Int.max {
                    let candidates = inRange.filter { distances[$0.y][$0.x] == distance }
                    let target = candidates.sorted( by: Point.readingOrder(left:right:) )[0]
                    let move = path(to: target, distances: distances)
                    let savedCell = map[position.y][position.x]

                    map[position.y][position.x] = .empty
                    position = move
                    map[position.y][position.x] = savedCell
                    
                    if let victim = nextVictim(targets: targets) {
                        attack(victim: victim)
                    }
                }
            }
        }
        
        return true
    }
        
    func nextVictim( targets: [Fighter] ) -> Fighter? {
        var minHP = Int.max
        var victim: Fighter?
        
        for fighter in targets {
            if position.distance( to: fighter.position ) == 1 {
                if fighter.hitPoints < minHP {
                    minHP = fighter.hitPoints
                    victim = fighter
                }
            }
        }
        
        return victim
    }
    
    func possibleMoves( position: Point ) -> [Point] {
        var moves: [Point] = []
        let x = position.x
        let y = position.y
        
        if case Cell.empty = map[y-1][x] {
            moves.append( Point( x: x, y: y-1 ) )
        }
        if case Cell.empty = map[y][x-1] {
            moves.append( Point( x: x-1, y: y ) )
        }
        if case Cell.empty = map[y][x+1] {
            moves.append( Point( x: x+1, y: y ) )
        }
        if case Cell.empty = map[y+1][x] {
            moves.append( Point( x: x, y: y+1 ) )
        }
        
        return moves
    }
    
    func findInRange( targets: [Fighter] ) -> [Point] {
        var inRange: [Point] = []
        
        targets.forEach { inRange.append( contentsOf: $0.possibleMoves( position: $0.position ) ) }
        inRange.sort( by: { $0.y < $1.y || $0.y == $1.y && $0.x < $1.x } )
        
        var last = Point( x: -1, y: -1 )
        
        return inRange.filter { let v = $0 != last; last = $0; return v }
    }
    
    func allDistances() -> [[Int]] {
        var distances = Array( repeating: Array(repeating: Int.max, count: map[0].count), count: map.count )
        var queue = [ position ]
        
        distances[position.y][position.x] = 0
        while queue.count > 0 {
            let current = queue.removeFirst()
            let distance = distances[current.y][current.x] + 1
            let moves = possibleMoves(position: current)
            
            for move in moves {
                if distances[move.y][move.x] == Int.max {
                    distances[move.y][move.x] = distance
                    queue.append(move)
                }
            }
        }
        
        return distances
    }
    
    func path( to location: Point, distances: [[Int]] ) -> Point {
        var results: [Point] = []
        var queue = [location]
        var alreadyQueued: Set<String> = []
        
        while queue.count > 0 {
            let current = queue.removeFirst()
            let distance = distances[current.y][current.x] - 1
            
            if distance < 1 {
                results.append(current)
            } else {
                let moves = possibleMoves(position: current)
                
                for move in moves {
                    if distances[move.y][move.x] == distance && !alreadyQueued.contains( move.hashKey() ) {
                        queue.append(move)
                        alreadyQueued.insert( move.hashKey() )
                    }
                }
            }
        }
        
        results.sort( by: Point.readingOrder(left:right:) )
        return results[0]
    }
    
    func attack( victim: Fighter ) -> Void {
        victim.hitPoints -= attackPoints
        if victim.isDead {
            map[victim.position.y][victim.position.x] = .empty
        }
    }
    
    static func allElves() -> [Fighter] {
        let cells = map.flatMap { $0 }.filter { if case Cell.elf( _ ) = $0 { return true }; return false }
        
        return cells.map { if case let Cell.elf( elf ) = $0 { return elf }; return nil! }
    }

    static func allGoblins() -> [Fighter] {
        let cells = map.flatMap { $0 }.filter { if case Cell.goblin( _ ) = $0 { return true }; return false }
        
        return cells.map { if case let Cell.goblin( goblin ) = $0 { return goblin }; return nil! }
    }

    static func allFighters() -> [Fighter] {
        var fighters: [Fighter] = []
        
        for row in map {
            for cell in row {
                switch cell {
                case let .elf( elf ):
                    fighters.append( elf )
                case let .goblin( goblin ):
                    fighters.append( goblin )
                default:
                    continue
                }
            }
        }
        
        return fighters
    }
}

enum Cell {
    case wall, empty, goblin( Fighter ), elf( Fighter )
    
    func mapValue() -> String {
        switch self {
        case .wall:
            return "#"
        case .empty:
            return "."
        case .goblin:
            return "G"
        case .elf:
            return "E"
        }
    }
}

func parseInput( input: String ) -> [[Cell]] {
    let lines = input.split(separator: "\n")
    var map: [[Cell]] = []
    
    for line in lines {
        var row: [Cell] = []
        
        for cell in line {
            let location = Point( x: row.count, y: map.count )
            
            switch cell {
            case "#":
                row.append( Cell.wall )
            case ".":
                row.append( Cell.empty )
            case "G":
                row.append( Cell.goblin( Fighter(type: .goblin, position: location ) ) )
            case "E":
                row.append( Cell.elf( Fighter(type: .elf, position: location ) ) )
            default:
                print( "Bad character '\(cell) in input." )
                exit(1)
            }
        }
        
        map.append( row )
    }
    
    return map
}

func printMap( map: [[Cell]], round: Int ) -> Void {
    print( "Round", round )
    map.forEach { print( $0.map { $0.mapValue() }.joined() ) }
    print()
}

var map: [[Cell]] = []

func runFight( printResults: Bool, elfAttackPoints: Int ) -> ( Bool, Int ) {
    map = parseInput(input: input)
    if printResults {
        printMap(map: map, round: 0)
    }
    
    var completed = 0
    let elves = Fighter.allElves()
    
    elves.forEach { $0.attackPoints = elfAttackPoints }
    THEFIGHT:
        for tick in 1 ... Int.max {
            let fighters = Fighter.allFighters()
            
            for fighter in fighters where fighter.isAlive {
                if !fighter.turn() {
                    if printResults {
                        printMap(map: map, round: tick)
                    }
                    break THEFIGHT
                }
            }
            //    printMap(map: map, round: tick)
            completed = tick
    }
    
    let remaining = Fighter.allFighters()
    let hitPoints = remaining.reduce( 0, { $0 + $1.hitPoints } )
    
    if printResults {
        print( "Win for team \(remaining[0].type.rawValue) at", completed * hitPoints )
    }
    
    return ( elves.count == Fighter.allElves().count, completed * hitPoints )
}

let ( success, result ) = runFight( printResults: true, elfAttackPoints: 3 )

print( "Part1:", result )

if success {
    print( "Part2:", result )
} else {
    var lowHP = 3
    var highHP = 100
    var part2 = 0
    var ( success, result ) = runFight( printResults: false, elfAttackPoints: highHP )
    
    if !success {
        print( "Part2: \(highHP) is not high enough" )
    }
    
    while lowHP + 1 < highHP {
        let currentHP = ( lowHP + highHP ) / 2
        
        ( success, result ) = runFight( printResults: false, elfAttackPoints: currentHP )
        if success {
            highHP = currentHP
            part2 = result
        } else {
            lowHP = currentHP
        }
    }
    
    print( "Part2:", part2 )
}
