//
//  main.swift
//  day18n
//
//  Created by Mark Johnson on 12/30/19.
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

struct Path: CustomStringConvertible {
    let distance: Int
    let keyPath: [Character]
    let keys: Set<Character>
    let doorPath: [Character]
    let doors: Set<Character>
    
    public var description: String {
        return """
            distance: \(distance)
            keyPath:  \( String(keyPath) )
            keys:     \( String( keys.sorted() ) )
            doorPath: \( String(doorPath) )
            doors:    \( String( doors.sorted() ) )
        """
    }
    
    static var empty: Path {
        return Path( distance: 0, keyPath: [], keys: Set(), doorPath: [], doors: Set() )
    }
    
    func add( distance: Int ) -> Path {
        return Path(
            distance: self.distance + distance,
            keyPath: keyPath,
            keys: keys,
            doorPath: doorPath,
            doors: doors
        )
    }
    
    func add( distance: Int, key: Character ) -> Path {
        return Path(
            distance: self.distance + distance,
            keyPath: keyPath + [ key ],
            keys: keys.union( [ key ] ),
            doorPath: doorPath,
            doors: doors
        )
    }
    
    func add( distance: Int, door: Character ) -> Path {
        return Path(
            distance: self.distance + distance,
            keyPath: keyPath,
            keys: keys,
            doorPath: doorPath + [ door ],
            doors: doors.union( [ door ] )
        )
    }
    
    func add( other: Path ) -> Path {
        return Path(
            distance: distance + other.distance,
            keyPath: keyPath + other.keyPath,
            keys: keys.union( other.keys ),
            doorPath: doorPath + other.doorPath,
            doors: doors.union( other.doors )
        )
    }
    
    func removeKey( key: Character ) -> Path {
        return Path(
            distance: distance,
            keyPath: keyPath.filter { $0 != key },
            keys: keys,
            doorPath: doorPath.filter { $0 != key },
            doors: doors.subtracting( [ key ] )
        )
    }
    
    func min( other: Path ) -> Path {
        return distance < other.distance ? self : other
    }
}

struct Vault: CustomStringConvertible {
    let map: Set<Point>
    let entry: Point
    let keys: Set<Character>
    let keysByName: [ Character : Point ]
    let keysByLocation: [ Point : Character ]
    let doorsByName: [ Character : Point ]
    let doorsByLocation: [ Point : Character ]
    
    var description: String {
        var result: [String] = []
        
        result.append( "Entry: \(entry)" )
        keysByName.keys.sorted().forEach { result.append(" \($0): \( keysByName[$0]! )" ) }
        doorsByName.keys.sorted().forEach {
            result.append(" \( String( $0 ).uppercased() ): \( doorsByName[$0]! )" )
        }
        
        return result.joined( separator: "\n" )
    }
    
    init( input: String ) {
        let grid = input.split( separator: "\n" ).map { Array( $0 ) }
        var map = Set<Point>()
        var entry = Point( x: 0, y: 0 )
        var keysByName: [ Character : Point ] = [:]
        var keysByLocation: [ Point : Character ] = [:]
        var doorsByName: [ Character : Point ] = [:]
        var doorsByLocation: [ Point : Character ] = [:]
        
        for y in 0 ..< grid.count {
            for x in 0 ..< grid[y].count {
                let position = Point( x: x, y: y )
                switch grid[y][x] {
                case "#":
                    break
                case "@":
                    entry = position
                    map.insert( position )
                case ".":
                    map.insert( position )
                case let char where char.isLowercase:
                    guard keysByName[char] == nil else {
                        print( "Duplicate key '\(grid[y][x])' at \(x),\(y)" )
                        exit(1)
                    }
                    keysByName[char] = position
                    keysByLocation[position] = char
                    map.insert( position )
                case let char where char.isUppercase:
                    let door = Character( String( char ).lowercased() )
                    guard doorsByName[door] == nil else {
                        print( "Duplicate door '\(grid[y][x])' at \(x),\(y)" )
                        exit(1)
                    }
                    doorsByName[door] = position
                    doorsByLocation[position] = door
                    map.insert( position )
                default:
                    print( "Invalid character '\(grid[y][x])' at \(x),\(y)" )
                    exit(1)
                }
            }
        }
        
        self.map = map
        self.entry = entry
        self.keys = Set<Character>( keysByName.keys )
        self.keysByName = keysByName
        self.keysByLocation = keysByLocation
        self.doorsByName = doorsByName
        self.doorsByLocation = doorsByLocation
    }
    
