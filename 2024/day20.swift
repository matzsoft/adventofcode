//
//         FILE: day20.swift
//  DESCRIPTION: Advent of Code 2024 Day 20: Race Condition
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/19/24 23:20:40
//

import Foundation
import Library

extension DirectionUDLR {
    init( from vector: Point2D ) {
        switch ( vector.x, vector.y ) {
        case let ( x, y ) where x < 0 && y == 0:
            self = .left
        case let ( x, y ) where x > 0 && y == 0:
            self = .right
        case let ( x, y ) where x == 0 && y < 0:
            self = .up
        case let ( x, y ) where x == 0 && y > 0:
            self = .down
        default:
            fatalError( "\(vector) is not orthogonal" )
        }
    }
}


struct Node {
    let position: Point2D
    let distance: Int
    let previous: Point2D?
    
    init( position: Point2D, distance: Int, previous: Point2D? = nil ) {
        self.position = position
        self.distance = distance
        self.previous = previous
    }
    
    func move( direction: DirectionUDLR ) -> Node {
        Node(
            position: position + direction.vector, distance: distance + 1,
            previous: position
        )
    }
}


struct Cheat: Hashable {
    let point1: Point2D
    let point2: Point2D
}


struct TargetGroup {
    let point1: Point2D
    let points: [Point2D]
    
    init( point1: Point2D, points: [Point2D] ) {
        self.point1 = point1
        self.points = points
    }
    
    init( from: Point2D, direction: DirectionUDLR ) {
        let reducedDirections = DirectionUDLR.allCases
            .filter { $0 != direction.turn( .back) }
        point1 = from
        points = reducedDirections.map { from + $0.vector }
    }
    
    func expand( from: Point2D, map: Map ) -> TargetGroup? {
        let point1 = from + point1
        guard map[point1] == .empty else { return nil }
        
        let points = points.map { from + $0 }.filter { map[$0] == .empty }
        return TargetGroup( point1: point1, points: points )
    }
}


struct CheatGroup {
    let point1: Point2D
    let groups: [TargetGroup]
    
    init( point1: Point2D, groups: [TargetGroup] ) {
        self.point1 = point1
        self.groups = groups
    }
    
    init( direction: DirectionUDLR ) {
        let reducedDirections = DirectionUDLR.allCases
            .filter { $0 != direction.turn( .back) }
        point1 = direction.vector
        groups = reducedDirections.map {
            TargetGroup( from: direction.vector + $0.vector, direction: $0 )
        }
    }
    
    func expand( from: Point2D, map: Map ) -> CheatGroup? {
        let point1 = from + point1
        guard map[point1] == .wall else { return nil }

        let groups = groups.compactMap { $0.expand( from: from, map: map ) }
        return CheatGroup( point1: point1, groups: groups )
    }
}


struct CheatGroups {
    let groups: [CheatGroup]
    
    init( groups: [CheatGroup] ) {
        self.groups = groups
    }
    
    init() {
        groups = DirectionUDLR.allCases.map { CheatGroup( direction: $0 ) }
    }
    
    func expand( from: Point2D, map: Map ) -> CheatGroups {
        CheatGroups( groups: groups.compactMap { $0.expand( from: from, map: map ) } )
    }
}


func vector( _ x: Int, _ y: Int ) -> Point2D {
    Point2D( x: x, y: y )
}


struct Map: CustomStringConvertible {
    enum External: Character {
        case wall = "#", empty = ".", start = "S", end = "E"
        
        var toInternal: Internal {
            switch self {
            case .wall:
                return .wall
            case .empty, .start, .end:
                return .empty
            }
        }
    }
    enum Internal {
        case wall, empty
        
        var toExternal: External {
            switch self {
            case .wall:
                return .wall
            case .empty:
                return .empty
            }
        }
    }
    
    let map: [[Internal]]
    let bounds: Rect2D
    let start: Point2D
    let end: Point2D
    let threshold: Int
    let noCheat: Int?
    
    var description: String {
        var representation = map.map { $0.map { $0.toExternal } }
        representation[start.y][start.x] = .start
        representation[end.y][end.x] = .end
        let buffer = representation.map {
            "#" + $0.map { String( $0.rawValue ) }.joined() + "#"
        }
        let bigRow = String( repeating: "#", count: map[0].count + 2 )
        let lines = [ bigRow ] + buffer + [ bigRow ]
        return lines.joined( separator: "\n" )
    }
    
