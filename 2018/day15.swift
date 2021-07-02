//
//         FILE: main.swift
//  DESCRIPTION: day15 - Beverage Bandits
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/22/21 19:12:37
//

import Foundation

extension Point2D {
    static func inReadingOrder( left: Point2D, right: Point2D ) -> Bool {
        return left.y < right.y || left.y == right.y && left.x < right.x
    }
}

class Fighter {
    enum Class: String { case goblin, elf }

    let type: Class
    var attackPoints = 3
    var hitPoints: Int
    var position: Point2D
    
    var isAlive: Bool { return hitPoints > 0 }
    var isDead: Bool { return !isAlive }
    
    init( type: Class, position: Point2D ) {
        self.type = type
        hitPoints = 200
        self.position = position
    }
    
    func turn( map: Map ) -> Bool {
        var targets: [Fighter] = []
        
        switch type {
        case .elf:
            targets = map.allGoblins
        case .goblin:
            targets = map.allElves
        }
        
        if targets.count == 0 {
            // All opponents are dead, indicate tick aborted
            return false
        }
        
        if let victim = nextVictim( targets: targets ) {
            attack( map: map, victim: victim )
        } else {
            let distances = allDistances( map: map )
            let inRange = findInRange( map: map, targets: targets )

            if let closest = inRange.min( by: { distances[$0.y][$0.x] < distances[$1.y][$1.x] } ) {
                let distance = distances[closest.y][closest.x]
                
                if distance < Int.max {
                    let candidates = inRange.filter { distances[$0.y][$0.x] == distance }
                    let target = candidates.sorted( by: Point2D.inReadingOrder( left: right: ) )[0]
                    let move = path( map: map, to: target, distances: distances )
                    let savedCell = map[position]

                    map[position] = .empty
                    position = move
                    map[position] = savedCell
                    
                    if let victim = nextVictim( targets: targets ) {
                        attack( map: map, victim: victim )
                    }
                }
            }
        }
        
        return true
    }
        
    func nextVictim( targets: [Fighter] ) -> Fighter? {
        return targets
            .filter { position.distance( other: $0.position ) == 1 }
            .min( by: { $0.hitPoints < $1.hitPoints } )
    }
    
    func findInRange( map: Map, targets: [Fighter] ) -> [Point2D] {
        var seen = Set<Point2D>()
        return targets
            .flatMap { map.possibleMoves( position: $0.position ) }
            .filter { seen.insert( $0 ).inserted }
            .sorted( by: Point2D.inReadingOrder( left: right: ) )
    }
        
    func allDistances( map: Map ) -> [[Int]] {
        var distances = Array( repeating: Array( repeating: Int.max, count: map.width ), count: map.height )
        var queue = [ position ]
        
        distances[position.y][position.x] = 0
        while queue.count > 0 {
            let current = queue.removeFirst()
            let distance = distances[current.y][current.x] + 1
            let moves = map.possibleMoves( position: current )
            
            for move in moves {
                if distances[move.y][move.x] == Int.max {
                    distances[move.y][move.x] = distance
                    queue.append( move )
                }
            }
        }
        
        return distances
    }
    
    func path( map: Map, to location: Point2D, distances: [[Int]] ) -> Point2D {
        var results: [Point2D] = []
        var queue = [location]
        var alreadyQueued: Set<Point2D> = []
        
        while queue.count > 0 {
            let current = queue.removeFirst()
            let distance = distances[current.y][current.x] - 1
            
            if distance < 1 {
                results.append( current )
            } else {
                let moves = map.possibleMoves( position: current )
                
                for move in moves {
                    if distances[move.y][move.x] == distance && !alreadyQueued.contains( move ) {
                        queue.append( move )
                        alreadyQueued.insert( move )
                    }
                }
            }
        }
        
        results.sort( by: Point2D.inReadingOrder( left: right: ) )
        return results[0]
    }
    
    func attack( map: Map, victim: Fighter ) -> Void {
        victim.hitPoints -= attackPoints
        if victim.isDead {
            map[victim.position] = .empty
        }
    }
}


