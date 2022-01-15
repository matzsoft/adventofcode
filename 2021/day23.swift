//
//         FILE: main.swift
//  DESCRIPTION: day23 - Amphipod
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/22/21 22:26:50
//

import Foundation

let asciiA = Int( Character( "A" ).asciiValue! )

func occupant( value: Int? ) -> String {
    guard let value = value else { return "." }
    return String( Character( UnicodeScalar( value + asciiA )! ) )
}


struct Tree {
    class Node {
        let burrow: Burrow
        var final: Burrow?
        let candidates: [Node]
        
        init( burrow: Burrow, candidates: [Node], final: Burrow? = nil ) {
            self.burrow = burrow
            self.final = final
            self.candidates = candidates
        }
    }
}


struct Burrow: CustomStringConvertible, Hashable {
    static let moveCosts = [ 1, 10, 100, 1000 ]
    static let entries = [ 2, 4, 6, 8 ]
    
    let hallway: [Int?]
    let rooms: [[Int?]]
    let energy: Int
    
    var isFinal: Bool { Burrow.entries.indices.allSatisfy { rooms[0][$0] == $0 && rooms[1][$0] == $0 } }
    var description: String {
        var lines = [ "Energy: \(energy)", String( repeating: "#", count: 13 ) ]
        
        lines.append( "#" + hallway.map { occupant( value: $0 ) }.joined() + "#" )
        lines.append( "###" + rooms[0].map { occupant( value: $0 ) }.joined( separator: "#" ) + "###" )
        lines.append( "  #" + rooms[1].map { occupant( value: $0 ) }.joined( separator: "#" ) + "#" )
        lines.append( "  " + String( repeating: "#", count: 9 ) )

        return lines.joined( separator: "\n" )
    }
    
    init( hallway: [Int?], rooms: [[Int?]], energy: Int ) {
        self.hallway = hallway
        self.rooms = rooms
        self.energy = energy
    }
    
    init( lines: [String] ) {
        hallway = Array( repeating: nil, count: 11 )
        rooms = lines[2...3].map {
            $0.filter { "ABCD?".contains( $0 ) }.map { Int( $0.asciiValue! ) - asciiA }
        }
        energy = 0
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( hallway )
        hasher.combine( rooms )
    }

    var possibleMoves: [Burrow] {
        let inHall = hallway.indices.filter( { hallway[$0] != nil } )
        let inRoom = rooms[0].indices.filter( { exitDepth( roomIndex: $0 ) != nil } )
        var moves = inHall.compactMap { moveInto( hallIndex: $0 ) }

        moves.append( contentsOf: inRoom.flatMap { moveOut( roomIndex: $0 ) } )
        return moves
    }
    
    var possibleMoveOutIn: [Burrow] {
        let candidates = rooms[0].indices.filter { exitDepth( roomIndex: $0 ) != nil }
        return candidates.compactMap { moveOutIn( roomIndex: $0 ) }
    }
    
    var possibleMoveIn: [Burrow] {
        let candidates = hallway.indices.filter { hallway[$0] != nil }
        return candidates.compactMap { moveInto( hallIndex: $0 ) }
    }
    
    var theoretical: Int {
        var newRooms = Array( repeating: rooms.count, count: rooms[0].count )
        var lastIndex = Array<Array<Int?>.Index?>( repeating: nil, count: rooms[0].count )
        var count = 0

        for roomIndex in rooms[0].indices {
            for depth in rooms.indices.reversed() {
                if rooms[depth][roomIndex] != roomIndex { break }
                newRooms[roomIndex] -= 1
                lastIndex[roomIndex] = depth
            }
        }
        
        for hallIndex in hallway.indices.filter( { hallway[$0] != nil } ) {
            let type = hallway[hallIndex]!
            let distance = abs( hallIndex - Burrow.entries[type] ) + newRooms[type]
            newRooms[type] -= 1
            count += distance * Burrow.moveCosts[type]
        }

        for roomIndex in rooms[0].indices {
            for depth in 0 ..< ( lastIndex[roomIndex] ?? ( rooms.indices.last! + 1 ) ) {
                if let type = rooms[depth][roomIndex] {
                    let hallDistance = abs( Burrow.entries[roomIndex] - Burrow.entries[type] )
                    let distance = depth + 1 + hallDistance + newRooms[type]
                    newRooms[type] -= 1
                    count += distance * Burrow.moveCosts[type]
                }
            }
        }

        return count
    }
    
    func exitDepth( roomIndex: Int ) -> Int? {
        guard let exitDepth = rooms.indices.first( where: { rooms[$0][roomIndex] != nil } ) else {
            return nil
        }
        if rooms[exitDepth][roomIndex] == roomIndex {
            let range = exitDepth ..< rooms.count
            if range.allSatisfy( { rooms[$0][roomIndex] == roomIndex } ) { return nil }
        }
        return exitDepth
    }
    
    func entryDepth( roomIndex: Int ) -> Int? {
        guard let entryDepth = rooms.indices.last( where: { rooms[$0][roomIndex] == nil } ) else {
            return nil
        }
        let range = ( entryDepth + 1 ..< rooms.count )
        guard range.allSatisfy( { rooms[$0][roomIndex] == roomIndex } ) else { return nil }
        return entryDepth
    }
    
    func notBlocked( hallIndex: Int, entryIndex: Int ) -> Bool {
        if hallIndex < entryIndex { return hallway[hallIndex+1...entryIndex].allSatisfy { $0 == nil } }
        return hallway[entryIndex...hallIndex-1].allSatisfy { $0 == nil }
    }

