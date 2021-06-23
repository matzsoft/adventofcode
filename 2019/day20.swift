//
//         FILE: main.swift
//  DESCRIPTION: day20 - Donut Maze
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/15/21 18:08:55
//

import Foundation

struct Donut {
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
        let destination: Point2D
        let type: PortalType
    }

    let map: Set<Point2D>
    let portals: [ Point2D : Portal ]
    let enter: Point2D
    let leave: Point2D
    
    init( lines: [String] ) {
        let grid = lines.map { Array( $0 ) }
        var map = Set<Point2D>()
        var portals: [ Point2D : Portal ] = [:]
        var labels: [ String : Point2D ] = [:]
        var enter: Point2D?
        var leave: Point2D?
        
        func getLabel( grid: [[Substring.Element]], x: Int, y: Int ) -> ( String, Point2D, PortalType )? {
            var label = ""
            var point: Point2D?
            
            if y < grid.count - 1 && grid[y+1][x].isUppercase {
                label = String( grid[y][x] ) + String( grid[y+1][x] )
                
                if y > 0 && grid[y-1][x] == "." {
                    point = Point2D( x: x, y: y-1 )
                } else if y < grid.count - 2 && grid[y+2][x] == "." {
                    point = Point2D( x: x, y: y+2 )
                }
            } else if x < grid[y].count - 1 && grid[y][x+1].isUppercase {
                label = String( grid[y][x] ) + String( grid[y][x+1] )

                if x > 0 && grid[y][x-1] == "." {
                    point = Point2D( x: x-1, y: y )
                } else if x < grid[y].count - 2 && grid[y][x+2] == "." {
                    point = Point2D( x: x+2, y: y )
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
                    map.insert( Point2D( x: x, y: y ) )
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
            
            for move in Direction4.allCases {
                let next = current + move.vector
                
                if map.contains( next ) && !seen.contains( next ) {
                    queue.append( ( next, distance + 1 ) )
                }
            }
        }
        
        return 0
    }
    
    struct Node {
        var list: [ Point2D : Int ]
    }
    
    func getNetwork() -> [ Point2D : Node ] {
        var network: [ Point2D : Node ] = [:]
        
        for portal in portals {
            if portal.value.type != .leave {
                network[portal.key] = traverseSubnet( point: portal.key )
            }
        }
        return network
    }
    
    func networkAsString( network: [ Point2D : Node ] ) -> String {
        var result: [ String ] = []
        
        for key in network.keys.sorted( by: { portals[$0]!.label < portals[$1]!.label } ) {
            let list = network[key]!.list
            let string = list.keys.map { "\( portals[$0]!.label):\(list[$0]! )" }.joined( separator: ", " )
            
            result.append( "\( portals[key]!.label ) => \(string)" )
        }
        
        return result.joined( separator: "\n" )
    }
    
    func traverseSubnet( point: Point2D ) -> Node {
        var subnet = Node( list: [:] )
        var queue: [ ( Point2D, Int ) ] = []
        var seen = Set( [ point ] )
  
        func moveOne( current: Point2D, distance: Int ) -> Void {
            for move in Direction4.allCases {
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
        let point: Point2D
        let distance: Int
        let level: Int
    }
    
    struct BeenThere {
        var record: [ Point2D : Set<Int> ] = [:]

        mutating func check( point: Point2D, level: Int ) -> Bool {
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
        var loopDetector: Set<[Point2D]> = []
        
        //print( networkAsString( network: network ) )
        while !queue.isEmpty {
            queue.sort { $0.distance < $1.distance }
            let queuePoints = queue.map { $0.point }
            
            guard !loopDetector.contains( queuePoints ) else {
                print( "Part 2: No solution" )
                exit( 1 )
            }
            loopDetector.insert( queuePoints )
            
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



func parse( input: AOCinput ) -> Donut {
    return Donut( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let donut = parse( input: input )
    return "\( donut.traverse() )"
}


func part2( input: AOCinput ) -> String {
    let donut = parse( input: input )
    return "\( donut.traverseRecurse() )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