class Map {
    enum Cell {
        case wall, empty, goblin( Fighter ), elf( Fighter )
        
        var mapValue: String {
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

    var cells: [[Cell]]
    var completed: Int?
    
    var width: Int { cells[0].count }
    var height: Int { cells.count }
    var outcome: Int? {
        guard let completed = completed else { return nil }
        
        return completed * allFighters.reduce( 0, { $0 + $1.hitPoints } )
    }

    init( lines: [String] ) {
        cells = ( 0 ..< lines.count ).map { y -> [Cell] in
            let characters = Array( lines[y] )
            
            return ( 0 ..< characters.count ).map { x -> Cell in
                switch characters[x] {
                case "#":
                    return Cell.wall
                case ".":
                    return Cell.empty
                case "G":
                    return Cell.goblin( Fighter( type: .goblin, position: Point2D( x: x, y: y ) ) )
                case "E":
                    return Cell.elf( Fighter( type: .elf, position: Point2D( x: x, y: y ) ) )
                default:
                    Swift.print( "Bad character '\(characters[x]) in input." )
                    exit( 1 )
                }
            }
        }
    }
    
    subscript( position: Point2D ) -> Cell {
        get {
            return cells[position.y][position.x]
        }
        set ( newValue ) {
            cells[position.y][position.x] = newValue
        }
    }
    
    var allFighters: [Fighter] {
        return cells.flatMap { $0 }.compactMap {
            switch $0 {
            case let .elf( elf ):
                return elf
            case let .goblin( goblin ):
                return goblin
            default:
                return nil
            }
        }
    }
    
    var allElves: [Fighter] {
        return cells.flatMap { $0 }.compactMap {
            if case let Cell.elf( elf ) = $0 { return elf }
            return nil
        }
    }

    var allGoblins: [Fighter] {
        return cells.flatMap { $0 }.compactMap {
            if case let Cell.goblin( goblin ) = $0 { return goblin }
            return nil
        }
    }

    func print( round: Int ) -> Void {
        Swift.print( "Round", round )
        cells.forEach { Swift.print( $0.map { $0.mapValue }.joined() ) }
        Swift.print()
    }

    func possibleMoves( position: Point2D ) -> [Point2D] {
        return DirectionUDLR.allCases
            .map { position + $0.vector }
            .filter { if case Cell.empty = self[$0] { return true }; return false }
    }
    
    func runFight( elfAttackPoints: Int, printResults: Bool = false ) -> Bool {
        if printResults { print( round: 0 ) }
        
        let elves = allElves
        
        elves.forEach { $0.attackPoints = elfAttackPoints }
        
        THEFIGHT:
        for tick in 1 ... Int.max {
            let fighters = allFighters
            
            for fighter in fighters where fighter.isAlive {
                if !fighter.turn( map: self ) {
                    if printResults { print( round: tick ) }
                    completed = tick - 1
                    break THEFIGHT
                }
            }
        }
        
        if printResults {
            Swift.print( "Win for team \(allFighters[0].type.rawValue) at", outcome! )
        }
        
        return elves.count == allElves.count
    }
}


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    let _ = map.runFight( elfAttackPoints: 3 )
    
    return "\( map.outcome! )"
}


func part2( input: AOCinput ) -> String {
    var lowHP = 3
    var lastHP = lowHP
    var highHP = 0
    var final = 0
    
    repeat {
        let map = parse( input: input )
        
        if map.runFight( elfAttackPoints: lowHP ) {
            highHP = lowHP
            lowHP = lastHP
            final = map.outcome!
        } else {
            lastHP = lowHP
            lowHP *= 2
        }
    } while highHP == 0
    
    while lowHP + 1 < highHP {
        let map = parse( input: input )
        let currentHP = ( lowHP + highHP ) / 2
        
        if map.runFight( elfAttackPoints: currentHP ) {
            highHP = currentHP
            final = map.outcome!
        } else {
            lowHP = currentHP
        }
    }
    
    return "\(final)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
