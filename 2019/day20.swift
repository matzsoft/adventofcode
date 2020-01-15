//
//  main.swift
//  day20
//
//  Created by Mark Johnson on 12/20/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
    
    static func +( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
    }
    
    static func -( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x - rhs.x, y: lhs.y - rhs.y )
    }
    
    func distance( other: Point ) -> Int {
        return abs( x - other.x ) + abs( y - other.y )
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( x )
        hasher.combine( y )
    }
    
    func min( other: Point ) -> Point {
        return Point( x: Swift.min( x, other.x ), y: Swift.min( y, other.y ) )
    }
    
    func max( other: Point ) -> Point {
        return Point( x: Swift.max( x, other.x ), y: Swift.max( y, other.y ) )
    }
}

enum Direction: Int, CaseIterable {
    case north = 1, south = 2, west = 3, east = 4
    
    var vector: Point {
        switch self {
        case .north:
            return Point( x: 0, y: -1 )
        case .south:
            return Point( x: 0, y: 1 )
        case .west:
            return Point( x: -1, y: 0 )
        case .east:
            return Point( x: 1, y: 0 )
        }
    }
    
    var reverse: Direction {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .west:
            return .east
        case .east:
            return .west
        }
    }
}

enum PortalType {
    case enter, leave, outside, inside
    
    var reverse: PortalType {
        switch self {
        case .enter:
            return .leave
        case .leave:
            return .enter
        case .outside:
            return .inside
        case .inside:
            return .outside
        }
    }
}

struct Portal {
    let label: String
    let destination: Point
    let type: PortalType
}

struct Donut {
    let map: Set<Point>
    let portals: [ Point : Portal ]
    let enter: Point
    let leave: Point
    
    init( input: String ) {
        let grid = input.split( separator: "\n" ).map { Array( $0 ) }
        var map = Set<Point>()
        var portals: [ Point : Portal ] = [:]
        var labels: [ String : Point ] = [:]
        var enter: Point?
        var leave: Point?
        
        func getLabel( grid: [[Substring.Element]], x: Int, y: Int ) -> ( String, Point, PortalType )? {
            var label = ""
            var point: Point?
            
            if y < grid.count - 1 && grid[y+1][x].isUppercase {
                label = String( grid[y][x] ) + String( grid[y+1][x] )
                
                if y > 0 && grid[y-1][x] == "." {
                    point = Point( x: x, y: y-1 )
                } else if y < grid.count - 2 && grid[y+2][x] == "." {
                    point = Point( x: x, y: y+2 )
                }
            } else if x < grid[y].count - 1 && grid[y][x+1].isUppercase {
                label = String( grid[y][x] ) + String( grid[y][x+1] )

                if x > 0 && grid[y][x-1] == "." {
                    point = Point( x: x-1, y: y )
                } else if x < grid[y].count - 2 && grid[y][x+2] == "." {
                    point = Point( x: x+2, y: y )
                }
            }
            
            guard point != nil else { return nil }
            if point!.x == 2 || point!.y == 2 {
                return ( label, point!, PortalType.outside )
            }
            
            if point!.x == grid[y].count - 3 || point!.y == grid.count - 3 {
                return ( label, point!, PortalType.outside )
            }
            
            return ( label, point!, PortalType.inside )
        }
        
        for y in 0 ..< grid.count {
            for x in 0 ..< grid[y].count {
                switch grid[y][x] {
                case " ", "#":
                    break
                case ".":
                    map.insert( Point( x: x, y: y ) )
                case let char where char.isUppercase:
                    if let ( label, point, type ) = getLabel( grid: grid, x: x, y: y ) {
                        switch label {
                        case "AA":
                            enter = point
                            portals[point] = Portal( label: label, destination: point, type: .enter )
                        case "ZZ":
                            leave = point
                            portals[point] = Portal( label: label, destination: point, type: .leave )
                        default:
                            if let labelPoint = labels[label] {
                                portals[point] = Portal( label: label, destination: labelPoint, type: type )
                                portals[labelPoint] = Portal( label: label, destination: point, type: type.reverse )
                            } else {
                                labels[label] = point
                            }
                        }
                    }
                default:
                    print( "Invalid character '\(grid[y][x])' at \(x),\(y)" )
                    exit(1)
                }
            }
        }
        
        self.map = map
        self.portals = portals
        self.enter = enter!
        self.leave = leave!
    }
    
