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
    
    func possibleMoves( map: Map, position: Point2D ) -> [Point2D] {
        return DirectionUDLR.allCases
            .map { position + $0.vector }
            .filter { if case Cell.empty = map[$0] { return true }; return false }
    }
    
    func findInRange( map: Map, targets: [Fighter] ) -> [Point2D] {
        var seen = Set<Point2D>()
        return targets
            .flatMap { $0.possibleMoves( map: map, position: $0.position ) }
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
            let moves = possibleMoves( map: map, position: current )
            
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
                let moves = possibleMoves( map: map, position: current )
                
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


class Map {
    var cells: [[Cell]]
    
    var width: Int { cells[0].count }
    var height: Int { cells.count }

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
}


func runFight( input: AOCinput, printResults: Bool, elfAttackPoints: Int ) -> ( Bool, Int ) {
    let map = Map( lines: input.lines )
    if printResults { map.print( round: 0 ) }
    
    var completed = 0
    let elves = map.allElves
    
    elves.forEach { $0.attackPoints = elfAttackPoints }
    
    THEFIGHT:
    for tick in 1 ... Int.max {
        let fighters = map.allFighters
        
        for fighter in fighters where fighter.isAlive {
            if !fighter.turn( map: map ) {
                if printResults { map.print( round: tick ) }
                break THEFIGHT
            }
        }
        //    printMap(map: map, round: tick)
        completed = tick
    }
    
    let remaining = map.allFighters
    let hitPoints = remaining.reduce( 0, { $0 + $1.hitPoints } )
    
    if printResults {
        print( "Win for team \(remaining[0].type.rawValue) at", completed * hitPoints )
    }
    
    return ( elves.count == map.allElves.count, completed * hitPoints )
}


func part1( input: AOCinput ) -> String {
    let ( _, result ) = runFight( input: input, printResults: false, elfAttackPoints: 3 )
    
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    var lowHP = 3
    var highHP = 100
    var final = 0
    
    do {
        let ( success, result ) = runFight( input: input, printResults: false, elfAttackPoints: lowHP )
        
        if success { return "\(result)" }
    }
    
    do {
        let ( success, _ ) = runFight( input: input, printResults: false, elfAttackPoints: highHP )
        
        if !success { return "\(highHP) is not high enough" }
    }
    
    while lowHP + 1 < highHP {
        let currentHP = ( lowHP + highHP ) / 2
        
        let ( success, result ) = runFight( input: input, printResults: false, elfAttackPoints: currentHP )
        if success {
            highHP = currentHP
            final = result
        } else {
            lowHP = currentHP
        }
    }
    
    return "\(final)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
