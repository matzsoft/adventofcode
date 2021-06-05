//
//         FILE: main.swift
//  DESCRIPTION: day15 - Oxygen System
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/04/21 14:49:22
//

import Foundation

extension DirectionUDLR {
    var inputValue: Int {
        switch self {
        case .up:
            return 1
        case .down:
            return 2
        case .left:
            return 3
        case .right:
            return 4
        }
    }
}

struct Droid {
    enum Status: Int {
        case wall = 0, open = 1, oxygen = 2
        
        var asString: String {
            switch self {
            case .wall:
                return "█"
            case .open:
                return " "
            case .oxygen:
                return "⌼"
            }
        }
    }

    struct Cell {
        let status: Status
        let unchecked: Set<DirectionUDLR>
        
        init( status: Status ) {
            self.status = status
            switch status {
            case .open, .oxygen:
                unchecked = Set<DirectionUDLR>( DirectionUDLR.allCases )
            case .wall:
                unchecked = Set<DirectionUDLR>()
            }
        }
        
        init( status: Status, unchecked: Set<DirectionUDLR> ) {
            self.status = status
            self.unchecked = unchecked
        }

        var asString: String { return status.asString }
        
        func checked( move: DirectionUDLR ) -> Cell {
            return Cell( status: status, unchecked: unchecked.subtracting( [ move ] ) )
        }
    }

    struct Path {
        let start: Point2D
        let end: Point2D
        let path: [ DirectionUDLR ]
    }

    var computer: Intcode
    var position = Point2D( x: 0, y: 0 )
    var map: [ Point2D : Cell ] = [ Point2D( x: 0, y: 0 ) : Cell( status: .open ) ]
    
    init( initialMemory: [Int] ) {
        computer = Intcode(name: "Huey", memory: initialMemory )
    }
    
    mutating func check( cell: Cell, for move: DirectionUDLR ) throws -> Void {
        let newPos = position + move.vector

        map[position] = cell.checked( move: move )
        if let newCell = map[newPos] {
            map[newPos] = newCell.checked( move: move.turn( Turn.back ) )
        } else {
            computer.inputs = [ move.inputValue ]
            let status = Status( rawValue: try computer.execute()! )!

            map[newPos] = Cell( status: status ).checked( move: move.turn( Turn.back ) )
            switch status {
            case .wall:
                break
            case .open, .oxygen:
                position = newPos
            }
//            print( asString )
//            print()
        }
    }
    
    func findPath( start: Point2D, until: (Cell) -> Bool ) -> Path {
        let startPath = Path( start: start, end: start, path: [] )
        var queue = [ startPath ]
        var seen = Set<Point2D>( [ start ] )
        
        while !queue.isEmpty {
            let thisPath = queue.removeFirst()
            
            if until( map[thisPath.end]! ) {
                return thisPath
            }
            
            for move in DirectionUDLR.allCases {
                let nextPos = thisPath.end + move.vector
                
                if !seen.contains( nextPos ) {
                    if let cell = map[nextPos] {
                        switch cell.status {
                        case .wall:
                            break
                        case .open, .oxygen:
                            let newPath = thisPath.path + [ move ]
                            
                            seen.insert( nextPos )
                            queue.append( Path( start: thisPath.start, end: nextPos, path: newPath ) )
                        }
                    }
                }
            }
        }
        
        return startPath
    }

    mutating func move( along path: Path ) throws -> Status {
        var lastStatus = map[position]!.status
        
        for move in path.path {
            computer.inputs = [ move.inputValue ]
            lastStatus = Status( rawValue: try computer.execute()! )!
            if lastStatus != .wall {
                position = position + move.vector
            }
        }
        
        return lastStatus
    }
    
    mutating func createMap() throws -> Void {
        while !map.allSatisfy( { $1.unchecked.isEmpty } ) {
            guard let cell = map[position] else {
                print( "Droid position compromised" )
                exit(1)
            }
            
            if let move = cell.unchecked.first {
                try check( cell: cell, for: move )
            } else {
                let path = findPath( start: position, until: { !$0.unchecked.isEmpty } )
                
                if try move( along: path ) == .wall {
                    throw RuntimeError( "Path movement failed" )
                }
            }
        }
    }
    
    func isAdjacent( location: Point2D, status: Status ) -> Bool {
        for move in DirectionUDLR.allCases {
            if let check = map[ location + move.vector ], check.status == status { return true }
        }
        return false
    }
    
    mutating func oxygenFill() -> Int {
        var time = 0
        
        while !map.allSatisfy( { $1.status != .open } ) {
            let nextFills = map.filter {
                $0.value.status == .open && isAdjacent( location: $0.key, status: .oxygen )
            }
            
            time += 1
            nextFills.forEach { map[$0.key] = Cell( status: .oxygen, unchecked: $0.value.unchecked ) }
        }
        
        return time
    }
    
    var asString: String {
        let bounds = Rect2D( points: map.map { $0.key } )
        var grid = Array(
            repeating: Array( repeating: ".", count: bounds.width + 2 ),
            count: bounds.height + 2
        )
        
        for ( location, cell ) in map {
            let y = location.y - bounds.min.y + 1
            let x = location.x - bounds.min.x + 1
            
            if location == position {
                grid[y][x] = "○"
            } else if location == Point2D( x: 0, y: 0 ) {
                grid[y][x] = "^"
            } else {
                grid[y][x] = cell.asString
            }
        }
        
        return grid.map { $0.joined() }.joined( separator: "\n" )
    }
}


func parse( input: AOCinput ) -> Droid {
    let initialMemory = input.line.split( separator: "," ).map { Int($0)! }
    var droid = Droid( initialMemory: initialMemory )
    
    try! droid.createMap()
    return droid
}


func part1( input: AOCinput ) -> String {
    let droid = parse( input: input )
    let path = droid.findPath( start: Point2D( x: 0, y: 0 ), until: { $0.status == .oxygen } )
    
    return "\( path.path.count )"
}


func part2( input: AOCinput ) -> String {
    var droid = parse( input: input )
    return "\( droid.oxygenFill() )"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