    func moveOut( roomIndex: Int, hallIndex: Int ) -> Burrow? {
        if Burrow.entries.contains( hallIndex ) { return nil }
        if hallway[hallIndex] != nil { return nil }
        guard let exitDepth = exitDepth( roomIndex: roomIndex ) else { return nil }
        let type = rooms[exitDepth][roomIndex]!
        let exitIndex = Burrow.entries[roomIndex]
        guard notBlocked( hallIndex: hallIndex, entryIndex: exitIndex ) else { return nil }

        let distance = abs( exitIndex - hallIndex ) + exitDepth + 1
        let newEnergy = distance * Burrow.moveCosts[type]
        var newHall = hallway
        var newRooms = rooms

        newHall[hallIndex] = type
        newRooms[exitDepth][roomIndex] = nil
        return Burrow( hallway: newHall, rooms: newRooms, energy: energy + newEnergy )
    }
    
    func moveOutIn( roomIndex: Int ) -> Burrow? {
        guard let exitDepth = exitDepth( roomIndex: roomIndex ) else { return nil }
        let type = rooms[exitDepth][roomIndex]!
        let exitIndex = Burrow.entries[roomIndex]
        let entryIndex = Burrow.entries[type]
        guard let entryDepth = entryDepth( roomIndex: type ) else { return nil }
        guard notBlocked( hallIndex: exitIndex, entryIndex: entryIndex ) else { return nil }
        let distance = abs( exitIndex - entryIndex ) + exitDepth + entryDepth + 2
        let newEnergy = distance * Burrow.moveCosts[type]
        var newRooms = rooms
        
        newRooms[exitDepth][roomIndex] = nil
        newRooms[entryDepth][type] = type
        return Burrow( hallway: hallway, rooms: newRooms, energy: energy + newEnergy )
    }
    
    func moveInto( hallIndex: Int ) -> Burrow? {
        guard let type = hallway[hallIndex] else { return nil }
        let entryIndex = Burrow.entries[type]
        guard notBlocked( hallIndex: hallIndex, entryIndex: entryIndex ) else { return nil }
        guard let entryDepth = entryDepth( roomIndex: type ) else { return nil }

        let distance = abs( hallIndex - entryIndex ) + entryDepth + 1
        let newEnergy = distance * Burrow.moveCosts[type]
        var newHall = hallway
        var newRooms = rooms

        newHall[hallIndex] = nil
        newRooms[entryDepth][type] = type

        return Burrow( hallway: newHall, rooms: newRooms, energy: energy + newEnergy )
    }

    func moveOut( roomIndex: Int ) -> [Burrow] {
        if let move = moveOutIn( roomIndex: roomIndex ) { return [ move ] }
        var leftRange = 0 ..< Burrow.entries[roomIndex]
        if let firstIndex = leftRange.last( where: { hallway[$0] != nil } ) {
            leftRange = firstIndex + 1 ..< Burrow.entries[roomIndex]
        }
        
        var rightRange = Burrow.entries[roomIndex] + 1 ..< hallway.count
        if let lastIndex = rightRange.first( where: { hallway[$0] != nil } ) {
            rightRange = Burrow.entries[roomIndex] + 1 ..< lastIndex
        }
        
        return
            leftRange.compactMap { moveOut( roomIndex: roomIndex, hallIndex: $0 ) } +
            rightRange.compactMap { moveOut( roomIndex: roomIndex, hallIndex: $0 ) }
    }

    var score: Int {
        let score0 = rooms[0].indices.filter {
            rooms[0][$0] == $0 && rooms[1][$0] == $0
        }.map { 4 * Burrow.moveCosts[$0] }.reduce( 0, + )
        let score1 = rooms[1].indices.filter {
            rooms[1][$0] == $0
        }.map { 3 * Burrow.moveCosts[$0] }.reduce( 0, + )
        let scoreH = hallway.indices.filter {
            hallway[$0] != nil && abs( $0 - Burrow.entries[ hallway[$0]! ] ) == 1
        }.map { Burrow.moveCosts[ hallway[$0]! ] }.reduce( 0, + )
        
        return score0 + score1 + scoreH
    }
    
    var neighbors: [Burrow] {
        var cumulative = self
        var list = possibleMoveOutIn
        
        if list.isEmpty { list = cumulative.possibleMoveIn }
        while !list.isEmpty {
            while !list.isEmpty {
                cumulative = list.first!
                list = cumulative.possibleMoveOutIn
            }
            
            list = cumulative.possibleMoveIn
            while !list.isEmpty {
                cumulative = list.first!
                list = cumulative.possibleMoveIn
            }
            list = cumulative.possibleMoveOutIn
        }

        list = cumulative.possibleMoves
        if cumulative != self && list.isEmpty { return [ cumulative ] }
        return list
    }
    
    func organize() -> Tree.Node {
        if isFinal { return Tree.Node( burrow: self, candidates: [], final: self ) }
        let list = neighbors
        if list.isEmpty { return Tree.Node( burrow: self, candidates: [] ) }
        
        let sorted = list.reduce( into: [ Burrow : Int ]() ) { $0[$1] = $1.score }.sorted {
            $0.value > $1.value
        }
        
        let candidates = sorted.map { $0.key.organize() }
        let final = candidates.compactMap { $0.final }.min( by: { $0.energy < $1.energy } )
        
        return Tree.Node( burrow: self, candidates: candidates, final: final )
    }
}


func part1( input: AOCinput ) -> String {
    let burrow = Burrow( lines: input.lines )
    let tree = burrow.organize()
    
    if let final = tree.final {
        return "\( final.energy )"
    }
    
    return "No solution"
}


func part2( input: AOCinput ) -> String {
    let burrow = Burrow( lines: input.lines )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
