//
//         FILE: main.swift
//  DESCRIPTION: day15 - Chiton
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/14/21 23:01:30
//

import Foundation

protocol RiskMap {
    var bounds: Rect2D { get }
    var end: Point2D { get }
    var points: [Point2D] { get }

    subscript( position: Point2D ) -> Int { get }
}

struct Map: RiskMap {
    let map: [[Int]]
    let bounds: Rect2D
    let end: Point2D
    
    subscript( position: Point2D ) -> Int { return map[position.y][position.x] }
    
    var points: [Point2D] {
        ( 0 ..< bounds.height ).map { row in
            ( 0 ..< bounds.width ).map { col in Point2D( x: col, y: row ) }
        }.flatMap { $0 }
    }

    init( lines: [String] ) {
        map = lines.map { $0.map { Int( String( $0 ) )! } }
        end = Point2D( x: map[0].count - 1, y: map.count - 1 )
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), max: end )
    }
    
    init( expand: Map, by: Int ) {
        map = expand.map.map { $0.map { risk -> Int in
            let new = risk + by
            return new < 10 ? new : new - 9 }
        }
        end = expand.end
        bounds = expand.bounds
    }
}

struct RiskMatrix {
    let map: RiskMap
    var risks: [[Int]]
    var vertexSet: Set<Point2D>
    
    subscript( position: Point2D ) -> Int {
        get { return risks[position.y][position.x] }
        set( newValue ) { risks[position.y][position.x] = newValue }
    }

    init( map: RiskMap, start: Point2D ) {
        self.map = map
        risks = Array(
            repeating: Array( repeating: Int.max, count: map.bounds.width ),
            count: map.bounds.height
        )
        
        vertexSet = Set( map.points )
        self[ start ] = 0
    }
    
    mutating func scan( predicate: ( Point2D ) -> Bool ) -> Point2D? {
        while !vertexSet.isEmpty {
            let position = vertexSet.min( by: { self[$0] < self[$1] } )!
            
            vertexSet.remove( position )

            for neighbor in DirectionUDLR.allCases
                    .map( { position + $0.vector } )
                    .filter( { vertexSet.contains( $0 ) } )
            {
                let risk = self[position] + map[neighbor]
                
                if risk < self[neighbor] {
                    self[neighbor] = risk
                }
            }
            if predicate( position ) { return position }
        }
        
        return nil
    }
}

struct TiledMap: RiskMap {
    static let expandFactor = 5
    
    let maps: [Map]
    let bounds: Rect2D
    let end: Point2D
    var points: [Point2D] {
        ( 0 ..< bounds.height ).map { row in
            ( 0 ..< bounds.width ).map { col in Point2D( x: col, y: row ) }
        }.flatMap { $0 }
    }
    var fullMap: String {
        return ( 0 ..< bounds.height ).map { y in
            ( 0 ..< maps[0].bounds.height ).map { mapY in
                ( 0 ..< bounds.width ).map { x -> String in
                    return maps[x + y].map[mapY].map { String( $0 ) }.joined()
                }.joined()
            }.joined( separator: "\n" )
        }.joined( separator: "\n" )
    }

    subscript( position: Point2D ) -> Int {
        let mapIndex = position.x / maps[0].bounds.width + position.y / maps[0].bounds.height
        let mapPosition = Point2D(
            x: position.x % maps[0].bounds.width, y: position.y % maps[0].bounds.height )
        return maps[mapIndex][mapPosition]
    }
    
    init( initial: Map ) {
        maps = [ initial ] + ( 1 ... 8 ).map { Map( expand: initial, by: $0 ) }
        end  = Point2D(
            x: initial.map[0].count * TiledMap.expandFactor - 1,
            y: initial.map.count * TiledMap.expandFactor - 1
        )
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), max: end )
    }
}


//1  function Dijkstra(Graph, source):
//2
//3      create vertex set Q
//4
//5      for each vertex v in Graph:
//6          dist[v] ← INFINITY
//7          prev[v] ← UNDEFINED
//8          add v to Q
//9      dist[source] ← 0
//10
//11      while Q is not empty:
//12          u ← vertex in Q with min dist[u]
//13
//14          remove u from Q
//15
//16          for each neighbor v of u still in Q:
//17              alt ← dist[u] + length(u, v)
//18              if alt < dist[v]:
//19                  dist[v] ← alt
//20                  prev[v] ← u
//21
//22      return dist[], prev[]


func parse( input: AOCinput ) -> Map {
    return Map( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let map = parse( input: input )
    var risks = RiskMatrix( map: map, start: Point2D( x: 0, y: 0 ) )

    if let ending = risks.scan( predicate: { $0 == map.end } ) {
        return "\( risks[ending] )"
    }
    return "No solution"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let tiled = TiledMap( initial: map )
    var risks = RiskMatrix( map: tiled, start: Point2D( x: 0, y: 0 ) )

    if let ending = risks.scan( predicate: { $0 == tiled.end } ) {
        return "\( risks[ending] )"
    }
    return "No solution"
}

try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