    init( from: Vault, map: Set<Point>, entry: Point ) {
        var queue = [ entry ]
        var seen = Set<Point>()
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            seen.insert( current )
            for move in Direction.allCases {
                let next = current + move.vector
                
                if map.contains( next ) && !seen.contains( next ) {
                    queue.append( next )
                }
            }
        }
        
        self.map = seen
        self.entry = entry
        self.keys = from.keys
        self.keysByName = from.keysByName
        self.keysByLocation = from.keysByLocation
        self.doorsByName = from.doorsByName
        self.doorsByLocation = from.doorsByLocation
    }
    
    func getConnections( symbol: Character ) -> [ Character : Path ] {
        var queue = [ ( symbol == "@" ? entry : keysByName[symbol]!, Path.empty ) ]
        var seen = Set<Point>()
        var network: [ Character : Path ] = [:]
        
        while !queue.isEmpty {
            let ( current, path ) = queue.removeFirst()
            
            seen.insert( current )
            for move in Direction.allCases {
                let next = current + move.vector
                
                if map.contains( next ) && !seen.contains( next ) {
                    if let key = keysByLocation[next] {
                        network[key] = path.add( distance: 1, key: key )
                    } else if let door = doorsByLocation[next] {
                        if path.keys.contains( door ) {
                            queue.append( ( next, path.add( distance: 1 ) ) )
                        } else {
                            queue.append( ( next, path.add( distance: 1, door: door ) ) )
                        }
                    } else {
                        queue.append( ( next, path.add( distance: 1 ) ) )
                    }
                }
            }
        }
        
        return network
    }
}

struct Network: CustomStringConvertible {
    let network: [ Character : [ Character : Path ] ]
    let path: Path
    
    var description: String {
        var result: [String] = []
        
        for key1 in network.keys.sorted() {
            for key2 in network[key1]!.keys.sorted() {
                result.append( "\(key1) => \(key2)" )
                result.append( String( describing: network[key1]![key2]! ) )
            }
        }
        return result.joined( separator: "\n" )
    }
    
    var isFinished: Bool {
        return network.values.allSatisfy { $0.isEmpty }
    }

    init( network: [ Character : [ Character : Path ] ], path: Path ) {
        self.network = network
        self.path = path
    }
    
    init( vault: Vault ) {
        var network: [ Character : [ Character : Path ] ] = [:]
        
        network["@"] = vault.getConnections( symbol: "@" )
        vault.keys.sorted().forEach {
            network[$0] = vault.getConnections( symbol: $0 )
        }
        
        self.init( network: network, path: Path.empty )
    }
    
    func isEquivalent( to other: Network ) -> Bool {
        guard Set( network.keys ) == Set( other.network.keys ) else { return false }
        
        return path.keyPath.last == other.path.keyPath.last
    }
    
    func moveTo( finish: Character ) -> Network {
        var network = self.network
        let path = self.path.add( other: network["@"]![finish]! )
        
        guard network.removeValue( forKey: "@" ) != nil else {
            print( "Network is munged" )
            exit( 1 )
        }
        
        guard let endRow = network.removeValue( forKey: finish ) else {
            print( "Network is broken" )
            exit( 1 )
        }
        
        network["@"] = endRow
        for rowKey in network.keys {
            let endCol = network[rowKey]!.removeValue( forKey: finish )
            
            for colKey in network[rowKey]!.keys {
                network[rowKey]![colKey]! = network[rowKey]![colKey]!.removeKey( key: finish )
            }
            
            if let endCol = endCol {
                let replacementSet = Set( endRow.keys ).subtracting( network[rowKey]!.keys + [ rowKey ] )
                
                for replacement in endRow.filter( { replacementSet.contains( $0.key ) } ) {
                    network[rowKey]![replacement.key] = Path(
                        distance: endCol.distance + replacement.value.distance,
                        keyPath: [ replacement.key ],
                        keys: Set( [ replacement.key ] ),
                        doorPath: replacement.value.doorPath.filter { $0 != finish },
                        doors: replacement.value.doors.subtracting( [ finish ] )
                    )
                }
            }
        }
        
        return Network( network: network, path: path )
    }
    
    func remove( door: Character ) -> Network {
        var network = self.network

        for row in network {
            for col in row.value {
                let path = col.value
                
                network[row.key]![col.key] = Path(
                    distance: path.distance,
                    keyPath: path.keyPath,
                    keys: path.keys,
                    doorPath: path.doorPath.filter { $0 != door },
                    doors: path.doors.subtracting( [ door ] )
                )
            }
        }
        
        return Network( network: network, path: path )
    }