    func traverse() -> Int {
        var queue = [ ( enter, 0 ) ]
        var seen = Set( [ enter ] )
        
        while !queue.isEmpty {
            let ( current, distance ) = queue.removeFirst()
            
            seen.insert( current )
            if let warp = portals[current] {
                switch warp.type {
                case .enter:
                    break
                case .leave:
                    return distance
                case .inside, .outside:
                    if !seen.contains( warp.destination ) {
                        queue.append( ( warp.destination, distance + 1 ) )
                        continue
                    }
                }
            }
            
            for move in Direction.allCases {
                let next = current + move.vector
                
                if map.contains( next ) && !seen.contains( next ) {
                    queue.append( ( next, distance + 1 ) )
                }
            }
        }
        
        return 0
    }
    
    struct Node {
        var list: [ Point : Int ]
    }
    
    func getNetwork() -> [ Point : Node ] {
        var network: [ Point : Node ] = [:]
        
        for portal in portals {
            if portal.value.type != .leave {
                network[portal.key] = traverseSubnet( point: portal.key )
            }
        }
        return network
    }
    
    func networkAsString( network: [ Point : Node ] ) -> String {
        var result: [ String ] = []
        
        for key in network.keys.sorted( by: { portals[$0]!.label < portals[$1]!.label } ) {
            let list = network[key]!.list
            let string = list.keys.map { "\( portals[$0]!.label):\(list[$0]! )" }.joined( separator: ", " )
            
            result.append( "\( portals[key]!.label ) => \(string)" )
        }
        
        return result.joined( separator: "\n" )
    }
    
    func traverseSubnet( point: Point ) -> Node {
        var subnet = Node( list: [:] )
        var queue: [ ( Point, Int ) ] = []
        var seen = Set( [ point ] )
  
        func moveOne( current: Point, distance: Int ) -> Void {
            for move in Direction.allCases {
                let next = current + move.vector
                
                if map.contains( next ) && !seen.contains( next ) {
                    queue.append( ( next, distance + 1 ) )
                }
            }
        }
        
        moveOne( current: point, distance: 0 )
        while !queue.isEmpty {
            let ( current, distance ) = queue.removeFirst()
            
            seen.insert( current )
            if let warp = portals[current] {
                switch warp.type {
                case .enter:
                    break
                case .leave, .inside, .outside:
                    subnet.list[current] = distance
                    continue
                }
            }
            
            moveOne( current: current, distance: distance )
        }
        
        return subnet
    }
    
    struct Candidate {
        let point: Point
        let distance: Int
        let level: Int
    }
    
    struct BeenThere {
        var record: [ Point : Set<Int> ] = [:]

        mutating func check( point: Point, level: Int ) -> Bool {
            if let entry = record[point] {
                if entry.contains( level ) {
                    return true
                }
                record[point]!.insert( level )
                return false
            }
            
            record[point] = [ level ]
            return false
        }
    }
    
    func traverseRecurse() -> Int {
        let network = getNetwork()
        var queue = [ Candidate( point: enter, distance: 0, level: 0 ) ]
        var seen = BeenThere()
        
        //print( networkAsString( network: network ) )
        while !queue.isEmpty {
            queue.sort { $0.distance < $1.distance }
            let candidate = queue.removeFirst()
            
            if candidate.point == leave {
                if candidate.level == 0 {
                    return candidate.distance
                }
                continue
            }
            
            for next in network[candidate.point]!.list {
                if !seen.check( point: next.key, level: candidate.level ) {
                    switch portals[next.key]!.type {
                    case .enter:
                        break
                    case .leave:
                        let point = next.key
                        let distance = candidate.distance + next.value
                        let level = candidate.level
                        
                        queue.append( Candidate( point: point, distance: distance, level: level ) )
                    case .outside:
                        if candidate.level > 0 {
                            let point = portals[next.key]!.destination
                            let distance = candidate.distance + next.value + 1
                            let level = candidate.level - 1
                            
                            queue.append( Candidate( point: point, distance: distance, level: level ) )
                        }
                    case .inside:
                        let point = portals[next.key]!.destination
                        let distance = candidate.distance + next.value + 1
                        let level = candidate.level + 1
                        
                        queue.append( Candidate( point: point, distance: distance, level: level ) )
                    }
                }
            }
        }
        
        return 0
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
let donut = Donut( input: input )

print( "Part 1: \( donut.traverse() )" )
print( "Part 2: \( donut.traverseRecurse() )" )