    init( input: AOCinput ) {
        var start = Point2D( x: 0, y: 0 )
        var end = start
        let trimmed = Array( input.lines[ 1 ..< input.lines.count - 1 ] )
        let fields = input.extras[0].split( separator: "," ).map { Int( $0 )! }
        map = trimmed.indices.map { y in
            let line = trimmed[y].dropLast().dropFirst().map { $0 }
            return line.indices.map { x in
                let external = External( rawValue: line[x] )!
                if external == .start { start = Point2D( x: x, y: y ) }
                if external == .end { end = Point2D( x: x, y: y ) }
                return external.toInternal
            }
        }
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count
        )!
        self.start = start
        self.end = end
        threshold = fields[0]
        noCheat = fields.count > 1 ? fields[1] : nil
    }
    
    subscript( _ point: Point2D ) -> Internal? {
        guard bounds.contains( point: point ) else { return nil }
        return map[point.y][point.x]
    }
    
    func contains( point: Point2D ) -> Bool {
        bounds.contains( point: point )
    }
    
    var shortestPath: ( Int?, [[Node?]] ) {
        let initial = Node( position: start, distance: 0 )
        var queue = CircularBuffer( initial: [ initial ], limit: 500 )
        var available = map
        var path = map.map { $0.map { _ -> Node? in nil } }
        available[start.y][start.x] = .wall
        path[start.y][start.x] = initial
                
        while true {
            guard let node = queue.read() else { return ( nil, path ) }
            if node.position == end { return ( node.distance, path ) }
            for trial in DirectionUDLR.allCases.map( { node.move( direction: $0 ) } ) {
                if bounds.contains( point: trial.position ) {
                    if available[trial.position.y][trial.position.x] == .empty {
                        available[trial.position.y][trial.position.x] = .wall
                        path[trial.position.y][trial.position.x] = trial
                        try! queue.write( value: trial )
                    }
                }
            }
        }
    }

    func pathDescription( path: [[Node?]] ) -> String {
        var representation = map.map { $0.map { $0.toExternal } }
        representation[start.y][start.x] = .start
        representation[end.y][end.x] = .end
        var buffer = representation.map { $0.map { String( $0.rawValue ) } }
        
        var current = path[end.y][end.x]
        while let previous = current?.previous {
            guard let node = path[previous.y][previous.x] else { fatalError( "Bonkers" ) }
            let vector = current!.position - node.position
            let direction = DirectionUDLR( from: vector )
            if node.position != start {
                buffer[node.position.y][node.position.x] = direction.toArrow
            }
            current = node
        }
        
        let bigRow = String( repeating: "#", count: map[0].count + 2 )
        let wango = buffer.map { "#" + $0.joined() + "#" }
        let lines = [ bigRow ] + wango + [ bigRow ]
        return lines.joined( separator: "\n" )
    }

    // ...3...
    // ..323..
    // .32123.
    // 3210123
    // .32123.
    // ..323..
    // ...3...
    var countCheats: [ Int : Int ] {
        let ( best, path ) = shortestPath
        guard let best else { fatalError( "No shortest path" ) }
        var histogram = [ Int : Int ]()
        var usedCheats = Set<Cheat>()
        
        print( pathDescription( path: path ) )
        let cheatGroups = CheatGroups()
        var current = path[end.y][end.x]
        var cheats = [ Cheat : [Int] ]()
        while let previous = current?.previous {
            guard let node = path[previous.y][previous.x] else { fatalError( "Bonkers" ) }
            if node.distance < best - 3 {
                let groups = cheatGroups.expand( from: previous, map: self )
                for cheat1 in groups.groups {
                    for cheat2 in cheat1.groups {
                        let trial = cheat2.point1
                        let candidate = path[trial.y][trial.x]!
                        if candidate.distance - 2 > node.distance {
                            let key = candidate.distance - node.distance - 2
                            let cheat = Cheat(
                                point1: cheat1.point1, point2: cheat2.point1
                            )
                            if key == 62 {
                                cheats[ cheat, default: [] ].append( key )
                            } else {
                                cheats[ cheat, default: [] ].append( key )
                            }
                        }
                    }
                }
            }
            
            current = node
        }
        
        let bestGains = cheats.mapValues { $0.max()! }
        bestGains.forEach { histogram[ $0.value, default: 0 ] += 1 }
        return histogram
    }
}


func part1( input: AOCinput ) -> String {
    let map = Map( input: input )
    let histogram = map.countCheats.sorted { $0.key < $1.key }
    
    for entry in histogram {
        print( "There are \(entry.value) cheats that save \(entry.key) picoseconds." )
    }
    return ""
}


func part2( input: AOCinput ) -> String {
//    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