    func gatherAll() -> Path {
        var queue = [ self ]
        var finals: [Network] = []
        
        while !queue.isEmpty {
            let manifest = queue
            var newQueue: [ Network ] = []
            
            for network in manifest {
                let candidates = network.network["@"]!.filter { $0.value.doors.isEmpty }
                
                for candidate in candidates {
                    let result = network.moveTo( finish: candidate.key )
                    
                    if result.isFinished {
                        finals.append( result )
                    } else {
                        newQueue.append( result )
                    }
                }
            }
            
            queue = []
            while !newQueue.isEmpty {
                let dupes = newQueue.filter { $0.isEquivalent( to: newQueue.first! ) }
                
                queue.append( dupes.min( by: { $0.path.distance < $1.path.distance } )! )
                newQueue = newQueue.filter { !$0.isEquivalent( to: newQueue.first! ) }
            }
        }
        
        return finals.min( by: { $0.path.distance < $1.path.distance } )!.path
    }
}

struct MultiNetwork: CustomStringConvertible {
    let networks: [Network]
    let path: Path
    
    init( vault: Vault ) {
        var map = vault.map
        let newEntries = [
            vault.entry + Direction.north.vector + Direction.west.vector,
            vault.entry + Direction.north.vector + Direction.east.vector,
            vault.entry + Direction.south.vector + Direction.east.vector,
            vault.entry + Direction.south.vector + Direction.west.vector,
        ]
        
        Direction.allCases.map { vault.entry + $0.vector }.forEach {
            guard map.remove( $0 ) != nil else {
                print( "Unable to build wall at \($0)" )
                exit(1)
            }
        }
        
        networks = newEntries.map { Network( vault: Vault( from: vault, map: map, entry: $0 ) ) }
        path = Path.empty
    }
    
    init( from multinet: MultiNetwork, removing key: Character, in position: Int ) {
        var newDistance = multinet.distance
        
        networks = multinet.networks.indices.map {
            if $0 != position {
                return multinet.networks[$0].remove( door: key )
            } else {
                let network = multinet.networks[$0].moveTo( finish: key )
                
                newDistance += network.path.distance - multinet.networks[$0].path.distance
                return network
            }
        }
        path = Path(
            distance: newDistance,
            keyPath: multinet.path.keyPath + [ key ],
            keys: multinet.path.keys.union( [ key ] ),
            doorPath: multinet.path.doorPath,
            doors: multinet.path.doors
        )
    }
    
    var description: String {
        return networks.indices.map { "Network \($0)\n\(networks[$0])" }.joined(separator: "\n" )
    }
    
    var distance: Int {
        return networks.reduce( 0, { $0 + $1.path.distance } )
    }
    
    var isFinished: Bool {
        return networks.allSatisfy { $0.isFinished }
    }
    
    func isEquivalent( to other: MultiNetwork ) -> Bool {
        guard networks.count == other.networks.count else { return false }
        
        return networks.indices.allSatisfy { networks[$0].isEquivalent( to: other.networks[$0] ) }
    }
    
    func getCandidates( for position: Int ) -> [MultiNetwork] {
        let eligibles = networks[position].network["@"]!.filter { $0.value.doors.isEmpty }.map { $0.key }
        
        return eligibles.map { MultiNetwork( from: self, removing: $0, in: position ) }
    }
    
    func gatherAll() -> Path {
        var queue = [ self ]
        var finals: [MultiNetwork] = []
        
        while !queue.isEmpty {
            let manifest = queue
            var newQueue: [MultiNetwork] = []
            
            for multinet in manifest {
                for position in 0 ..< multinet.networks.count {
                    let candidates = multinet.getCandidates( for: position )

                    for candidate in candidates {
                        if candidate.isFinished {
                            finals.append( candidate )
                        } else {
                            newQueue.append( candidate )
                        }
                    }
                }
            }
            
            queue = []
            while !newQueue.isEmpty {
                let dupes = newQueue.filter { $0.isEquivalent( to: newQueue.first! ) }
                
                queue.append( dupes.min( by: { $0.distance < $1.distance } )! )
                newQueue = newQueue.filter { !$0.isEquivalent( to: newQueue.first! ) }
            }
        }
        
        return finals.min( by: { $0.distance < $1.distance } )!.path
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
let vault = Vault( input: input )
let network = Network( vault: vault )

//print( network )
print( "Part 1:" )
print( network.gatherAll() )

let multiNetwork = MultiNetwork(vault: vault )
//print( multiNetwork )
print( "Part 2:" )
print( multiNetwork.gatherAll() )
