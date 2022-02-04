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
    subscript( position: Point2D ) -> Int { get }
}

struct Map: RiskMap {
    let map: [[Int]]
    let bounds: Rect2D
    
    subscript( position: Point2D ) -> Int { return map[position.y][position.x] }
    
    init( map: [[Int]] ) {
        self.map = map
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: map[0].count, height: map.count )!
    }
    
    init( lines: [String] ) {
        let map = lines.map { $0.map { Int( String( $0 ) )! } }
        self.init( map: map )
    }
    
    func expand( by: Int ) -> Map {
        guard by > 0 else { return self }
        
        let map = map.map { $0.map { risk -> Int in
            let new = risk + by
            return new < 10 ? new : new - 9 }
        }
        return Map( map: map )
    }
}


struct TiledMap: RiskMap {
    static let expandFactor = 5
    
    let maps: [Map]
    let bounds: Rect2D

    subscript( position: Point2D ) -> Int {
        let mapIndex = position.x / maps[0].bounds.width + position.y / maps[0].bounds.height
        let mapPosition = Point2D(
            x: position.x % maps[0].bounds.width, y: position.y % maps[0].bounds.height )
        return maps[mapIndex][mapPosition]
    }
    
    init( initial: Map ) {
        maps = ( 0 ... 8 ).map { initial.expand( by: $0 ) }
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ),
            width: initial.bounds.width * TiledMap.expandFactor,
            height: initial.bounds.height * TiledMap.expandFactor
        )!
    }
}


struct RiskMatrix {
    struct Node {
        var risk: Int
        var prev: Int?
        var next: Int?
    }
    
    let map: RiskMap
    var risks: [Node]
    var head: Int?
    
    subscript( position: Point2D ) -> Node {
        get { return risks[ index( from: position ) ] }
        set( newValue ) { risks[ index( from: position ) ] = newValue }
    }

    init( map: RiskMap ) {
        self.map = map
        risks = ( 0 ..< map.bounds.area ).map { Node( risk: Int.max, prev: $0 - 1, next: $0 + 1 ) }
        risks[0] = Node( risk: 0, prev: nil, next: 1 )
        risks[ map.bounds.area - 1 ].next = nil
        head = 0
    }
    
    func index( from: Point2D ) -> Int {
        from.y * map.bounds.width + from.x
    }
    
    func point( from: Int ) -> Point2D {
        Point2D( x: from % map.bounds.width, y: from / map.bounds.width )
    }
    
    mutating func removeFirst() -> Point2D? {
        guard let first = head else { return nil }
        if let next = risks[first].next { risks[next].prev = nil }
        head = risks[first].next
        risks[first].next = nil
        return point( from: first )
    }
    
    mutating func remove( index: Int ) -> Void {
        if index == head { head = risks[index].next }
        if let prev = risks[index].prev {
            risks[prev].next = risks[index].next
        }
        if let next = risks[index].next {
            risks[next].prev = risks[index].prev
        }
        risks[index].prev = nil
        risks[index].next = nil
    }
    
    mutating func insert( index: Int ) -> Void {
        guard let first = head else {
            head = index
            return
        }
        
        if risks[index].risk < risks[first].risk {
            head = index
            risks[index].next = first
            risks[first].prev = index
            return
        }
        
        var prev = first
        while let next = risks[prev].next {
            if risks[index].risk >= risks[next].risk {
                prev = next
            } else {
                risks[index].prev = prev
                risks[index].next = next
                risks[prev].next = index
                risks[next].prev = index
                return
            }
        }
        
        risks[prev].next = index
        risks[index].prev = prev
    }
    
    mutating func scan() -> Int? {
        while let position = removeFirst() {
            for neighbor in DirectionUDLR.allCases
                    .map( { position + $0.vector } )
                    .filter( { map.bounds.contains( point: $0 ) } )
                    .filter( { self[$0].prev != nil || self[$0].next != nil } )
            {
                let risk = self[position].risk + map[neighbor]
                
                if risk < self[neighbor].risk {
                    let index = index( from: neighbor )

                    if neighbor == map.bounds.max { return risk }
                    risks[index].risk = risk
                    remove( index: index )
                    insert( index: index )
                }
            }
        }
        
        return nil
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
    var risks = RiskMatrix( map: map )

    if let risk = risks.scan() {
        return "\( risk )"
    }
    return "No solution"
}


func part2( input: AOCinput ) -> String {
    let map = parse( input: input )
    let tiled = TiledMap( initial: map )
    var risks = RiskMatrix( map: tiled )

    if let risk = risks.scan() {
        return "\( risk )"
    }
    return "No solution"
}

try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
